'use strict';
// const
const express = require('express');
const q       = require('q');
const ddl     = require('./oracle.ddl.js');
const gitCtrl = require('./git.controller.js');
const CLog    = require('./logger.js');
const cfg     = require('./util.js');
const PORT    = 9090;
const app     = express();
const jsName  = "index";
// gl. var
var  gitPath       = null;
var  changeLogLoc  = null;
var  httpServer    = null;
var  log           = null;


var setResponseDef = function (res, objecRes){
    res.setHeader('Content-Type', 'application/json');
    res.set("Connection", "close");
    if (objecRes){
        res.send(JSON.stringify(objecRes));
    }
}


var userIsReq = function (user, res){
    if (!user){
        setResponseDef(res, {successful:false, msg:"User is required."});
    }

    return user;
};

var errorHandler = function (err) {
    log.error(jsName, err);
}

var saveToVersionCtrl = function (commitMsg, user, res){
        var ddl, gitC;

        gitC = new gitController({rootFolder:gitPath});
        log.info(jsName, "saveToVersionCtrl.... call...");

        gitC.pull()
            .fail(errorHandler)
            .done(function(){
                log.info(jsName, "git pull.... done...");
                ddl = new oracleDDL({
                    user       : user,
                    rootFolder : gitPath
                });

                ddl.getDefer()
                    .fail(errorHandler)
                    .done(function() {

                        gitC.getListOfChangedFiles()
                            .fail(errorHandler)
                            .done(function(listOfFIlesForCommit){
                                log.info(jsName, "get db changes..  done...");

                                if(listOfFIlesForCommit === undefined){

                                    log.info(jsName, "there is no file for git commit.. end servise request...");

                                    ddl.setRevisionOnDB(null)
                                       .fail(errorHandler)
                                       .done(function(){
                                            log.info(jsName, "setRevision hash on database... done...");
                                            setResponseDef(res, {successful:true});
                                       });

                                    return;
                                }

                                if(commitMsg === undefined){
                                    commitMsg  = '@' + user + "\n" + "\n";
                                    commitMsg += listOfFIlesForCommit.join("\n");
                                } else {
                                    commitMsg  = '@' + user + "\n" + "\n" + commitMsg;
                                };

                                log.info(jsName, "list of includes for CL... : " + listOfFIlesForCommit.join());
                                util.saveToCL(changeLogLoc, listOfFIlesForCommit)
                                    .fail(errorHandler)
                                    .done(function (){

                                        log.info(jsName, "write to CL ... done...");
                                        gitC.commitAndPush(commitMsg, true)
                                            .fail(errorHandler)
                                            .done(function(revHash){
                                            log.info(jsName, "git commit and push ... done...");

                                            ddl.setRevisionOnDB(revHash)
                                               .fail(errorHandler)
                                               .done(function(){
                                                    log.info(jsName, "setRevision hash on database... done...");
                                                    setResponseDef(res, {successful:true});
                                                });
                                        });
                                    });
                            });


                    });
            });
}


app.get('/saveToVersionCtrl', function(req, res) {
    var comMsg = req.query.commitMsg,
        user   = userIsReq(req.query.user, res),
        debug  = typeof v8debug === 'object',
        intId;

    if(!user){
        return;
    }

    var checkIfSingleConn = function(){
        // check current number of request on server, if there more then one
        // delay the current until one is finished.. the reason for this is fs directory..
        // there can be only one git commit at the time, preserve the commit user
        util.getNumberOfhttpConnection(httpServer).done(function(nOfCon){
             // if only one, and that is current requst
             // if you using node.js debug mode allow req.
            if (nOfCon === 1 || debug){
                saveToVersionCtrl(comMsg, user, res);
                clearInterval(intId);
            }else{
                log.info("There is a request currently running... delaying this request...");
            }
        });
    }
    intId = setInterval(checkIfSingleConn, 3000);
});


app.listen(PORT, function () {
    var promGitPath = util.loadGitPath(),
        promCLPath  = util.loadCLlocation();

    log = new logger();
    httpServer = this;
    console.log(jsName, "app is running  at port " + PORT);

    promGitPath.done(function (path){
      log.info(jsName,"path :  " + path);
      gitPath = path;
    });

    promCLPath.done(function (clLoc){
      log.info(jsName, "CL location is :  " + clLoc);
      changeLogLoc = clLoc;
    });

});

