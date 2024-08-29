#
# Makefile for LaTeX documents.
#
TEX  = $(wildcard [a-z]*.tex)
PDF  = $(patsubst %.tex,%.pdf,$(TEX))

all:  pdf

pdf: $(PDF)

%.pdf: %.tex
	pdflatex $*.tex
	pdflatex $*.tex

clean:
	rm -f *~
	rm -f *.log
	rm -f *.aux
	rm -f *.dvi
	rm -f *.err
	rm -f *.inf
	rm -f *.fls
	rm -f *.fdb_latexmk
	rm -f *.synctex.gz

