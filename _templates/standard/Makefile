#
# Package Makefile.
# Authors: Tomasz Walen, Rafal Rusin, Adam Iwanicki.
#

VERSION = 1.24

SHELL := /bin/bash -O extglob

include makefile.in

BIN_TIME = /usr/bin/time
TMP1     = .__tmp_1__~
TMP2     = .__tmp_2__~
TMP3     = .__tmp_3__~
TMP4     = .__tmp_4__~
MD5SUMS  = in/.md5sums

INGEN    = $(shell if [ `find prog -name "$(ID)ingen.*" | wc -l` -gt 0 ] ; then echo 1 ; else echo 0 ; fi)
INWER    = $(shell if [ `find prog -name "$(ID)inwer.*" | wc -l` -gt 0 ] ; then echo 1 ; else echo 0 ; fi)
CHECKER  = $(shell if [ `find prog -name "$(ID)chk.*" | wc -l` -gt 0 ] ; then echo 1 ; else echo 0 ; fi)
PROGS_OPT= $(shell find prog -regex "prog/$(ID)[0-9]*\.\(c\|cpp\|pas\|py\|ml\)" | sort -n -k 1.`echo "prog/$(ID)"| wc -c`)
PROGS_SLW= $(shell find prog -regex "prog/$(ID)s[0-9]*\.\(c\|cpp\|pas\|py\|ml\)" | sort -n -k 1.`echo "prog/$(ID)s"| wc -c`)
PROGS_BAD= $(shell find prog -regex "prog/$(ID)b[0-9]*\.\(c\|cpp\|pas\|py\|ml\)" | sort -n -k 1.`echo "prog/$(ID)b"| wc -c`)
PROGS_JAVA= $(shell find prog -regex "prog/$(ID)[0-9]*\.java" | sort -n -k 1.`echo "prog/$(ID)"| wc -c`)
PROGS_JAVA_SLW= $(shell find prog -regex "prog/$(ID)s[0-9]*\.java" | sort -n -k 1.`echo "prog/$(ID)"| wc -c`)
TESTS   += $(shell find in -regex "in/$(ID)[0-9]*[a-z]?ocen.in" | sort -n -k 1.`echo "in/$(ID)"| wc -c` )
TESTS   += $(shell find in -regex "in/$(ID)[0-9]*[a-z]?.in" | sort -n -k 1.`echo "in/$(ID)"| wc -c` )

B_PROGS_WER= $(shell find prog -regex "prog/$(ID)[0-9]*wer[0-9]*\.\(c\|cpp\|pas\|py\|ml\|java\)" | sort -n -k 1.`echo "prog/$(ID)"| wc -c`)
B_PROGS_SLW= $(shell find prog -regex "prog/$(ID)[0-9]*s\.\(c\|cpp\|pas\|py\|ml\|java\)" | sort -n -k 1.`echo "prog/$(ID)"| wc -c`)
B_PROGS_BAD= $(shell find prog -regex "prog/$(ID)[0-9]*b\.\(c\|cpp\|pas\|py\|ml\|java\)" | sort -n -k 1.`echo "prog/$(ID)"| wc -c`)

.PHONY : clean clean-gen export verify tgz run inwer outgen verify_limits verify_names info report quickver ingen_md5

all:
	# Podaj konkretny cel #

export:
	## Przygotowanie paczki dla SInOl'a ##
	make -C doc
	make -C prog
	make clean-gen
	make clean
	@touch "$(SIG).tgz" # Fix "file changed when we read it" error on first generation
	tar cvzf $(SIG).tgz --exclude "$(ID)/$(SIG).tgz" ../$(ID)


_sinol3_export:
	## Przygotowanie paczki dla SInOl'a ##
	make outgen
	make -C doc
	make -C prog
	make clean-gen
	make clean
	mkdir -p $(ID)
	mv !($(ID)) $(ID)/

_sinol3_get_oiejq:
	wget https://oi.edu.pl/static/attachment/20181007/oiejq.tar.gz
	tar -xvf oiejq.tar.gz
	chmod +x oiejq/oiejq.sh
	sed -i '/OI_TIME/c\OI_TIME = oiejq/oiejq.sh' makefile.in
	cat makefile.in

run:
	## Uruchomienie rozwiazania wzorcowego ##
	make _run_ver_n_$(ID).e

oirun:
	## Uruchomienie rozwiazania wzorcowego ##
	make _oirun_ver_n_$(ID).e

run_%:
	make _run_ver_n_$(ID)$*.e

oirun_%:
	make _oirun_ver_n_$(ID)$*.e

jrun_%:
	make _jrun_ver_n_$(ID)$*.e

verify: clean verify_$(MODE)

quickver:
	@make verify QUICK=1

verify_red:
	## Automatyczna weryfikacja redacji ##
	make -s "_verify_doc_$(ID)zad.tex"
	make -C doc all

info:
	## Wersja makefile'a $(VERSION) ##
	## Informacje o procesorze ##
	@cat /proc/cpuinfo
	@(ulimit -a)
	@free
	@if which mpstat >/dev/null ; then mpstat -P ALL; fi

verify_limits:
	## Automatyczna weryfikacja limitow ##
	##
	## TIMELIMIT:      $(TIMELIMIT)
	## SLOW_TIMELIMIT: $(SLOW_TIMELIMIT)
	## MEMLIMIT:       $(MEMLIMIT)
	##
	$(if $(TIMELIMIT),,$(error Brak ustawionego TIMELIMITu.))
	$(if $(SLOW_TIMELIMIT),,$(error Brak ustawionego SLOW_TIMELIMITu.))
	$(if $(MEMLIMIT),,$(error Brak ustawionego MEMLIMITu.))
	$(if $(shell if [ $(TIMELIMIT) -le 60 ]; then echo OK; fi),,$(error Za duzy TIMELIMIT: $(TIMELIMIT)))
	$(if $(shell if [ $(SLOW_TIMELIMIT) -le 120 ]; then echo OK; fi),,$(error Za duzy SLOW_TIMELIMIT: $(SLOW_TIMELIMIT)))
	$(if $(shell if [ $(MEMLIMIT) -le 512000 ]; then echo OK; fi),,$(error Za duzy MEMLIMIT: $(MEMLIMIT)))


verify_names:
	## Automatyczna weryfikacja nazw programow ##
	$(if $(B_PROGS_BAD), $(error Niewlasciwe nazwy programow blednych ($(B_PROGS_BAD)). Nazwy powinny sie zaczynac od $(ID)b),)
	$(if $(B_PROGS_SLW), $(error Niewlasciwe nazwy programow wolnych ($(B_PROGS_SLW)). Nazwy powinny sie zaczynac od $(ID)s),)
	$(if $(B_PROGS_WER), $(error Niewlasciwe nazwy programow weryfikujacych ($(B_PROGS_WER)). Prosze nadac im nazwy zgodnie z typem $(ID), $(ID)s lub $(ID)b),)


