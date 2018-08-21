# prepare-write

[![NPM version](https://img.shields.io/npm/v/prepare-write.svg)](https://www.npmjs.com/package/prepare-write)
[![Build Status](https://travis-ci.org/shinnn/prepare-write.svg?branch=master)](https://travis-ci.org/shinnn/prepare-write)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/prepare-write.svg)](https://coveralls.io/github/shinnn/prepare-write?branch=master)

Prepare for writing a file to the given path – create ancestor directories and verify no directory exists in the path

```javascript
const {existsSync} = require('fs');
const prepareWrite = require('prepare-write');

existsSync('dir0'); //=> false

(async () => await prepareWrite('dir0/dir1/dir2/file.txt'))();

existsSync('dir0'); //=> true
existsSync('dir0/dir1'); //=> true
existsSync('dir0/dir1/dir2'); //=> true
existsSync('dir0/dir1dir2/file.txt'); //=> false
```

## Installation

[Use npm.](https://docs.npmjs.com/cli/install)

```
npm install prepare-write
```

## API

```javascript
const prepareWrite = require('prepare-write');
```

### prepareWrite(*path*)

*path*: `string` (directory path)  
Return: `Promise<string | null>`

It ensures you can soon write a file to the given path by:

1. Creating ancestor directories if they don't exist
2. Checking if no directory already exists in the path

The `Promise` will be fulfilled with an absolute path of the first directory that had to be created.

```javascript
// a directory /foo doesn't exist

prepareWrite('/foo/bar/baz').then(firstDir => {
  firstDir; //=> '/foo/'
});

// a directory /foo/bar exists

prepareWrite('/foo/bar/baz').then(firstDir => {
  firstDir; //=> null
});

// a directory /foo/bar/baz exists

prepareWrite('/foo/bar/baz').catch(err => {
  err.message;
  //=> 'Tried to create a file as /foo/bar/baz, but a directory with the same name already exists.'
});
```

## License

[Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/deed)
