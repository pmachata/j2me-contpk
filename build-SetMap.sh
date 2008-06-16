#!/bin/sh

. build-SetMap.conf

echo "instantiating Set and Map classes..."
echo "" > build-SetMap.tmps
for i in $KEYTYPES; do
    FILENAME=`./inst-SetMap.sh set $i`
    if [ $? != 0 ]; then
	echo "failed instantiating set $i";
	exit 1;
    fi
    echo $FILENAME >> build-SetMap.tmps
    for j in $VALUETYPES; do
	FILENAME=`./inst-SetMap.sh map $i $j`
	if [ $? != 0 ]; then
	    echo "failed instantiating map $i $j";
	    exit 1;
	fi
	echo $FILENAME >> build-SetMap.tmps
    done
done
