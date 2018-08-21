'use strict';

const join = require('path').join;

const path = process.env.npm_execpath;

if (typeof path === 'string' && path.indexOf(join('node_modules', 'npm')) !== -1) {
	module.exports = path;
} else {
	module.exports = null;
}
