#!/bin/sh

if [ $# -lt 2 ]; then
    echo "usage: $0 set <keytype>"
    echo "       $0 map <keytype> <valtype>"
    echo
    echo "       keytype may be one of byte, short, int"
    echo "       valtype may be any valid Java type"
    exit 1
fi

KIND=$1
shift

case $KIND in
    "set") KIND=Set;;
    "map") KIND=Map;;
    *)     echo "invalid kind"
	   exit 1;;
esac

KEYTYPE=$1
shift

case $KEYTYPE in
    byte)  XKEYTYPE=Byte;;
    short) XKEYTYPE=Short;;
    int)   XKEYTYPE=Integer;;
    *)	   echo "invalid key type"
	   exit 1;;
esac

if [ "$KIND" = "Map" ]; then
    VALTYPE=$1
    case $VALTYPE in
	boolean) XVALTYPE=Boolean;;
	byte) XVALTYPE=Byte;;
	short) XVALTYPE=Short;;
	int) XVALTYPE=Integer;;
	long) XVALTYPE=Long;;
	float) XVALTYPE=Float;;
	double) XVALTYPE=Double;;
	char) XVALTYPE=Character;;
	"") echo "missing value type"
	    exit 1;;
	[a-zA-Z_]*) XVALTYPE=$VALTYPE;;
	*) echo "invalid value type"
	   exit 1;;
    esac
fi

FILENAME=$KIND$XKEYTYPE$XVALTYPE.java

cat SetMap.t \
    | sed -e 's:^M?\(.*\)$:IFMAP(<!dnl\n  \1\n!>)dnl:' \
          -e 's:^S?\(.*\)$:IFSET(<!dnl\n  \1\n!>)dnl:' \
    | m4 -DKIND=$KIND \
    	 -DVARTYPE=$KEYTYPE -DXVARTYPE=$XKEYTYPE \
    	 -DVALTYPE=$VALTYPE -DXVALTYPE=$XVALTYPE \
    > $FILENAME

echo $FILENAME
