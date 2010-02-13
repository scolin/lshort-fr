#	pstops "4:0L@0.8(22.5cm,-0.6cm)+1L@0.8(22.5cm,13.3cm),2L@0.8(22.5cm,-0.6cm)+3L@0.8(22.5cm,13.3cm)" \
SHELL = /bin/sh
VERS = 4.27fr-2
NAME = lshort-fr

OTHER = README CHANGES
FILES = src/biblio.tex src/math.tex src/things.tex src/contrib.tex src/lshort.sty src/mylayout.sty src/title.tex \
	src/custom.tex src/lshort.tex src/overview.tex src/typeset.tex src/fancyhea.sty src/lssym.tex src/spec.tex \
	src/lshort-base.tex src/lshort-a5.tex src/graphic.tex

# Define some variables
LATEX=latex
PDFLATEX=pdflatex
MAKEINDEX=makeindex
DVIPS=dvips

# The default targets
all: $(NAME).ps $(NAME)-book.ps $(NAME).pdf $(NAME)-a5book.pdf


$(NAME).dvi: $(FILES)
	-mkdir texbuild
	(TEXINPUTS=.:`pwd`/src:`pwd`/euro:${TEXINPUTS:-:} && export TEXINPUTS && cd texbuild && \
	$(LATEX) lshort && $(LATEX) lshort && $(MAKEINDEX) -s ../src/lshort.ist lshort; \
	$(LATEX) lshort && $(LATEX) lshort && mv lshort.dvi ../$(NAME).dvi)

$(NAME)-a5.dvi: $(FILES)
	-mkdir texbuild
	(TEXINPUTS=.:`pwd`/src:`pwd`/euro:${TEXINPUTS:-:} && export TEXINPUTS && cd texbuild && \
	$(LATEX) lshort-a5 && $(LATEX) lshort-a5 && $(MAKEINDEX) -s ../src/lshort.ist lshort-a5; \
	$(LATEX) lshort-a5 && $(LATEX) lshort-a5 && mv lshort-a5.dvi ../$(NAME)-a5.dvi)

