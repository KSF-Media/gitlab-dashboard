'use strict';

const inspectWithKind = require('inspect-with-kind');
const termSize = require('term-size');
const stringWidth = require('string-width');
const wrapAnsi = require('wrap-ansi');

const wrapAnsiOption = {hard: true};

module.exports = function neatFrame(...args) {
	const argLen = args.length;

	if (argLen !== 1) {
		throw new RangeError(`Expected 1 argument (string), but got ${argLen || 'no'} arguments instead.`);
	}

	const [str] = args;

	if (typeof str !== 'string') {
		throw new TypeError(`Expected a string to be framed with box-drawing characters, but got ${
			inspectWithKind(str)
		}.`);
	}

	// '  ┌'.length + '┐  '.length === 6
	const contentWidth = termSize().columns - 6;

	const padding = `  │${' '.repeat(contentWidth)}│`;
	const verticalBar = '─'.repeat(contentWidth);

	return `  ┌${verticalBar}┐
${padding}
${wrapAnsi(str, contentWidth - 2, wrapAnsiOption).split(/\r?\n/).map(line => `  │ ${line}${
		' '.repeat(Math.max(contentWidth - 2 - stringWidth(line), 0))
	} │`).join('\n')}
${padding}
  └${verticalBar}┘`;
};
