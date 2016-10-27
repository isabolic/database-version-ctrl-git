(function() {
    const git   = require('simple-git');
    const log   = require('./logger.js');
    const q     = require('q');

    gitController = function(opts) {
        this.log        = null;
        this.rootFolder = null;
        this.name       = "gitController";
        this.init = function() {
            this.log        = new logger();
            this.rootFolder = opts.rootFolder;
            this.git        = git(this.rootFolder);

            this.log.info(this.name, "gitController init...");

            return this;
        }

        return this.init(opts);
    }


    gitController.prototype = {

        pull: function pull(){
            var def = q.defer();
            this.log.info(this.name, "gitController pull...");

            this.git.pull(function(err){
                if (err){
                   this.log.error(this.name, err);
                   def.reject(err);
                } else {
                   def.resolve();
                }
            }.bind(this));

            return def.promise;
        },

        getListOfChangedFiles :  function getListOfChangedFiles(){
            var def = q.defer();

            this.git.status(function(err, res){
                var FilesForAdd = [], tmpFileArray = [];
                if (err){
                   this.log.error(this.name, err);
                   def.reject(err);
                } else {

                  tmpFileArray = tmpFileArray.concat(res.created  );
                  tmpFileArray = tmpFileArray.concat(res.deleted  );
                  tmpFileArray = tmpFileArray.concat(res.modified );
                  tmpFileArray = tmpFileArray.concat(res.not_added);
                  tmpFileArray = tmpFileArray.concat(res.renamed  );

                  if (tmpFileArray.length === 0){
                     def.resolve();
                  }

                  tmpFileArray.forEach(function(row, idx, arr){
                    FilesForAdd.push("@ " + row);

                    if (idx === (arr.length - 1) ) {
                      def.resolve(FilesForAdd);
                    }

                  });
                }
            });


            return def.promise;
        },

        commitAndPush: function commitAndPush(msg, push) {
            var def        = q.defer(),
                revHash    = null,
                resolveDef = function(){
                   def.resolve(revHash);
                }

            this.git.status(function(err, res){
                var FilesForAdd = [];

                this.log.info(this.name, "gitController commitAndPush...");

                if (err){
                    this.log.error(this.name, err);
                    def.reject(err);
                } else {

                    this.log.info(this.name, res);

                    FilesForAdd = FilesForAdd.concat(res.created  );
                    FilesForAdd = FilesForAdd.concat(res.deleted  );
                    FilesForAdd = FilesForAdd.concat(res.modified );
                    FilesForAdd = FilesForAdd.concat(res.not_added);
                    FilesForAdd = FilesForAdd.concat(res.renamed  );

                    if (FilesForAdd.length === 0){
                      resolveDef();
                    }

                    this.log.info(this.name, FilesForAdd);
                

                    this.git.add(FilesForAdd, function(){
                        this.git.commit(msg, function(err, commitSum){
                            if (err){
                                this.log.error(this.name, err);
                                def.reject(err);
                            } else {
                                revHash = commitSum.commit;
                                if (push === true) {
                                    this.git.push(resolveDef);
                                } else {
                                    resolveDef();
                                }
                            }
                        }.bind(this));
                    }.bind(this));
                }

            }.bind(this));

            return def.promise;
        }
    };

})();
