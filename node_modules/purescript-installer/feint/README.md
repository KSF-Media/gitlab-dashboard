# feint

[![npm version](https://img.shields.io/npm/v/feint.svg)](https://www.npmjs.com/package/feint)
[![Build Status](https://travis-ci.com/shinnn/feint.svg?branch=master)](https://travis-ci.com/shinnn/feint)
[![codecov](https://codecov.io/gh/shinnn/feint/branch/master/graph/badge.svg)](https://codecov.io/gh/shinnn/feint)

Make a given `Function` do nothing at its first call

```javascript
import feint from 'feint';

const fn = feint(() => 1);
fn(); //=> undefined
fn(); //=> 1
fn(); //=> 1
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm]https://docs.npmjs.com/about-npm/).

```
npm install feint
```

## API

```javascript
import feint from 'feint';
```

### feint(*fn*)

*fn*: `Function`  
Return: `Function`

It returns a new `Function` that does nothing when it's called for the first time. From the second time on, the function performs normally.

```javascript
import {existsSync, mkdirSync} from 'fs';
import feint from 'feint';

const feintMkdir = feint(mkdirSync);

feintMkdir('foo');
existsSync('foo'); //=> false

feintMkdir('foo');
existsSync('foo'); //=> true
```

## License

[ISC License](./LICENSE) © 2018 - 2019 Watanabe Shinnosuke
