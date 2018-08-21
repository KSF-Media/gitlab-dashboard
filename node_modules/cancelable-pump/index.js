'use strict';

const pump = require('pump');

const cancel = new Error('Canceled.');

module.exports = function cancelablePump(...args) {
	if (args.length === 0) {
		throw new RangeError('Expected at least 1 argument, but got no arguments.');
	}

	const nonCallbackArgs = args;
	const callback = typeof nonCallbackArgs[nonCallbackArgs.length - 1] === 'function' ?
		nonCallbackArgs.pop() :
		null;

	const streams = Array.isArray(args[0]) ? args[0] : nonCallbackArgs;
	const streamCount = streams.length;

	if (streamCount < 2) {
		throw new RangeError(`cancelable-pump requires more than 2 streams, but got ${streamCount}.`);
	}

	pump(streams, err => {
		if (!callback) {
			return;
		}

		if (err && err !== cancel) {
			callback(err);
			return;
		}

		callback();
	});

	return function cancelStreams() {
		streams[streamCount - 1].emit('error', cancel);
	};
};

