'use strict';

const util = require('util');
const byline = require('byline');
const execa = require('execa');
const Observable = require('zen-observable');

const HASHES = new Map([
	['darwin', 'macos'],
	['freebsd', 'freebsd'],
	['linux', 'linux'],
	['win32', 'windows']
]);

module.exports = function spawnStack(...args) {
	const argLen = args.length;

	if (argLen !== 1 && argLen !== 2) {
		return Promise.reject(new RangeError(`Expected 1 or 2 arguments (<Array<string>[, <Object>]), but got ${
			argLen === 0 ? 'no' : argLen
		} arguments.`));
	}

	let [stackArgs] = args;

	if (!Array.isArray(stackArgs)) {
		return Promise.reject(new TypeError(`Expected arguments of \`stack\` command (Array<string>), but got a non-array value ${
			util.inspect(stackArgs)
		}.`));
	}

	if (
		process.platform !== 'win32' &&
		!stackArgs.includes('--allow-different-user') &&
		!stackArgs.includes('--no-allow-different-user')
	) {
		stackArgs = ['--allow-different-user'].concat(stackArgs);
	}

	const lines = [];
	let completed = false;
	let error;

	let observer = {
		next(line) {
			lines.push(line);
		},
		error(err) {
			error = err;
		},
		complete() {
			completed = true;
		}
	};

	const cp = execa('stack', stackArgs, {preferLocal: false, ...args[1]});
	cp.stderr.setEncoding('utf8');

	byline(cp.stderr).on('data', line => observer.next(line));

	cp.then(data => { // eslint-disable-line promise/prefer-await-to-then
		observer.complete();
		return data;
	}, err => {
		if (err.code === 'ENOENT') {
			const hash = HASHES.get(process.platform);

			err.INSTALL_URL = `https://docs.haskellstack.org/en/stable/install_and_upgrade/${
				hash ? `#${hash}` : ''
			}`;

			err.message = `\`stack\` command is not found in your PATH. Make sure you have installed Stack. ${
				err.INSTALL_URL
			}`;
		}

		if (err.killed) {
			return;
		}

		observer.error(err);
	});

	cp[Symbol.observable] = () => new Observable(observerArg => { // eslint-disable-line no-use-extend-native/no-use-extend-native
		observer = observerArg;

		for (const line of lines) {
			observer.next(line);
		}

		if (error !== undefined) {
			observer.error(error);
		} else if (completed) {
			observer.complete();
		}

		return function killStack() {
			if (completed) {
				return;
			}

			cp.kill();
		};
	});

	return cp;
};
