# neat-stack

[![npm version](https://img.shields.io/npm/v/neat-stack.svg)](https://www.npmjs.com/package/neat-stack)
[![Build Status](https://travis-ci.org/shinnn/neat-stack.svg?branch=master)](https://travis-ci.org/shinnn/neat-stack)
[![Build status](https://ci.appveyor.com/api/projects/status/x8vq3s90c2x0putc/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/neat-stack/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/neat-stack.svg)](https://coveralls.io/github/shinnn/neat-stack?branch=master)

Make a color-coded stack trace from an error

```javascript
const neatStack = require('neat-stack');
const request = require('request');

request('foo', err => console.error(neatStack(err)));
```

<img alt="example" src="./screenshot.svg" width="890">

Useful for CLI applications — stack traces are not very important for end users but needed for authors to receive meaningful bug reports.

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install neat-stack
```

## API

```javascript
const neatStack = require('neat-stack');
```

### neatStack(*error*)

*error*: `Error`  
Return: `string`

It returns a refined [`Error#stack`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Error/Stack):

* Red-colored by [ANSI escape code](https://en.wikipedia.org/wiki/ANSI_escape_code).
* Lines starting with `'    at'` are dimmed.
* [Any lines from Node.js internals are omitted](https://github.com/sindresorhus/clean-stack).
* Paths are simplified by [replacing a home directory with `~`](https://github.com/shinnn/tilde-path) on POSIX.

```javascript
const error = new Error('Hi');

error.stack; /* => `Error: Hi
    at Object.<anonymous> (/Users/example/run.js:1:75)
    at Module._compile (internal/modules/cjs/loader.js:654:30)
    at Object.Module._extensions..js (internal/modules/cjs/loader.js:665:10)
    at Module.load (internal/modules/cjs/loader.js:566:32)
    at tryModuleLoad (internal/modules/cjs/loader.js:506:12)
    at Function.Module._load (internal/modules/cjs/loader.js:498:3)
    at Function.Module.runMain (internal/modules/cjs/loader.js:695:10)
    at startup (internal/bootstrap/node.js:201:19)
    at bootstrapNodeJSCore (internal/bootstrap/node.js:516:3)` */

neatStack(error); /* => `\u001b[31mError: Hi\u001b[2m
    at Object.<anonymous> (~/example/run.js:1:88)\u001b[22m\u001b[39m` */
```

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe
