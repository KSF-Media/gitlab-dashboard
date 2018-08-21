'use strict';

var fs = require('fs');

module.exports = function isDir(path, cb){
  if(!cb)return isDirSync(path);

  fs.stat(path, function(err, stats){
    if(err)return cb(err);
    return cb(null, stats.isDirectory());
  });
};

module.exports.sync = isDirSync;

function isDirSync(path){
  return fs.existsSync(path) && fs.statSync(path).isDirectory();
}
