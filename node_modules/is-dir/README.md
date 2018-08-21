# node-is-dir [![NPM version][npm-image]][npm-url] [![Downloads][downloads-image]][npm-url] [![Build Status][travis-image]][travis-url] [![Coveralls Status][coveralls-image]][coveralls-url]
> Tests if a given path resolves to a file.

## Example

### Async

```javascript
var isFile = require('is-dir');
isFile(__filename, function(err, bool){
  console.log(bool); // => true
});
```

### Sync

```javascript
var isDir = require('is-dir');
var bool = isDir(__dirname);
console.log(bool); // => true
```

With `.sync`:

```javascript
var isDir = require('is-dir');
var bool = isDir.sync(__dirname);
console.log(bool); // => true
```

##LICENSE
``````
The MIT License (MIT)

Copyright (c) 2014 Joseph Spencer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
``````

[downloads-image]: http://img.shields.io/npm/dm/node-is-dir.svg
[npm-url]: https://npmjs.org/package/node-is-dir
[npm-image]: http://img.shields.io/npm/v/node-is-dir.svg

[travis-url]: https://travis-ci.org/jsdevel/node-is-dir
[travis-image]: http://img.shields.io/travis/jsdevel/node-is-dir.svg

[coveralls-url]: https://coveralls.io/r/jsdevel/node-is-dir
[coveralls-image]: http://img.shields.io/coveralls/jsdevel/node-is-dir/master.svg
