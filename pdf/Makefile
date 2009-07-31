# Makefile for flshort
#
# Copyright (C) 1996 Matthieu Herrb
#
# $Id: Makefile,v 1.4 2001/11/25 17:43:58 matthieu Exp $
#
include ../Makefile.common

VPATH = ..
export TEXINPUTS = ..:

all pdf: $(PDF)


$(BASE).pdf: $(SRCS) $(BIBLIO) $(INDEX)
	$(PDFLATEX) $(MAIN)

$(PDF): $(BASE).pdf
	thumbpdf $(BASE).pdf
	$(PDFLATEX) $(MAIN)
	mv $(BASE).pdf $(PDF)


%.ind: %.idx
	$(MAKEINDEX) -s ../index.ist -o $(BASE).tmp $<
	../move-if-change $(BASE).tmp $@

%.idx: $(SRCS)
	$(PDFLATEX) $(MAIN)
	@while egrep -s 'Rerun to get cross-references right.' $(BASE).log ;\
	do \
	  $(PDFLATEX) $(MAIN) ; \
	done

clean:
	rm -f *.aux *.pdf *.toc *.lof *.lot *.exa *.idx *.log

