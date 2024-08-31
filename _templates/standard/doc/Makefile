#
# Makefile for LaTeX documents.
#

# actions: not-interactive

TEX  = $(wildcard [a-z]*.tex)
PDF  = $(patsubst %.tex,%.pdf,$(TEX))

all:  pdf

pdf: $(PDF)

%.pdf: %.tex
	pdflatex -halt-on-error -file-line-error -interaction=nonstopmode $*.tex
	pdflatex -halt-on-error -file-line-error -interaction=nonstopmode $*.tex

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

no_binaries:
	rm -f $(PDF)