$(NAME).ps: $(NAME).dvi
	(T1FONTS=.: && TEXFONTMAPS=.: && export T1FONTS TEXFONTMAPS && $(DVIPS) -j -Pcmz -o$(NAME).ps $(NAME).dvi )
	rm texbuild/*

$(NAME)-a5.ps: $(NAME)-a5.dvi
	(T1FONTS=.: && TEXFONTMAPS=.: && export T1FONTS TEXFONTMAPS  && $(DVIPS) -j -Pcmz -ta5 -o$(NAME)-a5.ps $(NAME)-a5.dvi )
	rm texbuild/*

$(NAME)-book.ps: $(NAME).ps
	psbook $(NAME).ps out.ps 
	pstops "4:0L@0.8(22.76cm,-0.6cm)+1L@0.8(22.76cm,13.45cm),3R@0.8(-1.38cm,16.25cm)+2R@0.8(-1.38cm,30.3cm)" \
			out.ps $(NAME)-book.ps
	rm out.ps

$(NAME)-a5book.ps: $(NAME)-a5.ps
	( psbook $(NAME)-a5.ps | psnup -pa4 -s1 -2 | pstops "2:0,1U(21cm,29.7cm)" >$(NAME)-a5book.ps )

$(NAME)-a5book.pdf: $(NAME)-a5book.ps
	 ps2pdf14 -sPAPERSIZE=a4 $(NAME)-a5book.ps $(NAME)-a5book.pdf

$(NAME).pdf: $(FILES)
	-mkdir pdfbuild
	(T1FONTS=.:`pwd`/eurofont: && export T1FONTS && TEXINPUTS=.:`pwd`/src:`pwd`/euro:${TEXINPUTS:-:}&&export TEXINPUTS&& cd pdfbuild&& \
	$(PDFLATEX) lshort&& $(PDFLATEX) lshort&& \
	$(MAKEINDEX) -s ../src/lshort.ist lshort&&$(PDFLATEX) lshort&& \
	(thumbpdf --resolution 10 lshort.pdf && $(PDFLATEX) lshort)&& \
	mv lshort.pdf ../$(NAME).pdf )
	rm pdfbuild/*

$(NAME)-letter.pdf: $(FILES)
	-mkdir pdfbuild
	(T1FONTS=.:`pwd`/eurofont: && export T1FONTS && TEXINPUTS=.:`pwd`/src:`pwd`/euro:${TEXINPUTS:-:}&&export TEXINPUTS&& cd pdfbuild&& \
	$(PDFLATEX) lshort-letter&& $(PDFLATEX) lshort-letter&& \
	$(MAKEINDEX) -s ../src/lshort.ist lshort-letter&&$(PDFLATEX) lshort-letter&& \
	(thumbpdf --resolution 10 lshort-letter.pdf && $(PDFLATEX) lshort-letter)&& \
	mv lshort-letter.pdf ../$(NAME)-letter.pdf )
	rm pdfbuild/*

src/title.tex: Makefile fixdate.pl
	perl fixdate.pl $(VERS) < src/title.tex > src/title.tex2 && mv src/title.tex2 src/title.tex

quick: $(FILES)
	(TEXINPUTS=`pwd`/src:$(TEXINPUTS)&& export TEXINPUTS&& cd texbuild&& \
        $(LATEX) lshort&& mv lshort.dvi ../$(NAME).dvi)


tar:	$(FILES)
	ln -s . $(NAME)-$(VERS)
	tar -zcvf $(NAME)-$(VERS).src.tar.gz `awk '{print "$(NAME)-$(VERS)/"$$1}' MANIFEST`
	rm $(NAME)-$(VERS)

dist:	all tar
	echo press enter to rsync
	read x
	rsync  $(NAME)-$(VERS).src.tar.gz CHANGES README $(NAME).pdf $(NAME)-a5book.pdf james:public_html/latex/
	lftp -e 'cd incoming;mkdir $(NAME)-$(VERS);cd $(NAME)-$(VERS);mput $(NAME)-$(VERS).src.tar.gz CHANGES README $(NAME)-book.ps $(NAME).dvi $(NAME).pdf $(NAME).ps;quit' ftp.tex.ac.uk
	(echo -e "Robin,\n\nI have uploaded $(NAME)-$(VERS) to ftp.tex.ac.uk:/incoming/$(NAME)-$(VERS).\n\nIf you think it is appropriate, announce it please.\n\nThanks and cheers\ntobi\n\n\n--";fortune -s shakes goethe) | mailx -s "Lshort Upload (note the quote)" ctan@dante.de
	(echo -e "Folks,\n\nI have created $(NAME)-$(VERS). It is available from http://tobi.oetiker.ch/latex.\n\nCheers tobi\n\n\n--";fortune -s shakes goethe) | mailx -s "Lshort $(VERS)" `cat TRLIST`

clean:
	rm -rf texbuild pdfbuild

# additions for the French version (mpg)
README.ctan.fr: Makefile
	sed -e 's/(version .*)/(version $(VERS))/' \
		-e 's/$(NAME)-.*\.tgz/$(NAME)-$(VERS).tgz/' \
		-i $@

ctan: tar $(NAME).pdf README.ctan.fr CHANGES.fr
	mkdir $(NAME)
	cd $(NAME) \
		&& ln -s ../$(NAME)-$(VERS).src.tar.gz $(NAME)-$(VERS).tgz \
		&& ln -s ../README.ctan.fr README \
		&& ln -s ../CHANGES.fr historique \
		&& ln -s ../$(NAME).pdf
	zip -r $(NAME).zip $(NAME)
	rm -rf $(NAME)

mrproper: clean
	rm -f -- $(NAME)[.-]* $(NAME).zip $(NAME)-$(VERS).src.tar.gz
