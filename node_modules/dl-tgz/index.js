'use strict';

const {createGunzip} = require('zlib');

const dlTar = require('dl-tar');
const isPlainObj = require('is-plain-obj');
const Observable = require('zen-observable');

module.exports = function dlTgz(...args) {
	const argLen = args.length;

	if (argLen !== 2 && argLen !== 3) {
		return new Observable(observer => {
			observer.error(new RangeError(`Expected 2 or 3 arguments (<string>, <string>[, <Object>]), but got ${
				argLen === 0 ? 'no' : argLen
			} arguments.`));
		});
	}

	const [url, dest, options] = args;

	if (isPlainObj(options)) {
		if (options.tarTransform !== undefined) {
			return new Observable(observer => {
				observer.error(new TypeError('dl-tgz doesn\'t support `tarTransform` option.'));
			});
		}

		return dlTar(url, dest, Object.assign({}, options, {tarTransform: createGunzip()}));
	}

	return dlTar(url, dest, options || {tarTransform: createGunzip()});
};
