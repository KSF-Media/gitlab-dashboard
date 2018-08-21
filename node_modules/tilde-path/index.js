'use strict';

const homedir = require('os').homedir;
const pathLib = require('path');

const win32Resolve = pathLib.win32.resolve;
const posixResolve = pathLib.posix.resolve;

module.exports = function tildePath(path) {
  if (process.platform === 'win32') {
    return win32Resolve(path);
  }

  const home = homedir();
  path = posixResolve(path);

  if (path === home) {
    return '~';
  }

  const homeWithTrailingSlash = `${home}/`;

  if (path.startsWith(homeWithTrailingSlash)) {
    return path.replace(homeWithTrailingSlash, '~/');
  }

  return path;
};
