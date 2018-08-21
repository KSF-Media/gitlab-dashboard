'use strict';

const {promisify} = require('util');

const isActualContent = require('junk').not;
const {readdir} = require('graceful-fs');

const promisifiedReaddir = promisify(readdir);

module.exports = async function readdirClean(...args) {
  const argLen = args.length;

  if (argLen !== 1) {
    throw new RangeError(`Expected 1 argument (<string|Buffer|URL>), but got ${
      argLen === 0 ? 'no' : argLen
    } arguments instead.`);
  }

  return (await promisifiedReaddir(args[0])).filter(isActualContent);
};
