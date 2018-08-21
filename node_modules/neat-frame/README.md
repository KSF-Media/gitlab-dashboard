# neat-frame

[![npm version](https://img.shields.io/npm/v/neat-frame.svg)](https://www.npmjs.com/package/neat-frame)
[![Build Status](https://travis-ci.org/shinnn/neat-frame.svg?branch=master)](https://travis-ci.org/shinnn/neat-frame)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/neat-frame.svg)](https://coveralls.io/github/shinnn/neat-frame?branch=master)

Generate simple framed text

```javascript
const neatFrame = require('neat-frame');

console.log(neatFrame(`neat-frame
Generate simple framed text from a string`));
```

```
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│ neat-frame                                                               │
│ Generate simple framed text from a string                                │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

* No config, 1 simple beautiful output
  * Single-line border
  * 1 padding between text and borders
  * 2 horizontal spaces on both side of the box
  * Left-aligned text
* Automatic box width adjustment for the current terminal width
  * Even support for a non-TTY environment where [`process.stdout.columns`](https://nodejs.org/api/tty.html#tty_writestream_columns) is unavailable
* Automatic line breaking for long text

## Installation

[Use npm.](https://docs.npmjs.com/cli/install)

```
npm install neat-frame
```

## API

```javascript
const neatFrame = require('neat-frame');
```

### neatFrame(*input*)

*input*: `string`  
Return: `string`

```javascript
// When the terminal width is 30

neatFrame('abcdefghijklmnopqrstuvwxyz');
/* =>
  ┌────────────────────────┐
  │                        │
  │ abcdefghijklmnopqrstuv │
  │ wxyz                   │
  │                        │
  └────────────────────────┘
*/

// When the terminal width is 20

neatFrame('abcdefghijklmnopqrstuvwxyz');
/* =>
  ┌──────────────┐
  │              │
  │ abcdefghijkl │
  │ mnopqrstuvwx │
  │ yz           │
  │              │
  └──────────────┘
*/
```

## License

[ISC License](./LICENSE) © 2017 Shinnosuke Watanabe
