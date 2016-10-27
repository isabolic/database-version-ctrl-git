(function() {
    const winston = require('winston');
    const mkdirp = require('mkdirp');


    var wiLogger = new(winston.Logger)({
        transports: [
            new(winston.transports.File)({
                name: 'info-file',
                filename: 'logs/filelog-info.log',
                level: 'info'
            }),
            new(winston.transports.File)({
                name: 'error-file',
                filename: 'logs/filelog-error.log',
                level: 'error'
            })
        ]
    });

    /**
     * [logger constructor]
     * @return {logger}
     */
    logger = function() {
        this.init = function() {
            mkdirp('logs', function(err) {
                if (err) {
                    logger.log('error', logger.name, err);
                }
            });
            return this;
        }

        return this.init();
    }

    /**
     * [logger constructor PUBLIC API methods]
     */
    logger.prototype = {
        /**
         * [info log info]
         * @param  {String} reference
         * @param  {String} msg
         */
        info: function info(reference, msg) {
            wiLogger.log('info', reference, msg);
        },

        /**
         * [error log error]
         * @param  {String} reference
         * @param  {String} msg
         */
        error: function error(reference, msg) {
            wiLogger.log('error', reference, msg);
        }
    };

})();
