include ../makefile.in

GCC_OPT = -Wall -lm -O3 -Wno-unused-result -Werror ${CFLAGS}
# -lm raczej niepotrzebne, see https://stackoverflow.com/questions/1033898/why-do-you-have-to-link-the-math-library-in-c/1033940#1033940
GPP_OPT = -Wall -lm -O3 -Wno-unused-result -Werror -std=c++20 ${CXXFLAGS}
PPC_OPT = -O2 -XS -Xt -Ci -Cr -Co -gl ${PASFLAGS}

PRG_C 	= $(wildcard *.c)
PRG_CPP = $(wildcard *.cpp)
PRG_JAVA = $(wildcard *.java)
PRG_PAS = $(wildcard *.pas)
PRG_ML  = $(wildcard *.ml)
PRG_PY  = $(wildcard *.py)
PRG     = $(PRG_C) $(PRG_CPP) $(PRG_PAS) $(PRG_ML) $(PRG_PY)


EXE_C   = $(patsubst %.c,%.e,$(PRG_C))
EXE_CPP = $(patsubst %.cpp,%.e,$(PRG_CPP))
EXE_JAVA = $(patsubst %.java,%.e,$(PRG_JAVA))
exe_pas = $(patsubst %.pas,%.e,$(prg_pas))
EXE_PY  = $(patsubst %.py,%.e,$(PRG_PY))
EXE_ML  = $(patsubst %.ml,%.e,$(PRG_ML))
EXE     = $(EXE_C) $(EXE_CPP) $(EXE_JAVA) $(EXE_PAS) $(EXE_ML) $(EXE_PY)

all: $(EXE) ${ID}.valgrind

%.e: %.py
	echo "#!/usr/bin/python3" > $*.e
	cat $*.py >> $*.e
	chmod +x $*.e
	py3compile $*.py

%.e: %.pas
	fpc $(PPC_OPT) $*.pas ${PAS_LDFLAGS}
	mv $* $*.e

%.e: %.c
	gcc $(GCC_OPT) $^ -o $*.e ${C_LDFLAGS}

%.e: %.cpp
	g++ $(GPP_OPT) $^ -o $*.e ${CXX_LDFLAGS}

#-Xmx$$MEM -Xms$$MEM -Xss$$MEM
%.e: %.java
	javac $(JAVA_OPT) $^
	MEM=$$(($(MEMLIMIT) / 1000))M; \
	echo "ulimit -v unlimited ; java -client -cp \`dirname \$$0\` $*" > $*.e
	chmod 755 $*.e

%.e: %.ml
	ocamlopt $^ -o $*.e
	rm -f *.cmx
	rm -f *.cmi
	rm -f *.cmo

%.valgrind: %.c
	gcc -O2 ${CFLAGS} -g -lm $^ -o $*.valgrind ${C_LDFLAGS}

%.valgrind: %.cpp
	g++ -O2 -std=c++17 ${CXXFLAGS} -g -lm $^ -o $*.valgrind ${CXX_LDFLAGS}

%.valgrind: %.pas %.e
	cp $*.e $*.valgrind

clean:
	rm -f *.o
	rm -f *.e
	rm -f *.valgrind
	rm -f *~
	rm -f *.class
	rm -f *.cmx
	rm -f *.cmi
	rm -f *.cmo
	rm -f *.so
	rm -f *.pyc
	rm -f *wrap*
	rm -f *JNI*
	rm -f *.log

-include makefile.user
