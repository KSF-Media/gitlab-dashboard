# rate-map

[![npm version](https://img.shields.io/npm/v/rate-map.svg)](https://www.npmjs.com/package/rate-map)
[![Build Status](https://travis-ci.org/shinnn/rate-map.svg?branch=master)](https://travis-ci.org/shinnn/rate-map)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/rate-map.svg)](https://coveralls.io/r/shinnn/rate-map)

Map a number in the range of `0`-`1` to a new value with a given range

```javascript
import rateMap from 'rate-map';

rateMap(0.5, 0, 100); //=> 50
rateMap(0.5, 100, 200); //=> 150
rateMap(0.5, -100, 100); //=> 0
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install rate-map
```

## API

### rateMap(*value*, *start*, *end*)

*value*: `number` in the range of `0..1`  
*start*: `number`  
*end*: `number`  
Return: `number`

```javascript
rateMap(0.1, 0, -1); //=> -0.1
rateMap(0.1, 1, -1); //=> -0.8
rateMap(0.1, -1, -2); //=> -1.1

rateMap(0, 5, 5); //=> 5
rateMap(0.5, 5, 5); //=> 5
rateMap(1, 5, 5); //=> 5
```

## License

[ISC License](./LICENSE) © 2018 Shinnosuke Watanabe
