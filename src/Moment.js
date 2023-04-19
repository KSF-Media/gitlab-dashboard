"use strict";

export function formatTime_(milliseconds) {
  return moment("2015-01-01")
    .startOf('day')
    .milliseconds(milliseconds)
    .format('HH:mm:ss');
};

export function fromNow_(jsDate) {
  return moment(jsDate).fromNow();
};
