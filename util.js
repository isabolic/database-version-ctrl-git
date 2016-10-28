(function(){

    const db             = require('promise-oracledb');
    const oracledb       = require('oracledb');
    const q              = require('q');
    const log            = require('./logger.js');
    const fs             = require('fs');
    const dbConfig       = JSON.parse(fs.readFileSync("db.config.json"));

    const getRootFolder  = "begin                                     " +
                           "  :ret := p$ver_ctrl.f_get_root_dir;      " +
                           "end;                                      ";

    const getCLLocation  = "begin                                       " +
                           "  :ret := p$ver_ctrl.f_get_cl_file_location;" +
                           "end;                                        ";

    /**
     * [createFIleIfNotExist - PRIVATE helper function create file if doesn't exist ]
     * @param  {String} file [file path]
     * @return {[type]}      [description]
     */
    var createFIleIfNotExist = function (filePath){
        var def  = q.defer(),
            log  = new logger();

        fs.exists(filePath, function(exists){
              if (exists) {
                log.info(util.name, "file :'" + filePath + "' already exists...");
                def.resolve();
              } else {
                fs.open(filePath, 'wx', function(err, fd){
                    if (err){
                        log.error(util.name, err);
                        def.reject(err);
                    } else {
                        log.info(util.name, "file :'" + filePath + "' is created...");
                        def.resolve();
                    }
                });
              }
        });

        return def.promise;
    };

    util = {
        name : 'util',
        loadGitPath : function (){
            var cmd      = getRootFolder,
                def      = q.defer(),
                log      = new logger(),
                bindvars = {
                    ret:  { dir: oracledb.BIND_OUT, type: oracledb.VARCHAR2  }
                };

            db.setConnection({
                user: dbConfig.user,
                password: dbConfig.password,
                connectString: dbConfig.connectString,
                useJSONFormat: dbConfig.useJSONFormat,
                enableLogging: dbConfig.enableLogging,
            });

            db.getConnection()
                .then(function (conn){
                    conn.execute(
                        cmd,
                        bindvars,
                        function(err, result){
                            if (err){
                                log.error(util.name, err);
                                def.reject(err);
                            } else {
                                log.info(util.name, "root folder :" + result.outBinds.ret);

                                if (result.outBinds.ret !== null) {
                                    def.resolve(result.outBinds.ret);
                                }
                            }
                            conn.close();
                        }
                    );
                });
                return  def.promise;
        },

        loadCLlocation : function (){
            var cmd      = getCLLocation,
                def      = q.defer(),
                log      = new logger(),
                bindvars = {
                    ret:  { dir: oracledb.BIND_OUT, type: oracledb.VARCHAR2  }
                };

            db.setConnection({
                user: dbConfig.user,
                password: dbConfig.password,
                connectString: dbConfig.connectString,
                useJSONFormat: dbConfig.useJSONFormat,
                enableLogging: dbConfig.enableLogging,
            });

            db.getConnection()
                .done(function (err, conn){
                    if (err){
                        log.error(util.name, err);
                        def.reject(err);
                    }

                    conn.execute(
                        cmd,
                        bindvars,
                        function(err, result){
                            if (err){
                                log.error(util.name, err);
                                def.reject(err);
                            } else {
                                log.info(util.name, "CL location is :" + result.outBinds.ret);

                                if (result.outBinds.ret !== null) {
                                    def.resolve(result.outBinds.ret);
                                }
                            }
                            conn.close();
                        }
                    );
                });
                return  def.promise;
        },

        getNumberOfhttpConnection : function (httpServer){
            var def  = q.defer(),
                log  = new logger();

            httpServer.getConnections(function(err, nOfCon){
                    if (err) {
                        log.error(util.name, err);
                        def.reject(err);
                    } else {
                        log.info(util.name, "getNumberOfhttpConnection :" + nOfCon);
                        def.resolve(nOfCon);
                    }
            });

            return def.promise;
        },

        saveToCL: function (clPath, files){
            var def  = q.defer(),
                log  = new logger(),
                l    = files.length,
                i    = 0, r;

            createFIleIfNotExist(clPath).done(function(){

                files.forEach(function(row, idx){
                    r = "";
                    // new line chars...

                    if (idx === 0){
                        // separete commits with new line
                        r += ("\n\n");
                    }

                    // static files for apex workspace
                    if(row.toUpperCase().indexOf("STATIC") > -1 ){
                        r += ("-- kopirati static files\n");
                        r += ("--" + row  + "\n");
                    } else{
                        r += (row + "\n");
                    }

                    fs.appendFile(clPath, r, function(err) {
                        if(err) {
                            log.error(util.name, err);
                            def.reject(err);
                        }else{
                            log.info(util.name, "saveToCL.. appendFile..." + row);
                            i++;
                            if (l === i){
                                def.resolve();
                            }
                        }
                    });

                });
            });

            return def.promise;
        }
    };

})();