#	pstops "4:0L@0.8(22.5cm,-0.6cm)+1L@0.8(22.5cm,13.3cm),2L@0.8(22.5cm,-0.6cm)+3L@0.8(22.5cm,13.3cm)" \
SHELL = /bin/sh
VERS = 6.0fr-unreleased
NAME = lshort-fr

OTHER = README CHANGES
FILES = src/biblio.tex src/math.tex src/things.tex src/contrib.tex src/lshort.sty src/mylayout.sty src/title.tex \
	src/custom.tex src/lshort.tex src/overview.tex src/typeset.tex src/fancyhea.sty src/lssym.tex src/spec.tex \
	src/lshort-base.tex src/lshort-a5.tex src/graphic.tex src/appendix.tex

# Define some variables
LATEX=latex
PDFLATEX=xelatex
MAKEINDEX=makeindex
DVIPS=dvips

# The default targets
all: $(NAME).pdf $(NAME)-a5.pdf

lulu: $(NAME)-body.pdf $(NAME)-title.pdf


$(NAME).pdf: $(FILES)
	-mkdir pdfbuild
	(T1FONTS=.:`pwd`/eurofont: && export T1FONTS && TEXINPUTS=.:`pwd`/src:`pwd`/euro:`pwd`/oberdiek:${TEXINPUTS:-:}&&export TEXINPUTS&& cd pdfbuild&& \
	$(PDFLATEX) lshort&& $(PDFLATEX) lshort&& \
	$(MAKEINDEX) -s ../src/lshort.ist lshort&&$(PDFLATEX) lshort&& \
	(thumbpdf --resolution 10 lshort.pdf && $(PDFLATEX) lshort)&& \
	mv lshort.pdf ../$(NAME).pdf )
	rm pdfbuild/*

$(NAME)-body.pdf: $(FILES)
	-mkdir pdfbuild
	(T1FONTS=.:`pwd`/eurofont: && export T1FONTS && TEXINPUTS=.:`pwd`/src:`pwd`/euro:`pwd`/oberdiek:${TEXINPUTS:-:}&&export TEXINPUTS&& cd pdfbuild&& \
	$(PDFLATEX) lshort-body && $(PDFLATEX) lshort-body && \
	$(MAKEINDEX) -s ../src/lshort.ist lshort-body &&$(PDFLATEX) lshort-body&& \
	mv lshort-body.pdf ../$(NAME)-body.pdf )
	rm pdfbuild/*

$(NAME)-title.pdf: $(FILES)
	-mkdir pdfbuild
	(T1FONTS=.:`pwd`/eurofont: && export T1FONTS && TEXINPUTS=.:`pwd`/src:`pwd`/euro:`pwd`/oberdiek:${TEXINPUTS:-:}&&export TEXINPUTS&& cd pdfbuild&& \
	$(PDFLATEX) lshort-title && $(PDFLATEX) lshort-title && \
	mv lshort-title.pdf ../$(NAME)-title.pdf )
	rm pdfbuild/*

$(NAME)-a5.pdf: $(FILES)
	-mkdir pdfbuild
	(T1FONTS=.:`pwd`/eurofont: && export T1FONTS && TEXINPUTS=.:`pwd`/src:`pwd`/euro:`pwd`/oberdiek:${TEXINPUTS:-:}&&export TEXINPUTS&& cd pdfbuild&& \
	$(PDFLATEX) lshort-a5&& $(PDFLATEX) lshort-a5&& \
	$(MAKEINDEX) -s ../src/lshort.ist lshort-a5&&$(PDFLATEX) lshort-a5&& \
	(thumbpdf --resolution 10 lshort-a5.pdf && $(PDFLATEX) lshort-a5)&& \
	mv lshort-a5.pdf ../$(NAME)-a5.pdf )
	rm pdfbuild/*

$(NAME)-letter.pdf: $(FILES)
	-mkdir pdfbuild
	(T1FONTS=.:`pwd`/eurofont: && export T1FONTS && TEXINPUTS=.:`pwd`/src:`pwd`/euro:`pwd`/oberdiek:${TEXINPUTS:-:}&&export TEXINPUTS&& cd pdfbuild&& \
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

rsync:  all tar
	echo press enter to rsync
	read x
	rsync  $(NAME)-$(VERS).src.tar.gz CHANGES README $(NAME).pdf $(NAME)-letter.pdf $(NAME)-a5.pdf james:public_html/latex/

dist:	rsync
	zip $(NAME)-$(VERS).zip $(NAME)-$(VERS).src.tar.gz CHANGES README $(NAME).pdf $(NAME)-letter.pdf $(NAME)-a5.pdf
	-rm $(NAME)
	ln -s . $(NAME)
	zip $(NAME)-$(VERS).zip $(NAME)/$(NAME)-$(VERS).src.tar.gz $(NAME)/CHANGES $(NAME)/README $(NAME)/$(NAME).pdf $(NAME)/$(NAME)-letter.pdf $(NAME)/$(NAME)-a5.pdf
	-rm $(NAME)
	echo upload $(NAME)-$(VERS).zip to http://www.ctan.org/upload   

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
