# file-to-tar

[![npm version](https://img.shields.io/npm/v/file-to-tar.svg)](https://www.npmjs.com/package/file-to-tar)
[![Build Status](https://travis-ci.org/shinnn/file-to-tar.svg?branch=master)](https://travis-ci.org/shinnn/file-to-tar)
[![Build status](https://ci.appveyor.com/api/projects/status/lvk0mredvv0ovinw/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/file-to-tar/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/file-to-tar.svg)](https://coveralls.io/github/shinnn/file-to-tar?branch=master)

Create a [tar](https://www.gnu.org/software/tar/manual/html_node/Standard.html) archive from a single file with the [Observable](https://tc39.github.io/proposal-observable/) API

```javascript
const {existsSync} = require('fs');
const fileToTar = require('file-to-tar');

const subscription = fileToTar('readme.txt', 'archive.tar').subscribe({
  start() {
    console.log('Creating `archive.tar` from `readme.txt` ...');
  },
  complete() {
    console.log('`archive.tar` created.');
    existsSync('archive.tar'); //=> true
  }
});

// Cancel compression
subscription.unsubscribe();
```

## Installation

[Use npm.](https://docs.npmjs.com/cli/install)

```
npm install file-to-tar
```

## API

```javascript
const fileToTar = require('file-to-tar');
```

### fileToTar(*filePath*, *tarPath* [, *options*])

*filePath*: `string` (path of a file to compress)  
*tarPath*: `string` (path of the created archive file)  
*options*: `Object`  
Return: [`Observable`](https://tc39.github.io/proposal-observable/#observable) ([zenparsing's implementation](https://github.com/zenparsing/zen-observable))

When the `Observable` is [subscribed](https://tc39.github.io/proposal-observable/#observable-prototype-subscribe), it starts to create a tar file from a given file and successively send compression progress to its `Observer`.

Every progress object have two properties `header` and `bytes`. `header` is [a header of the entry](https://github.com/mafintosh/tar-stream#headers), and `bytes` is the total processed size of the compression.

For example you can get the progress as a percentage by `(progress.bytes / progress.header.size || 0) * 100`.

```javascript
fileToTar('my/file', 'my/archive.tar')
.subscribe(({bytes, header}) => {
  console.log(`${(bytes / header.size * 100).toFixed(1)} %`);
}, console.error, () => {
  console.log('Completed');
});
```

```
0.0 %
0.1 %
0.3 %
0.4 %
︙
99.6 %
99.8 %
99.9 %
100.0 %
Completed
```

#### Options

You can pass options to [tar-fs](https://github.com/mafintosh/tar-fs)'s [`pack()`](https://github.com/mafintosh/tar-fs/blob/v1.15.3/index.js#L61) method and [`fs.createReadStream()`](https://nodejs.org/api/fs.html#fs_fs_createreadstream_path_options). Note that:

* [`entries`](https://github.com/mafintosh/tar-fs/blob/v1.15.3/index.js#L69), [`strip`](https://github.com/mafintosh/tar-fs/blob/v1.15.3/index.js#L76), [`filter` and `ignore`](https://github.com/mafintosh/tar-fs/blob/v1.15.3/index.js#L66) options are not supported.
* [`fs` option](https://github.com/mafintosh/tar-fs/blob/v1.15.3/index.js#L65) defaults to [graceful-fs](https://github.com/isaacs/node-graceful-fs) for more stability.

Additionally, you can use the following:

##### tarTransform

Type: [`Stream`](https://nodejs.org/api/stream.html#stream_stream)

A [transform stream](https://nodejs.org/api/stream.html#stream_class_stream_transform) to modify the archive after compression.

For example, pass [`zlib.createGzip()`](https://nodejs.org/api/zlib.html#zlib_zlib_creategzip_options) and you can create a [gzipped](https://tools.ietf.org/html/rfc1952) tar.

```javascript
const fileToTar = require('file-to-tar');
const {createGzip} = require('zlib');

const gzipStream = createGzip();

const observable = fileToTar('Untitled.txt', 'Untitled.tar.gz', {
  tarTransform: gzipStream
});
```

## Related project

* [tar-to-file](https://github.com/shinnn/tar-to-file) – Inverse of this module. Decompress a single-file tar archive

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe
