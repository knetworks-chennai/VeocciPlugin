var exec = require('cordova/exec');

exports.addPolygon = function(success, error, replaceifexist, polygon) {
    exec(success, error, "RIWS", "addPolygon", [replaceifexist, polygon]);
};

exports.removePolygon = function(success, error, polygon) {
    exec(success, error, "RIWS", "removePolygon", [polygon]);
};

exports.removeAll = function(success, error) {
    exec(success, error, "RIWS", "removeAll", []);
};

exports.initRIWS = function(onRunwayIncursion, onEndRunwayIncursion, error) {
    exec(onRunwayIncursion, onEndRunwayIncursion, "RIWS", "initRIWS", [error]);
};
