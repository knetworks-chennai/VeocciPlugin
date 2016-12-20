var exec = require('cordova/exec');

exports.addPolygon = function(arg0, success, error) {
    exec(success, error, "RIWS", "addPolygon", [arg0]);
};

exports.clearPolygon = function(arg0, success, error) {
    exec(success, error, "RIWS", "clearPolygon", [arg0]);
};

exports.RIWSAlert = function(arg0, success, error) {
    exec(success, error, "RIWS", "RIWSAlert", [arg0]);
};
