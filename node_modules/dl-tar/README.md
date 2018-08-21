# dl-tar

[![npm version](https://img.shields.io/npm/v/dl-tar.svg)](https://www.npmjs.com/package/dl-tar)
[![Build Status](https://travis-ci.org/shinnn/dl-tar.svg?branch=master)](https://travis-ci.org/shinnn/dl-tar)
[![Build status](https://ci.appveyor.com/api/projects/status/83sbr9dtbp3hreoy/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/dl-tar/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/dl-tar.svg)](https://coveralls.io/github/shinnn/dl-tar?branch=master)

A [Node.js](https://nodejs.org/) module to download and extract a [tar](https://www.gnu.org/software/tar/) archive with the [Observable](https://tc39.github.io/proposal-observable/) API

```javascript
const {readdirSync} = require('fs');
const dlTar = require('dl-tar');

const url = 'https://****.org/my-archive.tar';
/* my-archive
   ├── LICENSE
   ├── README.md
   ├── INSTALL
   └── bin
       └── app.exe
*/

dlTar(url, 'my/dir').subscribe({
  next({entry}) {
    if (entry.bytes !== entry.header.size) {
      return;
    }

    console.log(`✓ ${entry.header.name}`);
  },
  complete() {
    readdirSync('my/dir'); //=> ['INSTALL', LICENSE', 'README.md', 'bin']

    console.log('\nCompleted.')
  }
});
```

```
✓ bin/
✓ bin/app.exe
✓ README.md
✓ LICENSE
✓ install

Completed.
```

For [gzipped](https://tools.ietf.org/html/rfc1952) tar (`tar.gz`), use [`dl-tgz`](https://github.com/shinnn/dl-tgz) instead.

## Installation

[Use npm.](https://docs.npmjs.com/cli/install)

```
npm install dl-tar
```

## API

```javascript
const dlTar = require('dl-tar');
```

### dlTar(*tarArchiveUrl*, *extractDir* [, *options*])

*tarArchiveUrl*: `String`  
*extractDir*: `String` (a path where the archive will be extracted)  
*options*: `Object`  
Return: [`Observable`](https://tc39.github.io/proposal-observable/#observable) ([zenparsing's implementation](https://github.com/zenparsing/zen-observable))

When the `Observable` is [subscribe](https://tc39.github.io/proposal-observable/#observable-prototype-subscribe)d, it starts to download the tar archive, extract it and successively send extraction progress to its [`Observer`](https://github.com/tc39/proposal-observable#observer).

When the [`Subscription`](https://tc39.github.io/proposal-observable/#subscription-objects) is [unsubscribe](https://tc39.github.io/proposal-observable/#subscription-prototype-unsubscribe)d, it stops downloading and extracting.

#### Progress

Every progress object have two properties `entry` and `response`.

##### entry

Type: `Object {bytes: <number>, header: <Object>}`

`entry.header` is [a header of the entry](https://github.com/mafintosh/tar-stream#headers), and `entry.bytes` is the total size of currently extracted entry. `bytes` is always `0` if the entry is not a file but directory, link or symlink.

For example you can get the progress of each entry as a percentage by `(progress.entry.bytes / progress.entry.header.size || 0) * 100`.

```javascript
dlTar('https://****.org/my-archive.tar', 'my/dir')
.filter(progress => progress.entry.header.type === 'file')
.subscribe(progress => {
  console.log(`${(progress.entry.bytes / progress.entry.header.size * 100).toFixed(1)} %`);

  if (progress.entry.bytes === progress.entry.header.size) {
    console.log(`>> OK ${progress.entry.header.name}`);
  }
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
>> OK bin/app.exe
0.0 %
0.1 %
0.2 %
0.3 %
︙
```

##### response

Type: `Object {bytes: <number>, headers: <Object>, url: <string>}`

`response.url` is the final redirected URL of the request, `response.headers` is a [response header object](https://nodejs.org/api/http.html#http_message_headers) derived from [`http.IncomingMessage`](https://nodejs.org/api/http.html#http_class_http_incomingmessage), and `response.bytes` is a total content length of the downloaded archive. `content-length` header will be converted to `Number` if it is `String`.

#### Options

You can pass options to [Request](https://github.com/request/request#requestoptions-callback) and [tar-fs](https://github.com/mafintosh/tar-fs)'s [`extract` method](https://github.com/mafintosh/tar-fs/blob/12968d9f650b07b418d348897cd922e2b27ec18c/index.js#L167). Note that:

* [`ignore` option](https://github.com/mafintosh/tar-fs/blob/b79d82a79c5e21f6187462d7daaba1fc03cdd1de/index.js#L236) is applied before [`map` option](https://github.com/mafintosh/tar-fs/blob/b79d82a79c5e21f6187462d7daaba1fc03cdd1de/index.js#L232) modifies filenames.
* [`strip` option](https://github.com/mafintosh/tar-fs/blob/12968d9f650b07b418d348897cd922e2b27ec18c/index.js#L47) defaults to `1`, not `0`. That means the top level directory is stripped off by default.
* [`fs`](https://github.com/mafintosh/tar-fs/blob/e59deed830fded0e4e5beb016d2df9c7054bb544/index.js#L65) option defaults to [graceful-fs](https://github.com/isaacs/node-graceful-fs) for more stability.

Additionally, you can use the following:

##### tarTransform

Type: [`Stream`](https://nodejs.org/api/stream.html#stream_stream)

A [transform stream](https://nodejs.org/api/stream.html#stream_class_stream_transform) to modify the archive before extraction.

For example, pass [gunzip-maybe](https://github.com/mafintosh/gunzip-maybe) to this option and you can download both [gzipped](https://tools.ietf.org/html/rfc1952) and non-gzipped tar.

```javascript
const dlTar = require('dl-tar');
const gunzipMaybe = require('gunzip-maybe');

const observable = dlTar('https://github.com/nodejs/node/archive/master.tar.gz', './', {
  tarTransform: gunzipMaybe()
});
```

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe
