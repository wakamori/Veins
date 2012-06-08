#!/bin/bash

PROGRAM=`basename $0`

while getopts a:c:d: OPT
do
    case $OPT in
        "a" ) FLG_A="TRUE" ; VALUE_A="$OPTARG" ;;
        "c" ) FLG_C="TRUE" ; VALUE_C="$OPTARG" ;;
        "d" ) FLG_D="TRUE" ; VALUE_D="$OPTARG" ;;
          * ) OPT_ERROR=1; break;;
    esac
done

if [ $OPT_ERROR ]; then
    echo "Usage: $PROGRAM [-d directory] [-c command] [-a arguments]" 1>&2
    exit 1
fi

if [ "$FLG_D" = "TRUE" ]; then
    DIRECTORY=$VALUE_D
fi

if [ "$FLG_C" = "TRUE" ]; then
    COMMAND=$VALUE_C
fi

if [ "$FLG_A" = "TRUE" ]; then
    ARGS=$VALUE_A
fi

echo "DIRECTORY=$DIRECTORY"
echo "COMMAND=$COMMAND"
echo "ARGS=$ARGS"

/usr/local/bin/konoha2 - <<__EOT__
K.import("konoha");
K.import("konoha.subproc");
K.import("posix.process");

void main(String[] args) {
	Subproc s = Subproc.new("", true);
	if(args[0] == "init") {
		s.enableShellmode(false);
	}
	else {
		s.enableShellmode(true);
	}
	System.chdir(args[0])
	String str = s.exec("git " + args[1] + " " + args[2]);
	System.p(str);
}

String[] args = new String[0];
args.add("$DIRECTORY");
args.add("$COMMAND");
args.add("$ARGS");
main(args);
__EOT__
