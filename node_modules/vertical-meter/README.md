# vertical-meter

[![npm version](https://img.shields.io/npm/v/vertical-meter.svg)](https://www.npmjs.com/package/vertical-meter)
[![Build Status](https://travis-ci.org/shinnn/vertical-meter.svg?branch=master)](https://travis-ci.org/shinnn/vertical-meter)
[![Build status](https://ci.appveyor.com/api/projects/status/pfaygmaamvhpirb4/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/vertical-meter/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/vertical-meter.svg)](https://coveralls.io/github/shinnn/vertical-meter?branch=master)

Generate a dotted vertical bar whose height depends on the given value

```javascript
const verticalMeter = require('vertical-meter');

console.log(
  verticalMeter(0),
  verticalMeter(0.25),
  verticalMeter(0.5),
  verticalMeter(0.75),
  verticalMeter(1)
);
```

```
⠀ ⣀ ⣤ ⣶ ⣿
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install vertical-meter
```

## API

```javascript
const verticalMeter = require('vertical-meter');
```

### verticalMeter(*value*)

*value*: `number` (`0`..`1`)  
Return: `string`

| argument               | return       |
|:-----------------------|:-------------|
| `0` <= x < `1/8`       | `' '`        |
| `1/8` <= x < `3/8`     | `'⣀'`        |
| `3/8` <= x < `5/8`     | `'⣤'`        |
| `5/8` <= x < `7/8`     | `'⣶'`        |
| `7/8` <= x <= `1`      | `'⣿'`        |

## License

[ISC License](./LICENSE) © 2018 Shinnosuke Watanabe
