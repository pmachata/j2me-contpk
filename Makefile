all: stamp-all

clean:
	rm -f stamp-* *.class
	-rm -f `cat *.tmps`
	rm -f *.tmps

stamp-%: %.t
	./build-$(@:stamp-%=%).sh
	touch $@

stamp-all: stamp-SetMap
	javac -source 1.4 *.java
	touch $@

check: all
	./test.sh

.PHONY: all clean check
