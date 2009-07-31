#	pstops "4:0L@0.8(22.5cm,-0.6cm)+1L@0.8(22.5cm,13.3cm),2L@0.8(22.5cm,-0.6cm)+3L@0.8(22.5cm,13.3cm)" \
SHELL = /bin/sh
VERS = 4.17

OTHER = README CHANGES
FILES = src/biblio.tex src/math.tex src/things.tex src/contrib.tex src/lshort.sty src/mylayout.sty src/title.tex \
	src/custom.tex src/lshort.tex src/overview.tex src/typeset.tex src/fancyhea.sty src/lssym.tex src/spec.tex

# Define some variables
LATEX=latex
PDFLATEX=pdflatex
MAKEINDEX=makeindex


# The default targets
all: lshort.dvi lshort.ps lshort-book.ps lshort.pdf


lshort.dvi: $(FILES)
	-mkdir texbuild
	(TEXINPUTS=.:`pwd`/src:${TEXINPUTS:-:} && export TEXINPUTS && cd texbuild && \
	$(LATEX) lshort && $(LATEX) lshort && $(MAKEINDEX) -s ../src/lshort.ist lshort; \
	$(LATEX) lshort && $(LATEX) lshort && mv lshort.dvi ..)

lshort.ps: lshort.dvi
	(T1FONTS=.:`pwd`/eurofont: && export T1FONTS && dvips -Pcmz -olshort.ps lshort.dvi )
	rm texbuild/*

lshort-book.ps: lshort.ps
	psbook lshort.ps out.ps 
	pstops "4:0L@0.8(22.76cm,-0.6cm)+1L@0.8(22.76cm,13.45cm),3R@0.8(-1.38cm,16.25cm)+2R@0.8(-1.38cm,30.3cm)" \
			out.ps lshort-book.ps
	rm out.ps

lshort.pdf: $(FILES)
	-mkdir pdfbuild
	(T1FONTS=.:`pwd`/eurofont: && export T1FONTS && TEXINPUTS=.:`pwd`/src:${TEXINPUTS:-:}&&export TEXINPUTS&& cd pdfbuild&& \
	$(PDFLATEX) lshort&& $(PDFLATEX) lshort&& \
	$(MAKEINDEX) -s ../src/lshort.ist lshort&&$(PDFLATEX) lshort&& \
	(thumbpdf --resolution 10 lshort.pdf && $(PDFLATEX) lshort)&& \
	mv lshort.pdf .. )
	rm pdfbuild/*

src/title.tex: Makefile
	perl fixdate.pl $(VERS) < src/title.tex > src/title.tex2 && mv src/title.tex2 src/title.tex

quick: $(FILES)
	(TEXINPUTS=`pwd`/src:$(TEXINPUTS)&& export TEXINPUTS&& cd texbuild&& \
        $(LATEX) lshort&& mv lshort.dvi ..)


tar:	src/title.tex
	ln -s . lshort-$(VERS)
	gtar -zcvf lshort-$(VERS).src.tar.gz `awk -e '{print "lshort-$(VERS)/"$$1}' MANIFEST`
	rm lshort-$(VERS)

dist:	tar
	cp lshort-$(VERS).src.tar.gz CHANGES README lshort-book.ps lshort.dvi lshort.pdf lshort.ps $(HOME)/public_html/lshort/
	lftp -e 'cd incoming;mkdir lshort-$(VERS);cd lshort-$(VERS);mput lshort-$(VERS).src.tar.gz CHANGES README lshort-book.ps lshort.dvi lshort.pdf lshort.ps;quit' ftp.tex.ac.uk
	(gecho -e "Robin,\n\nI have uploaded lshort-$(VERS) to ftp.tex.ac.uk:/incoming/lshort-$(VERS).\n\nIf you think it is appropriate, announce it please.\n\nThanks and cheers\ntobi\n\n\n--";fortune -s shakes goethe) | mailx -s "Lshort Upload (note the quote)" ctan@dante.de
	(gecho -e "Folks,\n\nI have created lshort-$(VERS). It is available from http://people.ee.ethz.ch/~oetiker/lshort.\n\nCheers tobi\n\n\n--";fortune -s shakes goethe) | mailx -s "Lshort $(VERS)" `cat TRLIST`

clean:
	rm -rf texbuild pdfbuild
