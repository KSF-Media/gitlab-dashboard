'use strict';

const filesize = require('filesize');
const inspectWithKind = require('inspect-with-kind');

const formatter = Symbol('formatter');
const round = Symbol('round');
const spacer = Symbol('spacer');

const unsupportedOptions = [
  'exponent',
  'fullform',
  'fullforms',
  'output',
  'suffixes'
];

function validateNumber(num, name) {
  if (typeof num !== 'number') {
    throw new TypeError(`Expected ${name} to be a non-negative number, but got ${
      inspectWithKind(num)
    }.`);
  }

  if (num < 0) {
    throw new RangeError(`Expected ${name} to be a non-negative number, but got a negative value ${num}.`);
  }

  if (!Number.isFinite(num)) {
    throw new RangeError(`Expected ${name} to be a non-negative finite number, but got ${num}.`);
  }

  if (num > Number.MAX_SAFE_INTEGER) {
    throw new RangeError(`Expected ${name} to be a non-negative safe number, but got a too large number.`);
  }
}

module.exports = class SizeRate {
  constructor(options) {
    if (!options || typeof options !== 'object' || Array.isArray(options)) {
      throw new TypeError(`Expected an object to specify SizeRate options, but got ${
        inspectWithKind(options)
      }.`);
    }

    validateNumber(options.max, '`max` option');

    for (const unsupportedOption of unsupportedOptions) {
      const val = options[unsupportedOption];

      if (val !== undefined) {
        throw new Error(`\`${unsupportedOption}\` option is not supported, but ${
          inspectWithKind(val)
        } was provided.`);
      }
    }

    options = Object.assign({
      base: 10,
      round: 2,
      spacer: ' ',
      standard: 'iec'
    }, options, {output: 'array'});

    Object.defineProperty(this, round, {value: options.round});
    Object.defineProperty(this, spacer, {value: options.spacer});

    const result = filesize(options.max, options);
    const value = result[0].toFixed(options.round);
    const symbol = result[1];

    this.denominator = `${value}${options.spacer}${symbol}`;

    Object.defineProperty(this, formatter, {
      value: filesize.partial(Object.assign(options, {
        exponent: filesize(options.max, Object.assign({}, options, {output: 'exponent'}))
      }))
    });

    Object.defineProperty(this, 'max', {
      enumerable: true,
      value: options.max
    });

    this.bytes = 0;
  }

  set(num) {
    validateNumber(num, 'an argument of `format` method');

    if (num > this.max) {
      throw new RangeError(`Expected a number no larger than the max bytes (${this.max}), but got ${num}.`);
    }

    this.bytes = num;
  }

  format(num) {
    if (num !== undefined) {
      this.set(num);
    }

    const result = this[formatter](this.bytes);
    const str = `${result[0].toFixed(this[round])}${this[spacer]}${result[1]}`;
    return `${' '.repeat(this.denominator.length - str.length)}${str} / ${this.denominator}`;
  }
};

