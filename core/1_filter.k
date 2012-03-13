/**
 * I/O check
 */

boolean check_postdata(String data) {
    /* check input data */
}

boolean check_getdata(String getdata) {
    /* check input data */
}

boolean check_query(String query) {
    /* check query string */
}

String escape_html(String output) {
    /* escape output html */
		output = output.replace("<" , "&lt");
		output = output.replace(">" , "&gt");
		output = output.replace("&" , "&amp");
		output = output.replace("\"", "&quot");
		output = output.replace("\'", "&#39");
		return output;
}

// test
void escape_test(String s) {
	print s;
	print escape_html(s);
}
escape_test("<a hoge>test</hoge>");
escape_test("aa&bb=\"test\" \'hoge\' ");

