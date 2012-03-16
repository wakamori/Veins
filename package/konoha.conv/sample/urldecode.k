using konoha.conv.*;

OUT << "== decode == " << EOL;
OUT << "from: ";

String text = "abc+def+%2F+%26+%3D";

OUT << text << EOL;

OUT << "to: " << text.convert(to:durl) << EOL;
