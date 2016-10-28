(function(){
    /**
     * [constants]
     */
    const db       = require('promise-oracledb');
    const oracledb = require('oracledb');
    const q        = require('q');
    const fs       = require('fs');
    const mkdirp   = require('mkdirp');
    const log      = require('./logger.js');
    const dbConfig = JSON.parse(fs.readFileSync("db.config.json"));


    const sqlString            = "select full_path          "   +
                                 "     , dir                "   +
                                 "     , x.sql_text         "   +
                                 "  from v_user_ddl_log x   "   +
                                 "  where 1=1               "   +
                                 "    and x.is_valid = 'Y'  ";

    const initExec             = " begin                                "    +
                                 "  p$utl_context.clear_context;        "    +
                                 "  p$utl_context.set_user( '#USER#' ); "    +
                                 " end;                                 ";

    const generateScripts      = " begin                                   " +
                                 "   p$apx_utl.generate_apex_comp_script;  " +
                                 "   p$db_object.generate_db_object_script;" +
                                 " end;                                    ";

    const updateDdlLogStatus   = " begin                                         " +
                                 "   p$ver_ctrl.upd_export_status_all(:revHash); " +
                                 " end;                                          ";

    const areJobsExpDone       = "begin                                     " +
                                 "  :ret := p$ver_ctrl.are_job_exports_done;" +
                                 "end;                                      ";

    /**
     * [setConnection - PRIVATE set ddlLog connection object]
     * @param  {Object}          conn [oracle connection object]
     * @return {Q.defer.promise}
     */
    var setConnection = function(conn){
        var def = q.defer();
        this.log.info(this.name, "setConnection... ");
        if (this.oraCon === null){
            this.oraCon = conn;
            def.resolve();
        }else{
            this.log.info(this.name, "not connected to DB");
            def.reject();
        }
        return  def.promise;
    };

    /**
     * [cmdCloseDBConn - PRIVATE close connection to database]
     * @return {Q.defer.promise}
     */
    var cmdCloseDBConn = function(){
        var def = q.defer();

        this.log.info(this.name, "cmdCloseDBConn...");

        this.oraCon.close(function(err){
                        if (err){
                            this.log.error(this.name, err);
                            def.reject(err);
                        }else{
                            this.oraCon = null;
                            def.resolve();
                        }
                    }.bind(this));
        return  def.promise;
    };

    /**
     * [cmdGenScripts - PRIVATE generate apex, object scripts]
     * @return {Q.defer.promise}
     */
    var cmdGenScripts = function(){
        var cmd = generateScripts,
            def = q.defer();

        this.log.info(this.name, "cmdGenScripts...");
        this.log.info(this.name,  cmd);

        this.oraCon.execute(
                    cmd,
                    function(err, result){
                        if (err){
                            this.log.error(this.name, err);
                            def.reject(err);
                        }else {
                            def.resolve();
                        }
                    }.bind(this)
                );

        return  def.promise;
    };

    var areExpJobsDone = function (){
        var cmd = areJobsExpDone,
            def = q.defer(),
            intId,
            bindvars = {
                ret:  { dir: oracledb.BIND_OUT, type: oracledb.NUMBER  }
            }
            checkJobs = function(){
                this.oraCon.execute(
                            cmd,
                            bindvars,
                            function(err, result){
                                if (err){
                                    this.log.error(this.name, err);
                                    clearInterval(intId);
                                    def.reject(err);
                                } else {
                                    this.log.info(this.name, "jobs are done  = " + result.outBinds.ret);

                                    if (result.outBinds.ret === 1) {
                                        this.log.info(this.name, "job exports are done...");
                                        clearInterval(intId);
                                        def.resolve();
                                    }
                                }
                            }.bind(this)
                        );
            };

        this.log.info(this.name, "areExpJobsDone...");
        this.log.info(this.name,  cmd);
        intId = setInterval(checkJobs.bind(this), 3000);
        checkJobs.call(this);
        return  def.promise;
    };

    /**
     * [setContext - PRIVATE set context of user]
     * @return {Q.defer.promise}
     */
    var setContext = function(){
        var cmd = initExec,
            def = q.defer();

        cmd = cmd.replace("#USER#", this.options.user);

        this.log.info(this.name, "setContext...");
        this.log.info(this.name, cmd);

        this.oraCon.execute(
                    cmd,
                    function(err, result){
                        if (err){
                            this.log.error(this.name, err);
                            def.reject(err);
                        }else{
                            def.resolve();
                        }
                    }
                );

        return  def.promise;
    };

    /**
     * [cmdUpdateStatus - PRIVATE update status of ddl_log rows]
     * @return {Q.defer.promise}
     */
    var cmdUpdateStatus = function (hash){
        var cmd      = updateDdlLogStatus,
            def      = q.defer()
            bindvars = {
                revHash:  hash
            };

        this.log.info(this.name, "cmdUpdateStatus...");
        this.log.info(this.name, cmd);

        this.oraCon.execute(
                    cmd,
                    bindvars,
                    function(err, result){
                        if (err){
                            this.log.error(this.name, err);
                            def.reject(err);
                        }else{
                            def.resolve();
                        }
                    }.bind(this));

        return  def.promise;
    };

    /**
     * [cmdGetDDLs - PRIVATE get ddl scripts/objects from ddl_log]
     * @return {Q.defer.promise}
     */
    var cmdGetDDLs = function(){
        var sql  = sqlString,
            def  = q.defer(),
            that = this;

        this.log.info(this.name, "cmdGetDDLs...");
        this.log.info(this.name, sql);

        this.oraCon.execute(
            sql,
            function(err, result){
                if (err){
                    that.log.error(this.name, err);
                    def.reject(err);
                } else {
                    that.log.info(this.name, 'Data is loaded..');
                    that.result = result;
                    def.resolve();
                }
            });

        return def.promise;
    };

    /**
     * [writeToFs - PRIVATE write scripts/objects to fs]
     * @return {Q.defer.promise}
     */
    var writeToFs = function(){
        var rows     = this.result.rows,
              l      = rows.length,
              i      = 0,
              def    = q.defer(),
        errorHandler = function(err){
            this.log.error(this.name, err);
        };

        this.log.info(this.name, "writeToFs...");

        //if there is no rows...
        if(l === 0){
            def.resolve();
        }

        rows.forEach(function(row, idx){

            var fsPathwithFile = row[0]
               ,fsPath         = row[1]
               ,content        = row[2]
               ,outStream;

            //replace fullpath
            this.filesForCL.push(fsPathwithFile.replace(this.options.rootFolder, "@ ") + ";");

            mkdirp(fsPath, function (err) {
                if (err) {
                    errorHandler.call(this, err);
                }else{
                    this.log.info(this.name, 'created directory : ' + fsPath);
                }

                if(!content){
                  this.log.info(this.name, 'Content is not good ' + content);
                }

                content.setEncoding('utf8');
                this.log.info(this.name, 'Writing to ' + fsPathwithFile);

                outStream = fs.createWriteStream(
                    fsPathwithFile, { flags: 'w', defaultEncoding: 'utf8', fd: null, mode: 0o666, autoClose: true }
                );

                outStream.on('error', errorHandler.bind(this));
                content.pipe(outStream);

                outStream.on("finish", function(){
                    content.close();
                    this.log.info(this.name, "content is closed...");
                    i++;
                    if (i === l){
                        def.resolve();
                    }
                }.bind(this));
            }.bind(this));
        }.bind(this));

        return def.promise;
    };

    /**
     * [executeAdapter - PRIVATE execute in order every call on DB and resolve object defer]
     * @param  {Object}          conn [oracle connection object]
     */
    var executeAdapter = function(conn){
        this.log.info(this.name, "executeAdapter...");

        q.fcall(setConnection.bind(this, conn))
         .then(setContext.bind(this))
         .then(cmdGenScripts.bind(this))
         .then(areExpJobsDone.bind(this))
         .then(cmdGetDDLs.bind(this))
         .then(writeToFs.bind(this))
         //.then(cmdUpdateStatus.bind(this))
         //.then(cmdCloseDBConn.bind(this))
         .catch(function (error) {
                    this.log.error(this.name, "executeAdapter..." + error);
                    //close db..
                    cmdCloseDBConn.call(this);
                    this.def.reject(error);
                }.bind(this))
         .fin(function(){
                    this.def.resolve();
                }.bind(this));
    };

    /**
     * [oracleDDL - constructor]
     * @param  {objects} opts [options for oracleDDL]
     * @return {this}         [oracleDDL constructor]
     */
    oracleDDL = function(opts) {
        this.result     =  {};
        this.name       = 'oracleDDL';
        this.options    = {user:null, rootFolder:null};
        this.oraCon     = null;
        this.def        = q.defer();
        this.filesForCL = [];
        this.init = function(){

            this.options.user       = opts.user;
            this.options.rootFolder = opts.rootFolder;

            this.options.rootFolder + "/";

            // If the last character is not a backslash
            if (this.options.rootFolder.substr(-1) !== '/') {
                this.options.rootFolder += "/";
            }

            this.log = new logger();
            this.log.info(this.name, "oracleDDL init...");

            db.setConnection({
                user         : dbConfig.user,
                password     : dbConfig.password,
                connectString: dbConfig.connectString,
                useJSONFormat: dbConfig.useJSONFormat,
                enableLogging: dbConfig.enableLogging
            });

            db.getConnection()
              .then(executeAdapter.bind(this));

            return this;
        }

        return this.init(opts);
    };

    /**
     * [oracleDDL constructor PUBLIC API methods]
     */
    oracleDDL.prototype = {
        getDefer: function (){
            this.log.info(this.name, "oracleDDL getDefer...");
            return this.def.promise;
        },

        getFilesForCL: function(){
            return this.filesForCL;
        },

        setRevisionOnDB:function (revHash){
          var def = q.defer();

           q.fcall(cmdUpdateStatus.bind(this, revHash))
            .then(cmdCloseDBConn)
            .catch(function (error){
                cmdCloseDBConn.call(this);
                def.reject(error);
            })
            .fin(function(){
                def.resolve();
            });

          return def.promise;
        }
    };

})();