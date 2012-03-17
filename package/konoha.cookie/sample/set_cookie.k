using konoha.cookie.*;

void main(string[] args)
{
    c = new Cookie();
    c["key"] = "val";
    c["key"]["expires"] = "exp";
    c["key"]["path"] = "/";
    OUT << c.dump() << EOL;
}
