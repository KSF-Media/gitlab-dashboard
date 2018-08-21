# truncated-list

[![npm version](https://img.shields.io/npm/v/truncated-list.svg)](https://www.npmjs.com/package/truncated-list)
[![Build Status](https://travis-ci.org/shinnn/truncated-list.svg?branch=master)](https://travis-ci.org/shinnn/truncated-list)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/truncated-list.svg)](https://coveralls.io/github/shinnn/truncated-list?branch=master)

Create a list of items with truncating lines to the specified maximum number

```javascript
const truncatedList = require('truncated-list');

console.log(truncatedList([
  'Apple',
  'Orange',
  'Strawberry',
  'Grape',
  'Lemon',
  'Kiwi'
], 4));
```

```
* Apple
* Orange
* Strawberry
* Grape
  ... and 2 more
```

## Installation

[Use npm.](https://docs.npmjs.com/cli/install)

```
npm install truncated-list
```

## API

```javascript
const truncatedList = require('truncated-list');
```

### truncatedList(*items*, *max*)

*items*: `Iterable<string>` (list items)  
*max*: `integer` (maximum number of items)  
Return: `string`

It joins items into a list each of lines begins with `* `.

If the number of items exceeds `max`, it truncates the surplus and append `... and X more` to the result.

```javascript
truncatedList(new Set(['a', 'b']), 2);
//=> '* a\n* b'

truncatedList(new Set(['a', 'b']), 1);
//=> '* a\n  ... and 1 more'
```

## License

[ISC License](./LICENSE) © 2018 Shinnosuke Watanabe
