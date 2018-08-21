var Stream = require('..'),
    Pipe = require('pipette').Pipe;
require('should');
describe('Stream', function () {
  it('should work', function (done) {
    var readStream = new Stream('Test buffer'),
        writeStream = new Stream(),
        counter = 0;
    writeStream.on('end', function () {
      writeStream.toString().should.equal('Test Test buffer');
      if (counter++) done();
    });
    writeStream.write('Test ');
    readStream.pipe(writeStream).should.equal(writeStream);
    writeStream.end();
  });
});
