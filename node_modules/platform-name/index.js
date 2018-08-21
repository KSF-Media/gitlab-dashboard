'use strict';

const {inspect} = require('util');

const inspectWithKind = require('inspect-with-kind');

const map = new Map([
	['aix', 'AIX'],
	['android', 'Android'],
	['darwin', 'macOS'],
	['freebsd', 'FreeBSD'],
	['linux', 'Linux'],
	['openbsd', 'OpenBSD'],
	['sunos', 'Solaris'],
	['win32', 'Windows']
]);

const ERR = 'Expected a string one of \'aix\', \'android\', \'darwin\', \'freebsd\', \'linux\', \'openbsd\', \'sunos\' and \'win32\'';

module.exports = function platformName(...args) {
	const argLen = args.length;

	if (argLen === 0) {
		return map.get(process.platform);
	}

	if (argLen !== 1) {
		throw new RangeError(`Expected 0 or 1 argument ([<string>]), but got ${argLen} arguments.`);
	}

	const [id] = args;

	if (typeof id !== 'string') {
		throw new TypeError(`${ERR}, but got a non-string value ${inspectWithKind(id)}.`);
	}

	const result = map.get(id);

	if (!result) {
		throw new RangeError(`${ERR}, but got ${id.length === 0 ? '\'\' (empty string)' : inspect(id)}.`);
	}

	return result;
};

Object.defineProperty(module.exports, 'map', {
	value: map,
	enumerable: true
});
