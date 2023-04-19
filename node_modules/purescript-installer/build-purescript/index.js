'use strict';

const {basename, join, resolve} = require('path');
const {mkdtemp, stat} = require('fs');
const osTmpdir = require('os').tmpdir;
const util = require('util');

const feint = require('../feint/index.js');
const isPlainObj = require('is-plain-obj');
const Observable = require('zen-observable');
const once = require('once');
const rimraf = require('rimraf');
const spawnStack = require('../spawn-stack/index.js');

const downloadPurescriptSource = require('../download-purescript-source/index.js');

const ARGS_ERROR = 'Expected `args` option to be an array of user defined arguments passed to `stack setup` and `stack install`';
const buildOnlyArgs = new Set([
	'--dry-run',
	'--pedantic',
	'--fast',
	'--only-snapshot',
	'--only-dependencies',
	'--only-configure',
	'--trace',
	'--profile',
	'--no-strip',
	'--coverage',
	'--no-run-tests',
	'--no-run-benchmarks'
]);
const binName = `purs${process.platform === 'win32' ? '.exe' : ''}`;
const negligibleLineRe = /^WARNING: (?:filepath wildcard|(?:File|Directory) listed|Installation path|Specified pattern) .*/ui;

function isLocalBinPathFlag(flag) {
	return flag.startsWith('--local-bin-path');
}

module.exports = function buildPurescript(...args) {
	return new Observable(observer => {
		const argLen = args.length;

		if (argLen > 1) {
			const error = new RangeError(`Expected 0 or 1 argument ([<Object>]), but got ${argLen} arguments.`);
			error.code = 'ERR_TOO_MANY_ARGS';

			throw error;
		}

		const [options = {}] = args;

		if (argLen === 1) {
			if (!isPlainObj(options)) {
				throw new TypeError(`Expected build-purescript option to be an object, but got ${
					util.inspect(options)
				}.`);
			}

			// to validate download-purescript-source arguments beforehand
			const tmpSumscription = downloadPurescriptSource(__dirname, options).subscribe({
				error(err) {
					observer.error(err);
				}
			});
			setImmediate(() => tmpSumscription.unsubscribe());

			if (options.cwd !== undefined) {
				throw new Error(`build-purescript doesn't support \`cwd\` option, but ${
					util.inspect(options.cwd)
				} was provided.`);
			}

			if (options.args !== undefined) {
				if (!Array.isArray(options.args)) {
					throw new TypeError(`${ARGS_ERROR}, but got a non-array value ${
						util.inspect(options.args)
					}.`);
				}
			}
		}

		const subscriptions = new Set();
		const installArgs = [
			'install',
			`--local-bin-path=${process.cwd()}`,
			'--flag=purescript:RELEASE'
		];
		const defaultArgs = options.args ? options.args.filter(arg => {
			if (buildOnlyArgs.has(arg)) {
				installArgs.push(arg);
				return false;
			}

			return true;
		}) : [];

		if (defaultArgs.some(isLocalBinPathFlag)) {
			const error = new Error('`--local-bin-path` flag of the `stack` command is not configurable, but provided for `args` option.');
			error.code = 'ERR_INVALID_OPT_VALUE';

			throw error;
		}

		const spawnOptions = {cwd: null, ...options};
		const cleanupSourceDir = (cb = () => {}) => spawnOptions.cwd ? rimraf(spawnOptions.cwd, {glob: false}, cb) : cb();

		const sendError = once((err, id) => {
			if (id) {
				Object.defineProperty(err, 'id', {
					value: id,
					configurable: true,
					writable: true
				});
			}

			cleanupSourceDir(() => observer.error(err));
		});

		const setupArgs = [...defaultArgs, 'setup'];
		const setupCommand = `stack ${setupArgs.join(' ')}`;
		const buildArgs = [...defaultArgs, ...installArgs];
		const buildCommand = `stack ${buildArgs.join(' ')}`;

		const startBuildOnReady = feint(() => {
			subscriptions.add(Observable.from(spawnStack(buildArgs, spawnOptions)).subscribe({
				next(line) {
					if (negligibleLineRe.test(line)) {
						return;
					}

					observer.next({
						id: 'build',
						command: buildCommand,
						output: line
					});
				},
				error(err) {
					const negligibleMultiLineRe = new RegExp(`${negligibleLineRe.source}\\n\\r?`, 'ugim');

					err.message = err.message.replace(negligibleMultiLineRe, '');
					err.stack = err.stack.replace(negligibleMultiLineRe, '');

					sendError(err, 'build');
				},
				complete() {
					cleanupSourceDir(() => {
						observer.next({id: 'build:complete'});
						observer.complete();
					});
				}
			}));
		});

		const setup = once(() => {
			subscriptions.add(Observable.from(spawnStack(setupArgs, spawnOptions))
			.subscribe({
				next(line) {
					observer.next({
						id: 'setup',
						command: setupCommand,
						output: line
					});
				},
				error(err) {
					sendError(err, 'setup');
				},
				complete() {
					observer.next({id: 'setup:complete'});
					startBuildOnReady();
				}
			}));
		});

		const binPath = resolve(binName);

		stat(resolve(binName), (err, stats) => {
			if (observer.closed || err || !stats.isDirectory()) {
				return;
			}

			const error = new Error(`Tried to create a PureScript binary at ${binPath}, but a directory already exists there.`);

			error.code = 'EISDIR';
			sendError(error);
		});

		mkdtemp(join(osTmpdir(), 'node-purescript-'), (err, tmpDir) => {
			if (err) {
				sendError(err);
				return;
			}

			spawnOptions.cwd = tmpDir;

			if (observer.closed) {
				cleanupSourceDir();
				return;
			}

			const download = downloadPurescriptSource(tmpDir, options)
			.subscribe({
				next(progress) {
					progress.id = 'download';
					observer.next(progress);

					const {remain, header: {path}} = progress.entry;

					if (remain === 0 && basename(path) === 'stack.yaml') {
						setup();
					}
				},
				error(downloadErr) {
					sendError(downloadErr, 'download');
				},
				complete() {
					setup();
					observer.next({id: 'download:complete'});
					startBuildOnReady();
				}
			});

			subscriptions.add(download);
		});

		return function cancelBuild() {
			for (const subscription of subscriptions) {
				subscription.unsubscribe();
			}
		};
	});
};

Object.defineProperty(module.exports, 'supportedBuildFlags', {
	value: buildOnlyArgs,
	enumerable: true
});
