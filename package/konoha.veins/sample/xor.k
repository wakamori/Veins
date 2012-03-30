using konoha.veins.*;

$SEED = int.random();
print $SEED;

String source = "abc123/+-";
print source;

Bytes b = source.encode(to:xor);
String decode = b.decode(to:xor);
print decode;
