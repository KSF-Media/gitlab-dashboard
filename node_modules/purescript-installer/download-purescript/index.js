'use strict';

const {basename} = require('path');
const {inspect} = require('util');
const semver = require('semver');

const dlTar = require('../dl-tar/index.js');
const getArch = require('arch');
const isPlainObj = require('is-plain-obj');
const Observable = require('zen-observable');

const supportedPlatforms = new Map([
	['linux', 'linux64'],
	['darwin', 'macos'],
	['win32', 'win64']
]);

const unsupportedPlatforms = new Map([
	['aix', 'AIX'],
	['android', 'Android'],
	['freebsd', 'FreeBSD'],
	['openbsd', 'OpenBSD'],
	['sunos', 'Solaris']
]);

const DEFAULT_VERSION = '0.12.5';
const VERSION_ERROR = `Expected \`version\` option to be a string of PureScript version, for example '${DEFAULT_VERSION}'`;
const defaultOptions = {
	filter: function isPurs(filePath) {
		return basename(filePath, '.exe') === 'purs';
	},
	baseUrl: 'https://github.com/purescript/purescript/releases/download/'
};
const arch = getArch();

function createUnsupportedPlatformError() {
	const error = new Error(`Prebuilt \`purs\` binary is not provided for ${
		unsupportedPlatforms.get(process.platform)
	}.`);

	error.code = 'ERR_UNSUPPORTED_PLATFORM';
	Error.captureStackTrace(error, createUnsupportedPlatformError);

	return new Observable(observer => observer.error(error));
}

module.exports = arch === 'x64' ? function downloadPurescript(...args) {
	const argLen = args.length;

	if (argLen === 0) {
		const archiveName = supportedPlatforms.get(process.platform);

		if (!archiveName) {
			return createUnsupportedPlatformError();
		}

		return dlTar(`v${DEFAULT_VERSION}/${archiveName}.tar.gz`, process.cwd(), defaultOptions);
	} else if (argLen !== 1) {
		const error = new RangeError(`Expected 0 or 1 argument ([<Object>]), but got ${argLen} arguments.`);
		error.code = 'ERR_TOO_MANY_ARGS';

		return new Observable(observer => observer.error(error));
	}

	const [options] = args;

	if (!isPlainObj(options)) {
		return new Observable(observer => {
			observer.error(new TypeError(`Expected download-purescript option to be an object, but got ${inspect(options)}.`));
		});
	}

	if (options.followRedirect !== undefined && !options.followRedirect) {
		return new Observable(observer => observer.error(new Error('`followRedirect` option cannot be disabled.')));
	}

	const {version} = options;

	if (version !== DEFAULT_VERSION && version !== undefined) {
		if (typeof version !== 'string') {
			return new Observable(observer => {
				observer.error(new TypeError(`${VERSION_ERROR}, but got a non-string value ${inspect(version)}.`));
			});
		}

		if (version.length === 0) {
			return new Observable(observer => {
				observer.error(new Error(`${
					VERSION_ERROR
				}, but got '' (empty string). If you want to download the default version ${
					DEFAULT_VERSION
				}, you don't need to pass any values to \`version\` option.`));
			});
		}

		if (!semver.valid(version)) {
			return new Observable(observer => {
				observer.error(new Error(`${VERSION_ERROR}, but got an invalid version ${inspect(version)}.`));
			});
		}
	}

	if (!supportedPlatforms.has(process.platform)) {
		return createUnsupportedPlatformError();
	}

	if (options.strip !== undefined && options.strip !== 1) {
		return new Observable(observer => {
			observer.error(new Error(`\`strip\` option is unchangeable, but ${
				inspect(options.strip)
			} was provided.`));
		});
	}

	const url = `v${version || DEFAULT_VERSION}/${supportedPlatforms.get(process.platform)}.tar.gz`;

	return dlTar(url, process.cwd(), {...defaultOptions, ...options});
} : function downloadPurescript() {
	if (!supportedPlatforms.has(process.platform)) {
		return createUnsupportedPlatformError();
	}

	return new Observable(() => {
		const error = new Error('The prebuilt PureScript binaries only support 64-bit architectures, but the current system is not 64-bit.');

		error.code = 'ERR_UNSUPPORTED_ARCH';
		error.currentArch = arch;

		throw error;
	});
};

Object.defineProperty(module.exports, 'defaultVersion', {
	enumerable: true,
	value: DEFAULT_VERSION
});