report:
	@make -s -C prog
	@printf "<html> \n\
		<head> \n\
		<title>$(ID) - Raport</title> \n\
		<style> \n\
		.OK { background-color: lightgreen } \n\
		.WRONG_ANSWER {background-color: red } \n\
		.TIMEOUT {background-color: yellow } \n\
		.RTE { background-color: blue } \n\
		.RT_TIMEOUT { background-color: black; color: white } \n\
		.c {background-color: lightgreen} \n\
		.cpp {background-color: lightgreen} \n\
		.java {background-color: yellow} \n\
		.pas {background-color: lightblue} \n\
		.py {background-color: orange} \n\
		TD {text-align: center} \n\
		</style> \n\
		<pre>\n"
	@echo "</pre>"
	@printf "<h1>Raport</h1> \n\
		<h3>Legenda</h3> \n\
		<ul><li>* - przy nazwie testu oznacza test typu ocen</li> \n\
		<li> kolor zielony oznacza poprawne zakonczenie programu</li> \n\
		<li> kolor zolty oznacza przekroczenie limitu czasu</li> \n\
		<li> kolor czerwony oznacza nieprawidlowa odpowiedz</li> \n\
		<li> kolor niebieski oznacza blad wykonania</ul>"
	@echo "<table><tr><th>lang</th><th>progname</th>"
	@for i in $(TESTS); do echo "<th>`echo -n $$i | sed -e 's/ocen/*/' -e 's/in\/$(ID)//' -e 's/.in//'`</th>"; done
	@echo "</tr>"
	@for i in $(PROGS_OPT); do j=`basename $$i`; if ! make -s _run_rep_o_$$j; then exit 1; fi; done
	@for i in $(PROGS_JAVA); do j=`basename $$i`; if ! make -s _jrun_rep_o_$$j; then exit 1; fi; done
	@for i in $(PROGS_SLW); do j=`basename $$i`; if ! make -s _run_rep_s_$$j; then exit 1; fi; done
	@for i in $(PROGS_JAVA_SLW); do j=`basename $$i`; if ! make -s _jrun_rep_s_$$j; then exit 1; fi; done
	@for i in $(PROGS_BAD); do j=`basename $$i`; if ! make -s _run_rep_o_$$j; then exit 1; fi; done
	@for i in $(PROGS_WER); do j=`basename $$i`; if ! make -s _run_rep_o_$$j; then exit 1; fi; done
	@printf "</table>\n</body>\n</html>\n"

oireport:
	@make -s -C prog
	@printf "<html> \n\
		<head> \n\
		<title>$(ID) - Raport</title> \n\
		<style> \n\
		.OK { background-color: lightgreen } \n\
		.WRONG_ANSWER {background-color: red } \n\
		.TIMEOUT {background-color: yellow } \n\
		.RTE { background-color: blue } \n\
		.RT_TIMEOUT { background-color: black; color: white } \n\
		.c {background-color: lightgreen} \n\
		.cpp {background-color: lightgreen} \n\
		.java {background-color: yellow} \n\
		.pas {background-color: lightblue} \n\
		.py {background-color: orange} \n\
		TD {text-align: center} \n\
		</style> \n\
		<pre>\n"
	@echo "</pre>"
	@printf "<h1>Raport</h1> \n\
		<h3>Legenda</h3> \n\
		<ul><li>* - przy nazwie testu oznacza test typu ocen</li> \n\
		<li> kolor zielony oznacza poprawne zakonczenie programu</li> \n\
		<li> kolor zolty oznacza przekroczenie limitu czasu</li> \n\
		<li> kolor czerwony oznacza nieprawidlowa odpowiedz</li> \n\
		<li> kolor niebieski oznacza blad wykonania</ul>"
	@echo "<table><tr><th>lang</th><th>progname</th>"
	@for i in $(TESTS); do echo "<th>`echo -n $$i | sed -e 's/ocen/*/' -e 's/in\/$(ID)//' -e 's/.in//'`</th>"; done
	@echo "</tr>"
	@for i in $(PROGS_OPT); do j=`basename $$i`; if ! make -s _oirun_rep_o_$$j; then exit 1; fi; done
	@for i in $(PROGS_SLW); do j=`basename $$i`; if ! make -s _oirun_rep_s_$$j; then exit 1; fi; done
	@for i in $(PROGS_BAD); do j=`basename $$i`; if ! make -s _oirun_rep_o_$$j; then exit 1; fi; done
	@for i in $(PROGS_WER); do j=`basename $$i`; if ! make -s _oirun_rep_o_$$j; then exit 1; fi; done
	@printf "</table>\n</body>\n</html>\n"

verify_opr: info verify_red verify_limits verify_names
	## Automatyczna weryfikacja opracowania ##
	make -s "_verify_doc_$(ID)opr.tex"
	make -C doc all
	make -C prog all
	make ingen
	make ingen_md5
	make inwer
	make outgen
	@for i in `echo $(PROGS_OPT)`; do j="`basename $$i`"; j="`(echo $$j) | rev | cut -d. -f2- | rev`.e"; if ! make _run_ver_o_$$j; then exit 1; fi; done
	@for i in `echo $(PROGS_SLW)`; do j="`basename $$i`"; j="`(echo $$j) | rev | cut -d. -f2- | rev`.e"; if ! make _run_ver_s_$$j; then exit 1; fi; done
ifndef QUICK
	make report
	make valgrind
endif

oiverify_opr: info verify_red verify_limits verify_names
	## Automatyczna weryfikacja opracowania ##
	make -s "_verify_doc_$(ID)opr.tex"
	make -C doc all
	make -C prog all
	make ingen
	make ingen_md5
	make inwer
	make outgen
	@for i in `echo $(PROGS_OPT)`; do j="`basename $$i`"; j="`(echo $$j) | rev | cut -d. -f2- | rev`.e"; if ! make _oirun_ver_o_$$j; then exit 1; fi; done
	@for i in `echo $(PROGS_SLW)`; do j="`basename $$i`"; j="`(echo $$j) | rev | cut -d. -f2- | rev`.e"; if ! make _oirun_ver_s_$$j; then exit 1; fi; done
ifndef QUICK
	make oireport
	make valgrind
endif

verify_wer: verify_opr
	## Automatyczna weryfikacja weryfikacji ##
	make -s "_verify_doc_$(ID)wer.tex"

verify_tlu_%:
	## Automatyczne weryfikacja tlumaczenia ##
	make -s "_verify_doc_$(ID)zad-$*.tex"

