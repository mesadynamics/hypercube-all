#!/usr/bin/make

# make documentation

VENDOR    = Ister.ORG
VENDORWWW = " "

###
srcdir   = .
poddir   = $(srcdir)/src
htmldir  = $(srcdir)/html

POD2HTML      = pod2html
POD2HTMLFLAGS =  --css doc.css --header --backlink 'back to top'

PODLIST  = $(wildcard $(poddir)/*.pod)
HTMLLIST = $(patsubst $(poddir)/%.pod, $(htmldir)/%.html, $(PODLIST))

INTERMEDIATE  =
INTERMEDIATE += $(srcdir)/pod2*~


define run-pod2man
$(POD2MAN) $(POD2MANFLAGS) $< $@
gzip -f $@
endef


.PHONY : doc
doc: pod $(HTMLLIST) cleanup



.PHONY : pod
pod:
	make -C $(poddir) dist NAME=$(NAME) DOTVERSION=$(DOTVERSION)

#html
$(HTMLLIST): $(htmldir)/%.html: $(poddir)/%.pod $(poddir)/doc.css
	test -e $(htmldir) || mkdir $(htmldir)
	cd $(htmldir)
	cp $(poddir)/doc.css $(htmldir)
	$(POD2HTML) $(POD2HTMLFLAGS) $< > $@
	cd $(srcdir)

#cleanup
.PHONY : cleanup
cleanup:
	@echo "cleaning up..."
	-rm $(INTERMEDIATE)

#clean
.PHONY : clean
clean: cleanup
ifdef HTMLLIST
	-rm $(htmldir)/*
	-rmdir $(htmldir)
endif

