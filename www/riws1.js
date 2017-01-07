var exec = require('cordova/exec');

exports.addPolygon = function(success, error, replaceifexist, polygon, polygonguid) {
    exec(success, error, "RIWS", "addPolygon", [replaceifexist, polygon, polygonguid]);
};

exports.removePolygon = function(success, error, polygonguid) {
    exec(success, error, "RIWS", "removePolygon", [polygonguid]);
};

exports.removeAll = function(success, error) {
    exec(success, error, "RIWS", "removeAll", []);
};

exports.initRIWS = function(onRunwayIncursion, onEndRunwayIncursion, error) {
    exec(onRunwayIncursion, onEndRunwayIncursion, "RIWS", "initRIWS", [error]);
};