verify_tlu: verify_red

_verify_in_%:
	@if [ ! -f "in/$*" ] ; then echo Brak pliku in/$* ; exit 1 ; fi

_verify_out_%:
	@if [ ! -f "out/$*" ] ; then echo Brak pliku out/$* ; exit 1 ; fi

_verify_prog_%:
	@if [ ! -f "prog/$*" ] ; then echo Brak pliku prog/$* ; exit 1 ; fi

_verify_doc_%:
	@if [ ! -f "doc/$*" ] ; then echo Brak pliku doc/$* ; exit 1 ; fi
	make -C doc -B $(patsubst %.tex,%.pdf,$*)

clean:
	rm -f *~
	make -C doc clean
	make -C prog clean

######################################################################
# Usuniecie testow genereowanych automatycznie
######################################################################
clean-gen:
	@if [ "$(INGEN)" -eq 1 ] ; then \
		if [ -e in/tmp ]; then rm -r in/tmp; fi ; \
		mkdir in/tmp ; \
		if [ -f prog/$(ID)ingen.sh ] ; then \
			cd in/tmp ; ../../prog/$(ID)ingen.sh ; \
		else \
			make -C prog $(ID)ingen.e ; \
			cd in/tmp ; ../../prog/$(ID)ingen.e ; \
		fi ; \
		INGEN_FILES="`echo *.in`"; \
		cd ../.. ; \
		rm -r in/tmp ; \
		for i in $$INGEN_FILES; do \
			j=`basename $$i .in`; \
			echo Kasuje in/$$j.in; rm -f in/$$j.in; \
			echo Kasuje out/$$j.out; rm -f out/$$j.out; \
		done ;\
	fi

