# size-rate

[![NPM version](https://img.shields.io/npm/v/size-rate.svg)](https://www.npmjs.com/package/size-rate)
[![Build Status](https://travis-ci.org/shinnn/size-rate.svg?branch=master)](https://travis-ci.org/shinnn/size-rate)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/size-rate.svg)](https://coveralls.io/github/shinnn/size-rate?branch=master)

Format current and maximum bytes into a human-readable expression

```javascript
const SizeRate = require('size-rate');

const sizeRate = SizeRate({max: 100000000});

sizeRate.format();
//=> '  0.00 MB / 100.00 MB'

sizeRate.set(75049821);

sizeRate.format();
//=> ' 75.05 MB / 100.00 MB'

sizeRate.set(100000000);

sizeRate.format(100000000);
//=> '100.00 MB / 100.00 MB'
```

This module is useful for printing progress to the same line with [`process.stdout.clearLine()`](https://nodejs.org/api/readline.html#readline_readline_clearline_stream_dir).

<img src="screencast-1.gif" width="40%" align="right">

The format is designed to keep initial string length: it adds whitespaces to short values, keeps using the same unit and number of decimal spaces regardless of the current value.

<img src="screencast-2.gif" width="40%" align="right">

Usually, without string length unification, you ought to get more restless output instead.

## Installation

[Use npm.](https://docs.npmjs.com/cli/install)

```
npm install size-rate
```

## API

```javascript
const SizeRate = require('size-rate');
```

### class SizeRate(*options*)

*options*: `string` (single-line string)  
Return: `string`

#### options

Options are directly passed to [filesize.js](https://github.com/avoidwork/filesize.js) with these differences:

* [`base`](https://github.com/avoidwork/filesize.js#base) option defaults to `10` instead of `2`.
* [`standard`](https://github.com/avoidwork/filesize.js#standard) option defaults to `iec`.
* [`exponent`](https://github.com/avoidwork/filesize.js#exponent), [`fullform`](https://github.com/avoidwork/filesize.js#fullform), [`fullforms`](https://github.com/avoidwork/filesize.js#fullforms), [`output`](https://github.com/avoidwork/filesize.js#output) and [`suffixes`](https://github.com/avoidwork/filesize.js#suffixes-deprecated-use-symbols) options are not supported.

Also you need to set the following option:

##### max

Type: `number` (non-negative finite integer)

*Required.* The maximum size in byte displayed as a denominator.

### Instance properties

#### max

Type: `number`

The maximum size. Same as [the `max` property passed to the constructor](#max).

#### bytes

Type: `number`

The current size.

### Instance methods

#### format()

Return: `string`

Create a string in the form `${bytes} ${unit_of_max} / ${max} ${unit_of_max}` using [`bytes`](#bytes) and [`max`](#max-1) properties.

```javascript
new SizeRate({max: 1024}).format();
//=> '0.00 KB / 1.02 kB'

new SizeRate({max: 1024, base: 2}).format();
//=> '0.00 KiB / 1.00 KiB'
```

#### set(*currentBytes*)

*currentBytes*: `integer` (non-negative finite integer)

Set the current size in byte displayed as a numerator.

```javascript
const sizeRate = new SizeRate({max: 300000000, round: 1});

sizeRate.format();
//=> '  0.0 MB / 300.0 MB'

sizeRate.set(123456789);

sizeRate.format();
//=> '123.5 MB / 300.0 MB'
```

Note that the argument must not be larger than [`max`](#max-1) property.

```javascript
const sizeRate = new SizeRate({max: 10});

sizeRate.set(11);
// RangeError: Expected a number no larger than the max bytes (10), but got 11.
```

#### format(*currentBytes*)

*currentBytes*: `integer` (non-negative finite integer)  
Return: `string`

Call [`set`](#setcurrentbytes) method with a given argument, then call [`format`](#format) method.

```javascript
const sizeRate = new SizeRate({max: 7000, base: 2});

// Same as sizeRate.set(500); sizeRate.format()
sizeRate.format(500);
//=> '0.49 KiB / 6.84 KiB'

sizeRate.bytes;
//=> 500
```

## License

[Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/deed)
