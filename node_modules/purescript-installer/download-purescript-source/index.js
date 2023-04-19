'use strict';

const util = require('util');
const {extname, basename, join, sep} = require('path');

const dlTar = require('../dl-tar/index.js');
const isPlainObj = require('is-plain-obj');
const Observable = require('zen-observable');

const BASE_URL = 'https://github.com/purescript/purescript/archive/';
const DEFAULT_REV = 'v0.12.5';
const REV_ERROR = `Expected \`revision\` option to be a string of PureScript version or commit hash, for exmaple '${DEFAULT_REV}' and 'ee2fcf'`;

const ignoredExtensions = new Set([
	'.md',
	'.yml'
]);

const ignoredDirectoryNames = [
	'appveyor',
	'psc-ide',
	'travis'
];

const ignoredFilenames = new Set([
	'.gitignore',
	'logo.png',
	'make_release_notes'
]);

const defaultOptions = {
	filter(_, {header: {path}}) {
		if (ignoredExtensions.has(extname(path))) {
			return false;
		}

		const [topLevelDir] = path.split(sep);

		for (const ignoredDir of ignoredDirectoryNames) {
			if (path.startsWith(join(topLevelDir, ignoredDir))) {
				return false;
			}
		}

		return !ignoredFilenames.has(basename(path));
	},
	baseUrl: BASE_URL
};

module.exports = function downloadPurescriptSource(...args) {
	const argLen = args.length;

	if (argLen !== 1 && argLen !== 2) {
		return new Observable(observer => {
			observer.error(new RangeError(`Expected 1 or 2 arguments (<string>[, <Object>]), but got ${
				argLen === 0 ? 'no' : argLen
			} arguments.`));
		});
	}

	const [dir, options] = args;

	if (typeof dir !== 'string') {
		return new Observable(observer => {
			observer.error(new TypeError(`Expected a directory path where PureScript source will be extracted, but got a non-string value ${
				util.inspect(dir)
			}.`));
		});
	}

	if (argLen === 1) {
		return dlTar(`${DEFAULT_REV}.tar.gz`, dir, defaultOptions);
	}

	if (!isPlainObj(options)) {
		return new Observable(observer => {
			observer.error(new TypeError(`Expected download-purescript-source option to be an object, but got ${
				util.inspect(options)
			}.`));
		});
	}

	const rev = options.revision;

	if (rev !== undefined) {
		if (typeof rev !== 'string') {
			return new Observable(observer => {
				observer.error(new TypeError(`${REV_ERROR}, but got a non-string value ${util.inspect(rev)}.`));
			});
		}

		if (rev.length === 0) {
			return new Observable(observer => {
				observer.error(new Error(`${REV_ERROR}, but got '' (empty string).`));
			});
		}
	}

	if (options.strip !== undefined && options.strip !== 1) {
		return new Observable(observer => {
			observer.error(new Error(`\`strip\` option is unchangeable, but ${
				util.inspect(options.strip)
			} was provided.`));
		});
	}

	return dlTar(`${rev || DEFAULT_REV}.tar.gz`, dir, {...defaultOptions, ...options});
};

Object.defineProperty(module.exports, 'defaultRevision', {
	enumerable: true,
	value: DEFAULT_REV
});
