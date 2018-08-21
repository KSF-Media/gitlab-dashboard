'use strict';

const pathLib = require('path');

const dirname = pathLib.dirname;
const join = pathLib.join;
const parse = pathLib.parse;

const npmCliPath = require('npm-cli-path');

const getNpmCliDir = npmCliPath().then(result => {
	const path = parse(result);
	const root = path.root;
	result = path.dir;

	do {
		try {
			require.resolve(join(result, 'package.json'));
			break;
		} catch (_) {
			result = dirname(result);
		}
	} while (result !== root);

	return result;
});

module.exports = function npmCliDir() {
	return getNpmCliDir;
};
