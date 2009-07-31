# Makefile for flshort
#
# Copyright (C) 1996 Matthieu Herrb
#
# $Id: Makefile,v 1.17 1999/01/22 17:57:20 matthieu Exp $
#
include Makefile.common

all: all-dvi all-ps all-pdf

all-dvi: 
	(cd dvi ; $(MAKE) dvi)

all-ps: 
	(cd dvi ; $(MAKE) ps)

all-pdf:
	(cd pdf ; $(MAKE) pdf)

tar: $(BASE)-$(VERSION).tgz


$(BASE)-$(VERSION).tgz: $(SRCS) $(FIGS) $(BIBLIO) $(STY) \
			$(OTHER) $(MAKEFILES)
	rm -f $@
	$(TAR) czvf $@  $(SRCS) $(FIGS) $(BIBLIO) $(STY) \
			$(OTHER) $(MAKEFILES)



clean:
	rm -f $(BASE)-$(VERSION).tar.gz
	(cd dvi ; $(MAKE) clean)
	(cd pdf ; $(MAKE) clean)


