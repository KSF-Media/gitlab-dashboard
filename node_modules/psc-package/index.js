'use strict';

const path = require('path');

const toExecutableName = require('to-executable-name');

module.exports = path.join(__dirname, 'vendor', toExecutableName('psc-package'));
