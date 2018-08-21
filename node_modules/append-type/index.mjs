/*!
 * append-type | ISC (c) Shinnosuke Watanabe
 * https://github.com/shinnn/append-type
*/
export default function appendType(val) {
	if (val === undefined) {
		return 'undefined';
	}

	if (val === null) {
		return 'null';
	}

	return String(val) + ' (' + typeof val + ')';
}
