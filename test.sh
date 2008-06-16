#!/bin/bash
for i in *.java; do
    echo -n "testing $i: "
    FN=`basename $i .java`
    java -classpath . $FN
    if [ $? != 0 ]; then
	echo "testsuite failure"
	exit 1
    fi
done
