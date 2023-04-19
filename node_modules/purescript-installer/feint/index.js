'use strict';

const util = require('util');

module.exports = function createFeintFunction(fn) {
	if (typeof fn !== 'function') {
		throw new TypeError('Expected a function, but got ' + util.inspect(fn) + '.');
	}

	var called = false;

	return function feint() {
		if (!called) {
			called = true;
			return undefined;
		}

		return fn.apply(this, arguments);
	};
}
