'use strict';

const rateMap = require('rate-map');

const contents = ['⠀', '⣀', '⣤', '⣶', '⣿'];
const MAX = contents.length - 1;

module.exports = function verticalMeter(...args) {
	if (args.length !== 1) {
		throw new RangeError(`Expected 1 argument (<number>), but got ${args.length || 'no'} arguments.`);
	}

	return contents[Math.round(rateMap(args[0], 0, MAX))];
};
