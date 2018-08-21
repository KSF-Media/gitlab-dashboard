'use strict';

const realpath = require('fs').realpath;

const inspectWithKind = require('inspect-with-kind');
const isPlainObj = require('is-plain-obj');
const which = require('which');

const TYPE_ERROR = 'Expected an executable name inside the PATH (<string>)';
const OPTION_ERROR = 'Expected an option object to be passed to `node-which` https://www.npmjs.com/package/which (`null` by default)';

module.exports = function realExecutablePathCallback(cmd, options, cb) {
	if (typeof cmd !== 'string') {
		throw new TypeError(`${TYPE_ERROR}, but got a non-string value ${inspectWithKind(cmd)}.`);
	}

	if (cmd.length === 0) {
		throw new Error(`${TYPE_ERROR.replace(' (<string>)', '')}, but got '' (empty string).`);
	}

	if (cb === undefined) {
		cb = options;
		options = {};
	} else if (options) {
		if (!isPlainObj(options)) {
			throw new TypeError(`${OPTION_ERROR}, but got ${inspectWithKind(options)}.`);
		}

		if (options.all) {
			throw new Error('`all` option is not supported.');
		}
	} else {
		options = {};
	}

	if (typeof cb !== 'function') {
		throw new TypeError(`Expected a callback function, but got ${inspectWithKind(cb)}.`);
	}

	which(cmd, options, (err, resolvedPaths) => {
		if (err) {
			cb(err);
			return;
		}

		realpath(resolvedPaths, cb);
	});
};
