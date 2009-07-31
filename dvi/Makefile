# Makefile for flshort
#
# Copyright (C) 1996 Matthieu Herrb
#
# $Id: Makefile,v 1.5 2001/11/25 17:43:58 matthieu Exp $
#
include ../Makefile.common

VPATH = ..
export TEXINPUTS = ..:

all dvi: $(DOC)

ps: $(PS)

$(DOC): $(SRCS) $(BIBLIO) $(INDEX)
	$(LATEX) $(MAIN)
	mv $(BASE).dvi $(DOC)

$(PS):	$(DOC)
	$(DVIPS) -o $@ $(DOC)


%.ind: %.idx
	$(MAKEINDEX) -s ../index.ist -o $(BASE).tmp $<
	../move-if-change $(BASE).tmp $@

%.idx: $(SRCS)
	$(LATEX) $(MAIN)
	@while egrep -s 'Rerun to get cross-references right.' $(BASE).log ;\
	do \
	  $(LATEX) $(MAIN) ; \
	done

clean:
	rm -f *.aux *.dvi *.toc *.lof *.lot *.exa *.idx *.log

