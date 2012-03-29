using konoha.veins.*;

OUT << "== encode == " << EOL;
OUT << "from: ";

String text = "abc def / & =";

OUT << text << EOL;

OUT << "to: " << text.convert(to:url) << EOL;
