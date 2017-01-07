var exec = require('cordova/exec');

exports.addPolygon = function(success, error, replaceifexist, coordinates, polygonguid, polygonname) {
    exec(success, error, "RIWS", "addPolygon", [replaceifexist, coordinates, polygonguid, polygonname]);
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
