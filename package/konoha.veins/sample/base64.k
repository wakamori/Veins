using konoha.veins.*;

String source = "abc123+-/";
print source;
String encode = source.convert(to:base64);
print encode;
String decode = encode.convert(to:dbase64);
print decode;
