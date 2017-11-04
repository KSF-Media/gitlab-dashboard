"use strict";

exports.formatTime_ = function(milliseconds) {
  return moment("2015-01-01")
    .startOf('day')
    .milliseconds(milliseconds)
    .format('HH:mm:ss');
};

exports.fromNow_ = function(jsDate) {
  return moment(jsDate).fromNow();
};
