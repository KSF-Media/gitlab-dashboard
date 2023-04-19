# cancelable-pump

[![npm version](https://img.shields.io/npm/v/cancelable-pump.svg)](https://www.npmjs.com/package/cancelable-pump)
[![Build Status](https://travis-ci.org/shinnn/cancelable-pump.svg?branch=master)](https://travis-ci.org/shinnn/cancelable-pump)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/cancelable-pump.svg)](https://coveralls.io/github/shinnn/cancelable-pump?branch=master)

Cancelable [`pump`](https://github.com/mafintosh/pump)

```javascript
const {createReadStream, createWriteStream} = require('cancelable-pump');
const cancelablePump = require('cancelable-pump');

cancelablePump(createReadStream('1GB-file.txt'), createWriteStream('dest0'), () => {
  statSync('dest0').size; //=> 1000000000;
});

const cancel = cancelablePump(createReadStream('1GB-file.txt'), createWriteStream('dest1'), () => {
  statSync('dest1').size; //=> 263192576, or something else smaller than 1000000000
});

setTimeout(() => {
  cancel();
}, 1000);
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install cancelable-pump
```

## API

```javascript
const cancelablePump = require('cancelable-pump');
```

### cancelablePump(*stream0* [, *stream1*, *stream2*, ...] [, *callback*])

*stream0*, *stream1*, *stream2*, ...: [`Stream`](https://nodejs.org/api/stream.html#stream_stream)  
*callback*: `Function`  
Return: `Function`

### cancelablePump(*streams* [, *callback*])

*streams*: `Array<Stream>`  
*callback*: `Function`  
Return: `Function`

The API is almost the same as `pump`'s. The only difference is *cancelable-pump* returns a function to destroy all streams without passing any errors to the callback.

```javascript
const cancel = cancelablePump([src, transform, anotherTransform, dest], err => {
  err; //=> undefined
});

cancel();
```

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe
