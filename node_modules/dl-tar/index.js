'use strict';

const {inspect} = require('util');
const {join} = require('path');
const streamLib = require('stream');

const Transform = streamLib.Transform;
const PassThrough = streamLib.PassThrough;

const cancelablePump = require('cancelable-pump');
const Extract = require('tar-stream').extract;
const fsExtract = require('tar-fs').extract;
const gracefulFs = require('graceful-fs');
const inspectWithKind = require('inspect-with-kind');
const isPlainObj = require('is-plain-obj');
const isStream = require('is-stream');
const loadRequestFromCwdOrNpm = require('load-request-from-cwd-or-npm');
const Observable = require('zen-observable');

class DestroyableTransform extends Transform {
	destroy() {
		super.unpipe();
	}
}

class InternalExtract extends Extract {
	constructor(options) {
		super();

		this.cwd = options.cwd;
		this.ignore = options.ignore;
		this.observer = options.observer;
		this.url = '';
		this.responseHeaders = null;
		this.responseBytes = 0;
	}

	emit(eventName, header, stream, originalNext) {
		if (eventName !== 'entry') {
			super.emit(eventName, header);
			return;
		}

		if (this.ignore && this.ignore(join(this.cwd, join('/', header.name)), header)) {
			stream.resume();
			originalNext();

			return;
		}

		super.emit('entry', header, stream, err => {
			if (err) {
				originalNext(err);
				return;
			}

			this.observer.next({
				entry: {
					header,
					bytes: header.size
				},
				response: {
					url: this.url,
					headers: this.responseHeaders,
					bytes: this.responseBytes
				}
			});

			originalNext();
		});
	}
}

const functionOptions = new Set(['ignore', 'map', 'mapStream']);
const priorRequestOption = {encoding: null};
const priorTarFsOption = {ignore: null};

function echo(val) {
	return val;
}

const DEST_ERROR = 'Expected a path where downloaded tar archive will be extracted';
const TAR_TRANSFORM_ERROR = '`tarTransform` option must be a transform stream ' +
                            'that modifies the downloaded tar archive before extracting';
const MAP_STREAM_ERROR = 'The function passed to `mapStream` option must return a stream';
const STRIP_ERROR = 'Expected `strip` option to be a non-negative integer (0, 1, ...) ' +
                    'that specifies how many leading components from file names will be stripped';

module.exports = function dlTar(...args) {
	const argLen = args.length;

	if (argLen !== 2 && argLen !== 3) {
		throw new RangeError(`Expected 2 or 3 arguments (<string>, <string>[, <Object>]), but got ${
			argLen === 0 ? 'no' : argLen
		} arguments instead.`);
	}

	const [url, dest] = args;

	return new Observable(observer => {
		if (typeof url !== 'string') {
			throw new TypeError(`Expected a URL of tar archive, but got ${inspect(url)}.`);
		}

		if (url.length === 0) {
			throw new Error('Expected a URL of tar archive, but got \'\' (empty string).');
		}

		if (typeof dest !== 'string') {
			throw new TypeError(`${DEST_ERROR}, but got ${inspect(dest)}.`);
		}

		if (dest.length === 0) {
			throw new Error(`${DEST_ERROR}, but got '' (empty string).`);
		}

		const options = argLen === 3 ? args[2] : {};

		if (argLen === 3) {
			if (!isPlainObj(options)) {
				throw new TypeError(`Expected an object to specify \`dl-tar\` options, but got ${inspect(options)}.`);
			}

			if (options.method) {
				const formattedMethod = inspect(options.method);

				if (formattedMethod.toLowerCase() !== '\'get\'') {
					throw new (typeof options.method === 'string' ? Error : TypeError)(`Invalid \`method\` option: ${
						formattedMethod
					}. \`dl-tar\` module is designed to download archive files. So it only supports the default request method "GET" and it cannot be overridden by \`method\` option.`);
				}
			}

			for (const optionName of functionOptions) {
				const val = options[optionName];

				if (val !== undefined && typeof val !== 'function') {
					throw new TypeError(`\`${optionName}\` option must be a function, but got ${
						inspectWithKind(val)
					}.`);
				}
			}

			if (options.strip !== undefined) {
				if (typeof options.strip !== 'number') {
					throw new TypeError(`${STRIP_ERROR}, but got a non-number value ${inspect(options.strip)}.`);
				}

				if (!isFinite(options.strip)) {
					throw new RangeError(`${STRIP_ERROR}, but got ${options.strip}.`);
				}

				if (options.strip > Number.MAX_SAFE_INTEGER) {
					throw new RangeError(`${STRIP_ERROR}, but got a too large number.`);
				}

				if (options.strip < 0) {
					throw new RangeError(`${STRIP_ERROR}, but got a negative number ${options.strip}.`);
				}

				if (!Number.isInteger(options.strip)) {
					throw new Error(`${STRIP_ERROR}, but got a non-integer number ${options.strip}.`);
				}
			}

			if (options.tarTransform !== undefined) {
				if (!isStream(options.tarTransform)) {
					throw new TypeError(`${TAR_TRANSFORM_ERROR}, but got a non-stream value ${inspect(options.tarTransform)}.`);
				}

				if (!isStream.transform(options.tarTransform)) {
					throw new TypeError(`${TAR_TRANSFORM_ERROR}, but got a ${
						['duplex', 'writable', 'readable'].find(type => isStream[type](options.tarTransform))
					} stream instead.`);
				}
			}
		}

		const extractStream = new InternalExtract({
			cwd: dest,
			ignore: options.ignore,
			observer
		});
		const mapStream = options.mapStream || echo;
		const fileStreams = [];
		let ended = false;
		let cancel;

		const fsExtractStream = fsExtract(dest, Object.assign({
			extract: extractStream,
			fs: gracefulFs,
			strip: 1
		}, options, {
			mapStream(fileStream, header) {
				const newStream = mapStream(fileStream, header);

				if (!isStream.readable(newStream)) {
					fsExtractStream.emit(
						'error',
						new TypeError(`${MAP_STREAM_ERROR}${
							isStream(newStream) ?
								' that is readable, but returned a non-readable stream' :
								`, but returned a non-stream value ${inspect(newStream)}`
						}.`)
					);

					fileStreams.push(fileStream);
					return new PassThrough();
				}

				let bytes = 0;
				fileStreams.push(newStream);

				if (header.size !== 0) {
					observer.next({
						entry: {header, bytes},
						response: {
							url: extractStream.url,
							headers: extractStream.responseHeaders,
							bytes: extractStream.responseBytes
						}
					});
				}

				return newStream.pipe(new DestroyableTransform({
					transform(chunk, encoding, cb) {
						bytes += chunk.length;

						if (bytes !== header.size) {
							observer.next({
								entry: {header, bytes},
								response: {
									url: extractStream.url,
									headers: extractStream.responseHeaders,
									bytes: extractStream.responseBytes
								}
							});
						}

						cb(null, chunk);
					}
				}));
			}
		}, priorTarFsOption));

		loadRequestFromCwdOrNpm().then(request => {
			if (ended) {
				return;
			}

			const pipe = [
				request(Object.assign({url}, options, priorRequestOption))
				.on('response', function(response) {
					if (response.statusCode < 200 || 299 < response.statusCode) {
						this.emit('error', new Error(`${response.statusCode} ${response.statusMessage}`));
						return;
					}

					if (typeof response.headers['content-length'] === 'string') {
						response.headers['content-length'] = Number(response.headers['content-length']);
					}

					extractStream.url = response.request.uri.href;
					extractStream.responseHeaders = response.headers;
				}),
				new Transform({
					transform(chunk, encoding, cb) {
						extractStream.responseBytes += chunk.length;
						cb(null, chunk);
					}
				}),
				fsExtractStream
			];

			if (options.tarTransform) {
				pipe.splice(2, 0, options.tarTransform);
			}

			cancel = cancelablePump(pipe, err => {
				ended = true;

				if (err) {
					observer.error(err);
					return;
				}

				observer.complete();
			});
		}).catch(err => {
			ended = true;
			observer.error(err);
		});

		return function cancelExtract() {
			if (!cancel) {
				ended = true;
				return;
			}

			if (ended) {
				return;
			}

			cancel();
		};
	});
};
