'use strict';

const realExecutablePathCallback = require('real-executable-path-callback');

module.exports = function realExecutablePath(executableName, options) {
	return new Promise((resolve, reject) => {
		realExecutablePathCallback(executableName, options, (err, filePath) => {
			if (err) {
				reject(err);
				return;
			}

			resolve(filePath);
		});
	});
};
