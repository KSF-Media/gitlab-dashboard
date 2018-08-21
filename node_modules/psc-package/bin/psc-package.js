#!/usr/bin/env node
'use strict';

const spawn = require('child_process').spawn;

const child = spawn(require('../'), process.argv.slice(2), {stdio: 'inherit'});
child.on('exit', process.exit);
process.on('SIGINT', () => {
  child.kill('SIGINT');
});
process.on('SIGTERM', () => {
  child.kill();
});
