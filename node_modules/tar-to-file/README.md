# tar-to-file

[![npm version](https://img.shields.io/npm/v/tar-to-file.svg)](https://www.npmjs.com/package/tar-to-file)
[![Build Status](https://travis-ci.org/shinnn/tar-to-file.svg?branch=master)](https://travis-ci.org/shinnn/tar-to-file)
[![Build status](https://ci.appveyor.com/api/projects/status/k7u29ig6o2q21hri/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/tar-to-file/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/tar-to-file.svg)](https://coveralls.io/github/shinnn/tar-to-file?branch=master)

Decompress a single-file [tar](https://www.gnu.org/software/tar/manual/html_node/Standard.html) archive with the [Observable](https://tc39.github.io/proposal-observable/) API

```javascript
const {readFileSync} = require('fs');
const tarToFile = require('tar-to-file');

const subscription = tarToFile('archive.tar', 'target.txt').subscribe({
  start() {
    console.log('Extracting `archive.tar` ...');
  },
  complete() {
    console.log('Extracted.');
    readFileSync('target.txt'); //=> <Buffer ...>
  }
});

subscription.unsubscribe();
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install tar-to-file
```

## API

```javascript
const tarToFile = require('tar-to-file');
```

### tarToFile(*tarPath*, *filePath* [, *options*])

*tarPath*: `string` (path of the archive file)  
*filePath*: `string` (file path of the extracted contents)  
*options*: `Object`  
Return: [`Observable`](https://tc39.github.io/proposal-observable/#observable) ([zenparsing's implementation](https://github.com/zenparsing/zen-observable))

When the `Observable` is [subscribe](https://tc39.github.io/proposal-observable/#observable-prototype-subscribe)d, it starts to extract a file from a single-file archive and successively send extraction progress to its [`Observer`](https://github.com/tc39/proposal-observable#observer).

Every progress object have two properties `header` and `bytes`. `header` is [a header of the entry](https://github.com/mafintosh/tar-stream#headers), and `bytes` is the total processed size of the extraction.

For example you can get the progress as a percentage by `(progress.bytes / progress.header.size || 0) * 100`.

```javascript
tarToFile('my/archive.tar', 'my/file').subscribe(({bytes, header}) => {
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

Note that *tar-to-file* doesn't support any archives that:

* contains multiple entries
* contains a non-file, for example directory and symlink entries

```javascript
tarToFile('./has-directory.tar').subscribe({
  error(err) {
    err.message; /*=>
      Expected the archive test/fixture-directory.tar to contain only a single file,
      but actually contains a non-file entry '_' (directory).
    */
  }
});

tarToFile('./has-two-files.tar').subscribe({
  error(err) {
    err.message; /*=>
      Expected the archive ./has-two-files.tar to contain only a single file,
      but actually contains multiple entries 'a.txt' and 'b.txt'.
    */
  }
});
```

#### Options

You can pass options to [tar-fs](https://github.com/mafintosh/tar-fs)'s [`extract()`](https://github.com/mafintosh/tar-fs/blob/v1.15.3/index.js#L168) method and [`fs.createWriteStream()`](https://nodejs.org/api/fs.html#fs_fs_createwritestream_path_options). Note that:

* [`strip`](https://github.com/mafintosh/tar-fs/blob/v1.15.3/index.js#L185), [`filter` and `ignore`](https://github.com/mafintosh/tar-fs/blob/v1.15.3/index.js#L173) options are not supported.
* [`fs` option](https://github.com/mafintosh/tar-fs/blob/v1.15.3/index.js#L172) defaults to [graceful-fs](https://github.com/isaacs/node-graceful-fs) for more stability.

Additionally, you can use the following:

##### tarTransform

Type: [`Stream`](https://nodejs.org/api/stream.html#stream_stream)

A [transform stream](https://nodejs.org/api/stream.html#stream_class_stream_transform) to modify the archive before extraction.

For example, pass [`zlib.createGunzip()`](https://nodejs.org/api/zlib.html#zlib_zlib_creategunzip_options) and you can decompress a [gzipped](https://tools.ietf.org/html/rfc1952) tar.

```javascript
const tarToFile = require('tar-to-file');
const {createGunzip} = require('zlib');

const gunzipStream = createGunzip();

const observable = fileToTar('Untitled.tar.gz', 'Untitled.txt', {
  tarTransform: gunzipStream
});
```

## Related project

* [file-to-tar](https://github.com/shinnn/file-to-tar) – Inverse of this module. Create a tar archive from a single file

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe
