var exec = require('cordova/exec');

function FirebaseAuth(options) {

    options = options || {};
    var allowDomains = options.allowDomains ? [].concat(options.allowDomains) : null;
    exec(dispatchEvent, null, 'FirebasePhoneAuthPlugin', 'initialize', [allowDomains]);

    this.getToken = function(success, failure) {

        if(window.Promise) {
            return new Promise(function (resolve, reject) {

                exec(resolve, reject, 'FirebaseAuthPlugin', 'getToken', []);
            });
        } else {
            return exec(success, failure, 'FirebaseAuthPlugin', 'getToken', []);
        }
    };

    this.sendSMS = function () {

        return exec(null, null, 'FirebaseAuthPlugin', 'sendSMS', []);
    };
    
    this.verifyCode = function () {

        return exec(null, null, 'FirebaseAuthPlugin', 'verifyCode', []);
    };

    this.signOut = function () {

        return exec(null, null, 'FirebaseAuthPlugin', 'signOut', []);
    };

    function dispatchEvent(event) {

        window.dispatchEvent(new CustomEvent(event.type, {detail: event.data}));
    }
}

if (typeof module !== undefined && module.exports) {

    module.exports = FirebaseAuth;
}