mrproper:
	make -C doc no_binaries
	@if [ "$(INGEN)" -eq 1 ] ; then \
	    make clean-gen ; \
	fi
	make -C prog clean
	@echo Usuwanie plikow OUT
	rm -f out/*

############################################################################
# Przygotowanie danych wejsciowych generowanych automatycznie
############################################################################
ingen:
	ulimit -s unlimited
	@if [ "$(INGEN)" -eq 1 ] ; then \
		if [ -f prog/$(ID)ingen.sh ] ; then \
			cd in ; ../prog/$(ID)ingen.sh ; \
		else \
			make -C prog $(ID)ingen.e ; \
			cd in ; ../prog/$(ID)ingen.e ; \
		fi ; \
	fi


############################################################################
# Weryfikacja losowosci danych wejsciowych
############################################################################
ingen_md5: $(MD5SUMS)
	## Weryfikacja zgodnosci wygenerowanych danych wejsciowych
	##
	## Na komputerze uzytkownika pliki wejsciowe mialy nastepujace sumy kontrolne:
	@cat $(MD5SUMS)
	@md5sum -c $(MD5SUMS) || echo -n

############################################################################
# Weryfikacja poprawnosci danych wejsciowych
############################################################################
inwer:
	ulimit -s unlimited
	@if [ "$(INWER)" -eq 1 ] ; then \
		make -C prog $(ID)inwer.e ; \
		for i in $(TESTS) ; do \
			printf "%-11s ... " `basename $$i` ; \
			if ! prog/$(ID)inwer.e < $$i ;  then \
				echo "ZLE!!!" ; \
				exit 1 ; \
			fi ; \
		done ; \
	else \
		echo "Brak weryfikatora do testow" ; \
		exit 2 ; \
	fi
	@md5sum in/* > $(MD5SUMS)


############################################################################
# Wygenerowanie wzorcowych odpowiedzi dla biezacego zestawu testow
############################################################################
outgen:
	ulimit -s unlimited
	make -C prog $(ID).e
	@for i in $(TESTS) ; do \
	    printf "%-11s ... " `basename $$i` ; \
	    prog/$(ID).e < $$i > out/`basename $$i .in`.out ; \
	    echo OK ; \
	done


############################################################################
# Uruchomienie programu prog/$(ID)%.e na biezacym zestawie testow
# Ustawienie zmiennej ACC_TERM na 1 powoduje, ze wywlaszczane testy
# sa uwazane za OK.
# Ustawienie STOP_ON_WRONG na 1 powoduje przerwanie po napotkaniu
# testu, ktorego program nie przechodzi
############################################################################
_run_ver_n_%:
	make -s -C prog $*
	@if [ "$(CHECKER)" -eq "1" ] ; then make -C prog $(ID)chk.e ; fi
	@ACC_TERM=0;\
	STOP_ON_WRONG=0;\
	T_LIMIT=$(TIMELIMIT);\
	RT_LIMIT=$$(($(TIMELIMIT) * 10 + 100)); \
	PID='';\
	function sig_handler() { \
		if [ -n "$$PID" ]; then \
			kill -SIGKILL -$$PID >/dev/null 2>&1; \
			wait $$PID >/dev/null 2>&1; \
		fi; \
	}; \
	trap sig_handler SIGINT ; \
	for i in $(TESTS) ; do \
		j=out/`basename $$i .in`.out ; \
		\
		printf "%-11s " `basename $$i` ; \
		\
		rm -f $(TMP3);\
		rm -f $(TMP1);\
		setsid bash -c "ulimit -v $(MEMLIMIT); ulimit -t $$T_LIMIT ; \
				$(BIN_TIME) -f \"%U\" -o $(TMP2) prog/$* <$$i >$(TMP1)" >/dev/null 2>&1 & \
		PID=$$!; \
		setsid bash -c "sleep $$RT_LIMIT && kill -SIGKILL -$$PID" >/dev/null 2>&1 & \
		S_PID=$$!; \
		while ! kill -0 -$$S_PID >/dev/null 2>&1; do true; done; \
		wait $$PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then echo "OK" >$(TMP3); else echo "STOPPED" >$(TMP3); fi; \
		if [ "`cat $(TMP3)`" = OK ]; then TERM=0; else TERM=1; fi;\
		rm -f $(TMP3);\
		kill -SIGKILL -$$S_PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then TIMEOUT=0; else TIMEOUT=1; TERM=1; echo "$$RT_LIMIT.00" > $(TMP2); fi;\
		wait $$S_PID >/dev/null 2>&1; \
		TIME=`cat $(TMP2)` ; echo -n "$$TIME " ; \
		\
		if [ $$TERM -eq 0 ]; then \
			if [ "$(CHECKER)" -eq "1" ] ; then \
				prog/$(ID)chk.e $$i $(TMP1) $$j > $(TMP2) ; \
				RES=`head -n 1 $(TMP2)` ; \
				COMMENT=`head -n 2 $(TMP2) | tail -n 1` ; \
				if [ "$$RES" != "OK" ] ; then RES="WRONG_ANSWER" ; fi ; \
			else \
				if diff -Z -q $$j $(TMP1) > /dev/null ; then \
					RES="OK" ; \
				else \
					RES="WRONG_ANSWER" ; \
				fi ; \
				COMMENT="" ; \
			fi ; \
		fi; \
		if [ $$TERM -eq 1 ]; then RES="WRONG (TIMEOUT)"; fi; \
		if [ $$TERM -eq 1 ] && [ "$$ACC_TERM" = 1 ]; then RES="OK"; fi; \
		if [ $$TIMEOUT -eq 1 ]; then RES="\x1b[31m!REAL TIMEOUT!\x1b[0m"; fi; \
		printf "$$RES $$COMMENT\n" ; \
		rm -f $(TMP1) $(TMP2) ; \
		if [ "$$RES" != "OK" ] && [ "$$STOP_ON_WRONG" = 1 ]; then exit 1; fi;\
	done

_oirun_ver_n_%:
	make -s -C prog $*
	@if [ "$(CHECKER)" -eq "1" ] ; then make -C prog $(ID)chk.e ; fi
	@ACC_TERM=0;\
	STOP_ON_WRONG=0;\
	T_LIMIT=$(TIMELIMIT);\
	RT_LIMIT=$$(($(TIMELIMIT) * 10 + 100)); \
	PID='';\
	function sig_handler() { \
		if [ -n "$$PID" ]; then \
			kill -SIGKILL -$$PID >/dev/null 2>&1; \
			wait $$PID >/dev/null 2>&1; \
		fi; \
	}; \
	trap sig_handler SIGINT ; \
	for i in $(TESTS) ; do \
		j=out/`basename $$i .in`.out ; \
		\
		printf "%-11s " `basename $$i` ; \
		\
		rm -f $(TMP3);\
		rm -f $(TMP1);\
		setsid bash -c "ulimit -v $(MEMLIMIT); ulimit -t $$T_LIMIT ; \
				$(OI_TIME) ./prog/$* <$$i >$(TMP1) 2>$(TMP2)" >/dev/null 2>&1 & \
		PID=$$!; \
		setsid bash -c "sleep $$RT_LIMIT && kill -SIGKILL -$$PID" >/dev/null 2>&1 & \
		S_PID=$$!; \
		while ! kill -0 -$$S_PID >/dev/null 2>&1; do true; done; \
		wait $$PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then echo "OK" >$(TMP3); else echo "STOPPED" >$(TMP3); fi; \
		if [ "`cat $(TMP3)`" = OK ]; then TERM=0; else TERM=1; fi;\
		rm -f $(TMP3);\
		kill -SIGKILL -$$S_PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then TIMEOUT=0; else TIMEOUT=1; TERM=1; echo "$$RT_LIMIT.00" > $(TMP2); fi;\
		wait $$S_PID >/dev/null 2>&1; \
    cat $(TMP2) | tail -n 1 | cut -d ' ' -f 2 | cut -d 's' -f 1 > $(TMP4); mv $(TMP4) $(TMP2); \
		TIME=`cat $(TMP2)` ; echo -n "$$TIME " ; \
		\
		if [ $$TERM -eq 0 ]; then \
			if [ "$(CHECKER)" -eq "1" ] ; then \
				prog/$(ID)chk.e $$i $(TMP1) $$j > $(TMP2) ; \
				RES=`head -n 1 $(TMP2)` ; \
				COMMENT=`head -n 2 $(TMP2) | tail -n 1` ; \
				if [ "$$RES" != "OK" ] ; then RES="WRONG_ANSWER" ; fi ; \
			else \
				if diff -Z -q $$j $(TMP1) > /dev/null ; then \
					RES="OK" ; \
				else \
					RES="WRONG_ANSWER" ; \
				fi ; \
				COMMENT="" ; \
			fi ; \
		fi; \
		if [ $$TERM -eq 1 ]; then RES="WRONG (TIMEOUT)"; fi; \
		if [ $$TERM -eq 1 ] && [ "$$ACC_TERM" = 1 ]; then RES="OK"; fi; \
		if [ $$TIMEOUT -eq 1 ]; then RES="\x1b[31m!REAL TIMEOUT!\x1b[0m"; fi; \
		printf "$$RES $$COMMENT\n" ; \
		rm -f $(TMP1) $(TMP2) ; \
		if [ "$$RES" != "OK" ] && [ "$$STOP_ON_WRONG" = 1 ]; then exit 1; fi;\
	done

_jrun_ver_n_%:
	make -s -C prog $*
	@if [ "$(CHECKER)" -eq "1" ] ; then make -C prog $(ID)chk.e ; fi
	@ACC_TERM=0;\
	STOP_ON_WRONG=0;\
	T_LIMIT=$(TIMELIMIT);\
	RT_LIMIT=$$(($(TIMELIMIT) * 10 + 100)); \
	PID='';\
	function sig_handler() { \
		if [ -n "$$PID" ]; then \
			kill -SIGKILL -$$PID >/dev/null 2>&1; \
			wait $$PID >/dev/null 2>&1; \
		fi; \
	}; \
	trap sig_handler SIGINT ; \
	for i in $(TESTS) ; do \
		j=out/`basename $$i .in`.out ; \
		\
		printf "%-11s " `basename $$i` ; \
		\
		rm -f $(TMP3);\
		rm -f $(TMP1);\
		setsid bash -c "$(BIN_TIME) -f \"%U\" -o $(TMP2) prog/$* <$$i >$(TMP1)" >/dev/null 2>&1 & \
		PID=$$!; \
		setsid bash -c "sleep $$RT_LIMIT && kill -SIGKILL -$$PID" >/dev/null 2>&1 & \
		S_PID=$$!; \
		while ! kill -0 -$$S_PID >/dev/null 2>&1; do true; done; \
		wait $$PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then echo "OK" >$(TMP3); else echo "STOPPED" >$(TMP3); fi; \
		if [ "`cat $(TMP3)`" = OK ]; then TERM=0; else TERM=1; fi;\
		rm -f $(TMP3);\
		kill -SIGKILL -$$S_PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then TIMEOUT=0; else TIMEOUT=1; TERM=1; echo "$$RT_LIMIT.00" > $(TMP2); fi;\
		wait $$S_PID >/dev/null 2>&1; \
		TIME=`cat $(TMP2)` ; echo -n "$$TIME " ; \
		\
		if [ $$TERM -eq 0 ]; then \
			if [ "$(CHECKER)" -eq "1" ] ; then \
				prog/$(ID)chk.e $$i $(TMP1) $$j > $(TMP2) ; \
				RES=`head -n 1 $(TMP2)` ; \
				COMMENT=`head -n 2 $(TMP2) | tail -n 1` ; \
				if [ "$$RES" != "OK" ] ; then RES="WRONG_ANSWER" ; fi ; \
			else \
				if diff -Z -q $$j $(TMP1) > /dev/null ; then \
					RES="OK" ; \
				else \
					RES="WRONG_ANSWER" ; \
				fi ; \
				COMMENT="" ; \
			fi ; \
		fi; \
		if [ $$TERM -eq 1 ]; then RES="WRONG (TIMEOUT)"; fi; \
		if [ $$TERM -eq 1 ] && [ "$$ACC_TERM" = 1 ]; then RES="OK"; fi; \
		if [ $$TIMEOUT -eq 1 ]; then RES="\x1b[31m!REAL TIMEOUT!\x1b[0m"; fi; \
		printf "$$RES $$COMMENT\n" ; \
		rm -f $(TMP1) $(TMP2) ; \
		if [ "$$RES" != "OK" ] && [ "$$STOP_ON_WRONG" = 1 ]; then exit 1; fi;\
	done

_run_ver_o_%:
	make -s -C prog $*
	@if [ "$(CHECKER)" -eq "1" ] ; then make -C prog $(ID)chk.e ; fi
	@ACC_TERM=0;\
	STOP_ON_WRONG=1;\
	T_LIMIT=$(TIMELIMIT);\
	RT_LIMIT=$$(($(TIMELIMIT) * 10 + 100)); \
	PID='';\
	function sig_handler() { \
		if [ -n "$$PID" ]; then \
			kill -SIGKILL -$$PID >/dev/null 2>&1; \
			wait $$PID >/dev/null 2>&1; \
		fi; \
	}; \
	trap sig_handler SIGINT ; \
	for i in $(TESTS) ; do \
		j=out/`basename $$i .in`.out ; \
		\
		printf "%-11s " `basename $$i` ; \
		\
		rm -f $(TMP3);\
		rm -f $(TMP1);\
		setsid bash -c "ulimit -v $(MEMLIMIT); ulimit -t $$T_LIMIT ; \
				$(BIN_TIME) -f \"%U\" -o $(TMP2) prog/$* <$$i >$(TMP1)" >/dev/null 2>&1 & \
		PID=$$!; \
		setsid bash -c "sleep $$RT_LIMIT && kill -SIGKILL -$$PID" >/dev/null 2>&1 & \
		S_PID=$$!; \
		while ! kill -0 -$$S_PID >/dev/null 2>&1; do true; done; \
		wait $$PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then echo "OK" >$(TMP3); else echo "STOPPED" >$(TMP3); fi; \
		if [ "`cat $(TMP3)`" = OK ]; then TERM=0; else TERM=1; fi;\
		rm -f $(TMP3);\
		kill -SIGKILL -$$S_PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then TIMEOUT=0; else TIMEOUT=1; TERM=1; echo "$$RT_LIMIT.00" > $(TMP2); fi;\
		wait $$S_PID >/dev/null 2>&1; \
		TIME=`cat $(TMP2)` ; echo -n "$$TIME " ; \
		\
		if [ $$TERM -eq 0 ]; then \
			if [ "$(CHECKER)" -eq "1" ] ; then \
				prog/$(ID)chk.e $$i $(TMP1) $$j > $(TMP2) ; \
				RES=`head -n 1 $(TMP2)` ; \
				COMMENT=`head -n 2 $(TMP2) | tail -n 1` ; \
				if [ "$$RES" != "OK" ] ; then RES="WRONG_ANSWER" ; fi ; \
			else \
				if diff -Z -q $$j $(TMP1) > /dev/null ; then \
					RES="OK" ; \
				else \
					RES="WRONG_ANSWER" ; \
				fi ; \
				COMMENT="" ; \
			fi ; \
		fi; \
		if [ $$TERM -eq 1 ]; then RES="WRONG (TIMEOUT)"; fi; \
		if [ $$TERM -eq 1 ] && [ "$$ACC_TERM" = 1 ]; then RES="OK"; fi; \
		if [ $$TIMEOUT -eq 1 ]; then RES="\x1b[31m!REAL TIMEOUT!\x1b[0m"; fi; \
		printf "$$RES $$COMMENT\n" ; \
		rm -f $(TMP1) $(TMP2) ; \
		if [ "$$RES" != "OK" ] && [ "$$STOP_ON_WRONG" = 1 ]; then exit 1; fi;\
	done

_jrun_ver_o_%:
	make -s -C prog $*
	@if [ "$(CHECKER)" -eq "1" ] ; then make -C prog $(ID)chk.e ; fi
	@ACC_TERM=0;\
	STOP_ON_WRONG=1;\
	T_LIMIT=$(TIMELIMIT);\
	RT_LIMIT=$$(($(TIMELIMIT) * 10 + 100)); \
	PID='';\
	function sig_handler() { \
		if [ -n "$$PID" ]; then \
			kill -SIGKILL -$$PID >/dev/null 2>&1; \
			wait $$PID >/dev/null 2>&1; \
		fi; \
	}; \
	trap sig_handler SIGINT ; \
	for i in $(TESTS) ; do \
		j=out/`basename $$i .in`.out ; \
		\
		printf "%-11s " `basename $$i` ; \
		\
		rm -f $(TMP3);\
		rm -f $(TMP1);\
		setsid bash -c "ulimit -t $$T_LIMIT ; \
				$(BIN_TIME) -f \"%U\" -o $(TMP2) prog/$* <$$i >$(TMP1)" >/dev/null 2>&1 & \
		PID=$$!; \
		setsid bash -c "sleep $$RT_LIMIT && kill -SIGKILL -$$PID" >/dev/null 2>&1 & \
		S_PID=$$!; \
		while ! kill -0 -$$S_PID >/dev/null 2>&1; do true; done; \
		wait $$PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then echo "OK" >$(TMP3); else echo "STOPPED" >$(TMP3); fi; \
		if [ "`cat $(TMP3)`" = OK ]; then TERM=0; else TERM=1; fi;\
		rm -f $(TMP3);\
		kill -SIGKILL -$$S_PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then TIMEOUT=0; else TIMEOUT=1; TERM=1; echo "$$RT_LIMIT.00" > $(TMP2); fi;\
		wait $$S_PID >/dev/null 2>&1; \
		TIME=`cat $(TMP2)` ; echo -n "$$TIME " ; \
		\
		if [ $$TERM -eq 0 ]; then \
			if [ "$(CHECKER)" -eq "1" ] ; then \
				prog/$(ID)chk.e $$i $(TMP1) $$j > $(TMP2) ; \
				RES=`head -n 1 $(TMP2)` ; \
				COMMENT=`head -n 2 $(TMP2) | tail -n 1` ; \
				if [ "$$RES" != "OK" ] ; then RES="WRONG_ANSWER" ; fi ; \
			else \
				if diff -Z -q $$j $(TMP1) > /dev/null ; then \
					RES="OK" ; \
				else \
					RES="WRONG_ANSWER" ; \
				fi ; \
				COMMENT="" ; \
			fi ; \
		fi; \
		if [ $$TERM -eq 1 ]; then RES="WRONG (TIMEOUT)"; fi; \
		if [ $$TERM -eq 1 ] && [ "$$ACC_TERM" = 1 ]; then RES="OK"; fi; \
		if [ $$TIMEOUT -eq 1 ]; then RES="\x1b[31m!REAL TIMEOUT!\x1b[0m"; fi; \
		printf "$$RES $$COMMENT\n" ; \
		rm -f $(TMP1) $(TMP2) ; \
		if [ "$$RES" != "OK" ] && [ "$$STOP_ON_WRONG" = 1 ]; then exit 1; fi;\
	done

_run_ver_s_%:
	make -s -C prog $*
	@if [ "$(CHECKER)" -eq "1" ] ; then make -C prog $(ID)chk.e ; fi
	@ACC_TERM=1;\
	STOP_ON_WRONG=1;\
	T_LIMIT=$(SLOW_TIMELIMIT);\
	RT_LIMIT=$$(($(SLOW_TIMELIMIT) * 10 + 100)); \
	PID='';\
	function sig_handler() { \
		if [ -n "$$PID" ]; then \
			kill -SIGKILL -$$PID >/dev/null 2>&1; \
			wait $$PID >/dev/null 2>&1; \
		fi; \
	}; \
	trap sig_handler SIGINT ; \
	for i in $(TESTS) ; do \
		j=out/`basename $$i .in`.out ; \
		\
		printf "%-11s " `basename $$i` ; \
		\
		rm -f $(TMP3);\
		rm -f $(TMP1);\
		setsid bash -c "ulimit -v $(MEMLIMIT); ulimit -t $$T_LIMIT ; \
				$(BIN_TIME) -f \"%U\" -o $(TMP2) prog/$* <$$i >$(TMP1)" >/dev/null 2>&1 & \
		PID=$$!; \
		setsid bash -c "sleep $$RT_LIMIT && kill -SIGKILL -$$PID" >/dev/null 2>&1 & \
		S_PID=$$!; \
		while ! kill -0 -$$S_PID >/dev/null 2>&1; do true; done; \
		wait $$PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then echo "OK" >$(TMP3); else echo "STOPPED" >$(TMP3); fi; \
		if [ "`cat $(TMP3)`" = OK ]; then TERM=0; else TERM=1; fi;\
		rm -f $(TMP3);\
		kill -SIGKILL -$$S_PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then TIMEOUT=0; else TIMEOUT=1; TERM=1; echo "$$RT_LIMIT.00" > $(TMP2); fi;\
		wait $$S_PID >/dev/null 2>&1; \
		TIME=`cat $(TMP2)` ; echo -n "$$TIME " ; \
		\
		if [ $$TERM -eq 0 ]; then \
			if [ "$(CHECKER)" -eq "1" ] ; then \
				prog/$(ID)chk.e $$i $(TMP1) $$j > $(TMP2) ; \
				RES=`head -n 1 $(TMP2)` ; \
				COMMENT=`head -n 2 $(TMP2) | tail -n 1` ; \
				if [ "$$RES" != "OK" ] ; then RES="WRONG_ANSWER" ; fi ; \
			else \
				if diff -Z -q $$j $(TMP1) > /dev/null ; then \
					RES="OK" ; \
				else \
					RES="WRONG_ANSWER" ; \
				fi ; \
				COMMENT="" ; \
			fi ; \
		fi; \
		if [ $$TERM -eq 1 ]; then RES="WRONG (TIMEOUT)"; fi; \
		if [ $$TERM -eq 1 ] && [ "$$ACC_TERM" = 1 ]; then RES="OK"; fi; \
		if [ $$TIMEOUT -eq 1 ]; then RES="\x1b[31m!REAL TIMEOUT!\x1b[0m"; fi; \
		printf "$$RES $$COMMENT\n" ; \
		rm -f $(TMP1) $(TMP2) ; \
		if [ "$$RES" != "OK" ] && [ "$$STOP_ON_WRONG" = 1 ]; then exit 1; fi;\
	done

_jrun_ver_s_%:
	make -s -C prog $*
	@if [ "$(CHECKER)" -eq "1" ] ; then make -C prog $(ID)chk.e ; fi
	@ACC_TERM=1;\
	STOP_ON_WRONG=1;\
	T_LIMIT=$(SLOW_TIMELIMIT);\
	RT_LIMIT=$$(($(SLOW_TIMELIMIT) * 10 + 100)); \
	PID='';\
	function sig_handler() { \
		if [ -n "$$PID" ]; then \
			kill -SIGKILL -$$PID >/dev/null 2>&1; \
			wait $$PID >/dev/null 2>&1; \
		fi; \
	}; \
	trap sig_handler SIGINT ; \
	for i in $(TESTS) ; do \
		j=out/`basename $$i .in`.out ; \
		\
		printf "%-11s " `basename $$i` ; \
		\
		rm -f $(TMP3);\
		rm -f $(TMP1);\
		setsid bash -c "ulimit -t $$T_LIMIT ; \
				$(BIN_TIME) -f \"%U\" -o $(TMP2) prog/$* <$$i >$(TMP1)" >/dev/null 2>&1 & \
		PID=$$!; \
		setsid bash -c "sleep $$RT_LIMIT && kill -SIGKILL -$$PID" >/dev/null 2>&1 & \
		S_PID=$$!; \
		while ! kill -0 -$$S_PID >/dev/null 2>&1; do true; done; \
		wait $$PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then echo "OK" >$(TMP3); else echo "STOPPED" >$(TMP3); fi; \
		if [ "`cat $(TMP3)`" = OK ]; then TERM=0; else TERM=1; fi;\
		rm -f $(TMP3);\
		kill -SIGKILL -$$S_PID >/dev/null 2>&1; \
		if [ "0" -eq "$$?" ]; then TIMEOUT=0; else TIMEOUT=1; TERM=1; echo "$$RT_LIMIT.00" > $(TMP2); fi;\
		wait $$S_PID >/dev/null 2>&1; \
		TIME=`cat $(TMP2)` ; echo -n "$$TIME " ; \
		\
		if [ $$TERM -eq 0 ]; then \
			if [ "$(CHECKER)" -eq "1" ] ; then \
				prog/$(ID)chk.e $$i $(TMP1) $$j > $(TMP2) ; \
				RES=`head -n 1 $(TMP2)` ; \
				COMMENT=`head -n 2 $(TMP2) | tail -n 1` ; \
				if [ "$$RES" != "OK" ] ; then RES="WRONG_ANSWER" ; fi ; \
			else \
				if diff -Z -q $$j $(TMP1) > /dev/null ; then \
					RES="OK" ; \
				else \
					RES="WRONG_ANSWER" ; \
				fi ; \
				COMMENT="" ; \
			fi ; \
		fi; \
		if [ $$TERM -eq 1 ]; then RES="WRONG (TIMEOUT)"; fi; \
		if [ $$TERM -eq 1 ] && [ "$$ACC_TERM" = 1 ]; then RES="OK"; fi; \
		if [ $$TIMEOUT -eq 1 ]; then RES="\x1b[31m!REAL TIMEOUT!\x1b[0m"; fi; \
		printf "$$RES $$COMMENT\n" ; \
		rm -f $(TMP1) $(TMP2) ; \
		if [ "$$RES" != "OK" ] && [ "$$STOP_ON_WRONG" = 1 ]; then exit 1; fi;\
	done


define get_rep_result
	PID=$$!; \
	setsid bash -c "sleep $$RT_LIMIT && kill -SIGKILL -$$PID" >/dev/null 2>&1 & \
	S_PID=$$!; \
	while ! kill -0 -$$S_PID >/dev/null 2>&1; do true; done; \
	wait $$PID >/dev/null 2>&1; \
	RES=$$?; \
	kill -SIGKILL -$$S_PID >/dev/null 2>&1; \
	if [ "0" -eq "$$?" ]; then TIMEOUT=0; else TIMEOUT=1; TERM=1; echo "$$RT_LIMIT.00" > $(TMP2); fi;\
	wait $$S_PID >/dev/null 2>&1; \
	TIME=`cat $(TMP2)`; \
	\
	if [ "$$RES" -eq "0" ]; then \
		if [ "$(CHECKER)" -eq "1" ] ; then \
			prog/$(ID)chk.e $$i $(TMP1) $$j > $(TMP2) ; \
			RES=`head -n 1 $(TMP2)` ; \
			if [ "$$RES" != "OK" ] ; then RES="WRONG_ANSWER" ; fi ; \
		else \
			if diff -Z -q $$j $(TMP1) > /dev/null ; then \
				RES="OK" ; \
			else \
				RES="WRONG_ANSWER" ; \
			fi ; \
		fi ; \
	elif [ "$$TIMEOUT" -eq "1" ]; then \
		RES="RT_TIMEOUT"; \
		TIME=$$RT_LIMIT; \
	elif [ "$$RES" -eq "137" ]; then \
		RES="TIMEOUT"; \
		TIME=$$T_LIMIT; \
	else \
	  RES="RTE"; \
		TIME=`tail -n 1 $(TMP2)`; \
	fi; \
	rm -f $(TMP1) $(TMP2) ; \
	\
	printf "<td class=\"%s\">%ss</td>\n" "$$RES" "$$TIME"
endef

define get_oirep_result
	PID=$$!; \
	setsid bash -c "sleep $$RT_LIMIT && kill -SIGKILL -$$PID" >/dev/null 2>&1 & \
	S_PID=$$!; \
	while ! kill -0 -$$S_PID >/dev/null 2>&1; do true; done; \
	wait $$PID >/dev/null 2>&1; \
	RES=$$?; \
	kill -SIGKILL -$$S_PID >/dev/null 2>&1; \
	if [ "0" -eq "$$?" ]; then TIMEOUT=0; else TIMEOUT=1; TERM=1; echo "$$RT_LIMIT.00" > $(TMP2); fi;\
	wait $$S_PID >/dev/null 2>&1; \
  cat $(TMP2) | tail -n 1 | cut -d ' ' -f 2 | cut -d 's' -f 1 > $(TMP4); mv $(TMP4) $(TMP2); \
  TIME=`cat $(TMP2)`; \
	\
	if [ "$$RES" -eq "0" ]; then \
		if [ "$(CHECKER)" -eq "1" ] ; then \
			prog/$(ID)chk.e $$i $(TMP1) $$j > $(TMP2) ; \
			RES=`head -n 1 $(TMP2)` ; \
			if [ "$$RES" != "OK" ] ; then RES="WRONG_ANSWER" ; fi ; \
		else \
			if diff -Z -q $$j $(TMP1) > /dev/null ; then \
				RES="OK" ; \
			else \
				RES="WRONG_ANSWER" ; \
			fi ; \
		fi ; \
	elif [ "$$TIMEOUT" -eq "1" ]; then \
		RES="RT_TIMEOUT"; \
		TIME=$$RT_LIMIT; \
	elif [ "$$RES" -eq "137" ]; then \
		RES="TIMEOUT"; \
		TIME=$$T_LIMIT; \
	else \
	  RES="RTE"; \
		TIME=`tail -n 1 $(TMP2)`; \
	fi; \
	rm -f $(TMP1) $(TMP2) ; \
	\
	printf "<td class=\"%s\">%ss</td>\n" "$$RES" "$$TIME"
endef

_jrun_rep_o_%:
	PROG="`basename $* | rev | cut -d. -f2- | rev`.e"; \
		LANG="`basename $* | rev | cut -d. -f1 | rev`"; \
		T_LIMIT=$(TIMELIMIT);\
		RT_LIMIT=$$(($(TIMELIMIT) * 10 + 100)); \
		PID='';\
		function sig_handler() { \
			if [ -n "$$PID" ]; then \
				kill -SIGKILL -$$PID >/dev/null 2>&1; \
				wait $$PID >/dev/null 2>&1; \
			fi; \
		}; \
		trap sig_handler SIGINT ; \
		echo "<tr><td class=\"$$LANG\">$$LANG</td><td>$$PROG</td>" ; \
		for i in $(TESTS) ; do \
			j=out/`basename $$i .in`.out ; \
			\
			rm -f $(TMP3) $(TMP1);\
			setsid bash -c "ulimit -t $$T_LIMIT ; \
					$(BIN_TIME) -f \"%U\" -o $(TMP2) prog/$$PROG <$$i >$(TMP1)" >/dev/null 2>&1 & \
			$(get_rep_result); \
		done

_jrun_rep_s_%:
	PROG="`basename $* | rev | cut -d. -f2- | rev`.e"; \
		LANG="`basename $* | rev | cut -d. -f1 | rev`"; \
		T_LIMIT=$(SLOW_TIMELIMIT);\
		RT_LIMIT=$$(($(SLOW_TIMELIMIT) * 10 + 100)); \
		PID='';\
		function sig_handler() { \
			if [ -n "$$PID" ]; then \
				kill -SIGKILL -$$PID >/dev/null 2>&1; \
				wait $$PID >/dev/null 2>&1; \
			fi; \
		}; \
		trap sig_handler SIGINT ; \
		echo "<tr><td class=\"$$LANG\">$$LANG</td><td>$$PROG</td>" ; \
		for i in $(TESTS) ; do \
			j=out/`basename $$i .in`.out ; \
			\
			rm -f $(TMP3) $(TMP1);\
			setsid bash -c "ulimit -t $$T_LIMIT ; \
					$(BIN_TIME) -f \"%U\" -o $(TMP2) prog/$$PROG <$$i >$(TMP1)" >/dev/null 2>&1 & \
			$(get_rep_result); \
		done

_run_rep_o_%:
	PROG="`basename $* | rev | cut -d. -f2- | rev`.e"; \
		LANG="`basename $* | rev | cut -d. -f1 | rev`"; \
		T_LIMIT=$(TIMELIMIT);\
		RT_LIMIT=$$(($(TIMELIMIT) * 10 + 100)); \
		PID='';\
		function sig_handler() { \
			if [ -n "$$PID" ]; then \
				kill -SIGKILL -$$PID >/dev/null 2>&1; \
				wait $$PID >/dev/null 2>&1; \
			fi; \
		}; \
		trap sig_handler SIGINT ; \
		echo "<tr><td class=\"$$LANG\">$$LANG</td><td>$$PROG</td>" ; \
		for i in $(TESTS) ; do \
			j=out/`basename $$i .in`.out ; \
			\
			rm -f $(TMP3) $(TMP1) ;\
			setsid bash -c "ulimit -v $(MEMLIMIT); ulimit -t $$T_LIMIT ; \
					$(BIN_TIME) -f \"%U\" -o $(TMP2) prog/$$PROG <$$i >$(TMP1)" >/dev/null 2>&1 & \
			$(get_rep_result); \
		done

_run_rep_s_%:
	PROG="`basename $* | rev | cut -d. -f2- | rev`.e"; \
		LANG="`basename $* | rev | cut -d. -f1 | rev`"; \
		T_LIMIT=$(SLOW_TIMELIMIT);\
		RT_LIMIT=$$(($(SLOW_TIMELIMIT) * 10 + 100)); \
		PID='';\
		function sig_handler() { \
			if [ -n "$$PID" ]; then \
				kill -SIGKILL -$$PID >/dev/null 2>&1; \
				wait $$PID >/dev/null 2>&1; \
			fi; \
		}; \
		trap sig_handler SIGINT ; \
		echo "<tr><td class=\"$$LANG\">$$LANG</td><td>$$PROG</td>" ; \
		for i in $(TESTS) ; do \
			j=out/`basename $$i .in`.out ; \
			\
			rm -f $(TMP3) $(TMP1);\
			setsid bash -c "ulimit -v $(MEMLIMIT); ulimit -t $$T_LIMIT ; \
					$(BIN_TIME) -f \"%U\" -o $(TMP2) prog/$$PROG <$$i >$(TMP1)" >/dev/null 2>&1 & \
			$(get_rep_result); \
		done

_oirun_rep_o_%:
	PROG="`basename $* | rev | cut -d. -f2- | rev`.e"; \
		LANG="`basename $* | rev | cut -d. -f1 | rev`"; \
		T_LIMIT=$(TIMELIMIT);\
		RT_LIMIT=$$(($(TIMELIMIT) * 10 + 100)); \
		PID='';\
		function sig_handler() { \
			if [ -n "$$PID" ]; then \
				kill -SIGKILL -$$PID >/dev/null 2>&1; \
				wait $$PID >/dev/null 2>&1; \
			fi; \
		}; \
		trap sig_handler SIGINT ; \
		echo "<tr><td class=\"$$LANG\">$$LANG</td><td>$$PROG</td>" ; \
		for i in $(TESTS) ; do \
			j=out/`basename $$i .in`.out ; \
			\
			rm -f $(TMP3) $(TMP1) ;\
			setsid bash -c "ulimit -v $(MEMLIMIT); ulimit -t $$T_LIMIT ; \
				  $(OI_TIME) ./prog/$$PROG <$$i >$(TMP1) 2>$(TMP2)" >/dev/null 2>&1 & \
			$(get_oirep_result); \
		done

_oirun_rep_s_%:
	PROG="`basename $* | rev | cut -d. -f2- | rev`.e"; \
		LANG="`basename $* | rev | cut -d. -f1 | rev`"; \
		T_LIMIT=$(SLOW_TIMELIMIT);\
		RT_LIMIT=$$(($(SLOW_TIMELIMIT) * 10 + 100)); \
		PID='';\
		function sig_handler() { \
			if [ -n "$$PID" ]; then \
				kill -SIGKILL -$$PID >/dev/null 2>&1; \
				wait $$PID >/dev/null 2>&1; \
			fi; \
		}; \
		trap sig_handler SIGINT ; \
		echo "<tr><td class=\"$$LANG\">$$LANG</td><td>$$PROG</td>" ; \
		for i in $(TESTS) ; do \
			j=out/`basename $$i .in`.out ; \
			\
			rm -f $(TMP3) $(TMP1);\
			setsid bash -c "ulimit -v $(MEMLIMIT); ulimit -t $$T_LIMIT ; \
				  $(OI_TIME) ./prog/$$PROG <$$i >$(TMP1) 2>$(TMP2)" >/dev/null 2>&1 & \
			$(get_oirep_result); \
		done

valgrind:
	make -C prog ${ID}.valgrind
	@echo "<h2>Valgrind</h2>\n<table>\n"
	@PROG="${ID}.valgrind"; \
		RT_LIMIT=$$(($(TIMELIMIT) * 15 + 150)); \
		PID='';\
		function sig_handler() { \
			if [ -n "$$PID" ]; then \
				kill -SIGKILL -$$PID >/dev/null 2>&1; \
				wait $$PID >/dev/null 2>&1; \
			fi; \
		}; \
		trap sig_handler SIGINT ; \
		for i in $(TESTS) ; do \
			j=out/`basename $$i .in`.out ; \
			\
			rm -f $(TMP3) $(TMP1) ;\
			setsid bash -c "$(BIN_TIME) -f \"%U\" -o $(TMP2) \
					valgrind --error-exitcode=1 --leak-check=no prog/$$PROG <$$i >$(TMP1)" >/dev/null 2>&1 & \
			$(get_rep_result); \
		done
	@echo "</table>\n"

