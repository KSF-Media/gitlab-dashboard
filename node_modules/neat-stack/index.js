'use strict';

const {inspect} = require('util');

const {dim, red} = require('chalk');
const cleanStack = require('clean-stack');

module.exports = function neatStack(...args) {
	if (args.length !== 1) {
		throw new RangeError(`Expected 1 argument, but got ${args.length || 'no'} arguments.`);
	}

	const [error] = args;
	const option = {pretty: process.platform !== 'win32'};

	if (typeof error === 'string') {
		return red(cleanStack(error, option));
	}

	if (error === null || typeof error !== 'object' || typeof error.stack !== 'string') {
		return red(inspect(error));
	}

	const title = error.toString();
	const stack = cleanStack(error.stack, option);

	if (!stack.startsWith(title)) {
		return red(stack);
	}

	return red(`${title}${dim(cleanStack(error.stack, option).slice(title.length))}`);
};
