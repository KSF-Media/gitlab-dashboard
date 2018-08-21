/*!
 * load-from-cwd-or-npm | MIT (c) Shinnosuke Watanabe
 * https://github.com/shinnn/load-from-cwd-or-npm
*/
'use strict';

const path = require('path');

const inspectWithKind = require('inspect-with-kind');
const npmCliDir = require('npm-cli-dir');
const optional = require('optional');
const resolveFromNpm = require('resolve-from-npm');

const MODULE_ID_ERROR = 'Expected a string of npm package name, for example `glob`, `graceful-fs`';
const resolveSemverFromNpm = resolveFromNpm('semver');

function createModuleNotFoundRejection(moduleId, cwd, npmCliDirPath) {
	const error = new Error(`Failed to load "${
		moduleId
	}" module from the current working directory (${
		cwd
	}).${npmCliDirPath ? ` Then tried to load "${
		moduleId
	}" from the npm CLI directory (${
		npmCliDirPath
	}), but it also failed.` : ''} Install "${moduleId}" and try again. (\`npm install ${moduleId}\`)`);

	error.code = 'MODULE_NOT_FOUND';
	error.id = moduleId;
	error.triedPaths = {cwd};

	if (npmCliDirPath) {
		error.triedPaths.npm = npmCliDirPath;
		error.npmVersion = require(path.join(npmCliDirPath, './package.json')).version;
	}

	return Promise.reject(error);
}

module.exports = function loadFromCwdOrNpm(moduleId, compareFn) {
	if (typeof moduleId !== 'string') {
		return Promise.reject(new TypeError(`${MODULE_ID_ERROR}, but got ${inspectWithKind(moduleId)}.`));
	}

	if (moduleId.length === 0) {
		return Promise.reject(new Error(`${MODULE_ID_ERROR}, but got '' (empty string).`));
	}

	if (moduleId.charAt(0) === '@') {
		return new Promise(resolve => resolve(require(moduleId)));
	}

	if (moduleId.indexOf('/') !== -1 || moduleId.indexOf('\\') !== -1) {
		return Promise.reject(new Error(`"${
			moduleId
		}" includes path separator(s). The string must be an npm package name, for example \`request\` \`semver\`.`));
	}

	if (compareFn && typeof compareFn !== 'function') {
		return Promise.reject(new TypeError(`Expected a function to compare two package versions, but got ${
			inspectWithKind(compareFn)
		}.`));
	}

	const modulePkgId = `${moduleId}/package.json`;
	const tasks = [resolveFromNpm(modulePkgId)];

	if (!compareFn) {
		tasks.push(resolveSemverFromNpm);
	}

	const cwd = process.cwd();

	return Promise.all(tasks).then(function chooseOneModuleFromCwdAndNpm(results) {
		const packageJsonPathFromNpm = results[0];

		if (!compareFn) {
			compareFn = require(results[1]).gte;
		}

		if (compareFn((optional(modulePkgId) || {version: '0.0.0-0'}).version, require(packageJsonPathFromNpm).version)) {
			const result = optional(moduleId);

			if (result !== null) {
				return result;
			}
		}

		return require(path.dirname(packageJsonPathFromNpm));
	}, function fallbackToCwd() {
		const result = optional(moduleId);

		if (result === null) {
			return npmCliDir().then(npmCliDirPath => createModuleNotFoundRejection(moduleId, cwd, npmCliDirPath), () => createModuleNotFoundRejection(moduleId, cwd, null));
		}

		return result;
	});
};
