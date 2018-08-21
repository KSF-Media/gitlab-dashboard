'use strict';

const exec = require('child_process').exec;
const lstat = require('fs').lstat;
const path = require('path');

if (process.platform !== 'win32') {
	module.exports = function winUserInstalledNpmCliPath() {
		return Promise.reject(new Error('Only supported in Windows.'));
	};
} else {
	const getNpmPrefix = new Promise(function executor(resolve, reject) {
		// https://github.com/npm/npm/blob/v5.6.0/bin/npm.cmd
		// https://github.com/npm/npm/pull/9089
		exec('npm prefix -g', (err, stdout) => {
			if (err) {
				reject(err);
				return;
			}

			resolve(stdout.trim());
		});
	});

	module.exports = function winUserInstalledNpmCliPath() {
		return getNpmPrefix.then(npmPrefix => new Promise(function executor(resolve, reject) {
			const expectedPath = path.join(npmPrefix, 'node_modules\\npm\\bin\\npm-cli.js');

			lstat(expectedPath, function lstatCallback(err, stat) {
				if (err) {
					reject(err);
					return;
				}

				if (!stat.isFile()) {
					reject(new Error(`${expectedPath} exists, but it's not a file.`));
					return;
				}

				resolve(expectedPath);
			});
		}));
	};
}
