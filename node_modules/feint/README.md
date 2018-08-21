# feint

[![npm version](https://img.shields.io/npm/v/feint.svg)](https://www.npmjs.com/package/feint)
[![Build Status](https://travis-ci.org/shinnn/feint.svg?branch=master)](https://travis-ci.org/shinnn/feint)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/feint.svg)](https://coveralls.io/r/shinnn/feint)

Make a given function do nothing at its first call

```javascript
const feint = require('feint');

const fn = feint(() => 1);
fn(); //=> undefined
fn(); //=> 1
fn(); //=> 1
```

## Installation

[Use npm](https://docs.npmjs.com/cli/install).

```
npm install feint
```

## API

### feint(*fn*)

*fn*: `Function`  
Return: `Function`

It returns a new function that does nothing when it's called for the first time. From the second time on, the function performs normally.

```javascript
const {existsSync, mkdirSync} = require('fs');
const feint = require('feint');

const feintMkdir = feint(mkdirSync);

feintMkdir('foo');
existsSync('foo'); //=> false

feintMkdir('foo');
existsSync('foo'); //=> true
```

## License

[ISC License](./LICENSE) © 2018 Shinnosuke Watanabe
