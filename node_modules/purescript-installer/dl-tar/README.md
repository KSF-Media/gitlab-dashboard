# dl-tar

[![npm version](https://img.shields.io/npm/v/dl-tar.svg)](https://www.npmjs.com/package/dl-tar)
[![Build Status](https://travis-ci.org/shinnn/dl-tar.svg?branch=master)](https://travis-ci.org/shinnn/dl-tar)
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
    if (entry.remain === 0) {
      console.log(`✓ ${entry.header.name}`);
    }
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

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install dl-tar
```

## API

```javascript
const dlTar = require('dl-tar');
```

### dlTar(*tarArchiveUrl*, *extractDir* [, *options*])

*tarArchiveUrl*: `string`  
*extractDir*: `string` (a path where the archive will be extracted)  
*options*: `Object`  
Return: [`Observable`](https://tc39.github.io/proposal-observable/#observable) ([zenparsing's implementation](https://github.com/zenparsing/zen-observable))

When the `Observable` is [subscribe](https://tc39.github.io/proposal-observable/#observable-prototype-subscribe)d, it starts to download the tar archive, extract it and successively send extraction progress to its [`Observer`](https://github.com/tc39/proposal-observable#observer).

When the [`Subscription`](https://tc39.github.io/proposal-observable/#subscription-objects) is [unsubscribe](https://tc39.github.io/proposal-observable/#subscription-prototype-unsubscribe)d, it stops downloading and extracting.

It automatically unzips gzipped archives.

#### Progress

Every progress object have two properties `entry` and `response`.

##### entry

Type: [`tar.ReadEntry`](https://github.com/npm/node-tar#class-tarreadentry-extends-minipass)

An instance of [node-tar](https://github.com/npm/node-tar)'s [`ReadEntry`](https://github.com/npm/node-tar/blob/v4.4.2/lib/read-entry.js) object.

For example you can get the progress of each entry as a percentage by `100 - progress.entry.remain / progress.entry.size * 100`.

```javascript
dlTar('https://****.org/my-archive.tar', 'my/dir')
.filter(progress => progress.entry.type === 'File')
.subscribe(progress => {
  console.log(`${(100 - progress.entry.remain / progress.entry.size * 100).toFixed(1)} %`);

  if (progress.entry.remain === 0) {
    console.log(`>> OK ${progress.entry.header.path}`);
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

`response.url` is the final redirected URL of the request, `response.headers` is a [response header object](https://nodejs.org/api/http.html#http_message_headers) derived from [`http.IncomingMessage`](https://nodejs.org/api/http.html#http_class_http_incomingmessage), and `response.bytes` is a total content length of the downloaded archive. `content-length` header will be converted to `number` if it's `string`.

#### Options

You can pass options to [Request](https://github.com/request/request#requestoptions-callback) and [node-tar](https://www.npmjs.com/package/tar)'s [`Unpack` constructor](https://github.com/npm/node-tar#class-tarunpack). Note that:

* `onentry` option is not supported.
* `strict` option defaults to `true`, not `false`.
* `strip` option defaults to `1`, not `0`. That means the top level directory is stripped off by default.

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe
