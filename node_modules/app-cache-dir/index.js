'use strict';

const {join} = require('path');
const {homedir, tmpdir} = require('os');

const inspectWithKind = require('inspect-with-kind');

const ARG_ERROR = 'Expected an application name to find its cache directory';

function isLocalAppDataKey(key) {
  return key.toUpperCase() === 'LOCALAPPDATA';
}

function validateArgument(appName) {
  if (typeof appName !== 'string') {
    throw new TypeError(`${ARG_ERROR} (string), but got ${inspectWithKind(appName)}.`);
  }

  if (appName.length === 0) {
    throw new Error(`${ARG_ERROR}, but got '' (empty string).`);
  }
}

function fallback(appName) {
  return join(tmpdir(), appName, 'cache');
}

function posixAppCacheDir(appName) {
  validateArgument(appName);

  if (process.env.XDG_CACHE_HOME) {
    return join(process.env.XDG_CACHE_HOME, appName);
  }

  const home = homedir();

  if (home && !home.includes('\0')) {
    return join(home, '.cache', appName);
  }

  return fallback(appName);
}

function win32AppCacheDir(appName) {
  validateArgument(appName);

  const key = Object.keys(process.env).find(isLocalAppDataKey);

  if (key) {
    return join(process.env[key], appName, 'cache');
  }

  return fallback(appName);
}

module.exports = function appCacheDir(appName) {
  if (process.platform === 'win32') {
    return win32AppCacheDir(appName);
  }

  return posixAppCacheDir(appName);
};

module.exports.posix = posixAppCacheDir;
module.exports.win32 = win32AppCacheDir;
