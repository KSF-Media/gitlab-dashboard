# StringStream for node.js

This package provides classes to work with strings in a streaming way.

## Installation

  npm install string-stream

## Api

  - [Readable()](#readable)
  - [Readable.read()](#readablereadnnumber)
  - [Readable.pipe()](#readablepipedestbuffer)

### Readable()

  Implements a readable stream interface to a string or a buffer.

### Readable.read(n:Number)

  Reads the given n bytes from the stream.

### Readable.pipe(dest:Buffer)

  Not quite sure if it is necessary to implement the pipe method.  But the
  piping with the core method doesn't work.

