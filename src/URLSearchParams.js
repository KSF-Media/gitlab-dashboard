"use strict";

exports.get = function(paramName) {
  return function() {
    var url = new URL(window.location.toString());
    return url.searchParams.get(paramName) || "null";
  };
};
