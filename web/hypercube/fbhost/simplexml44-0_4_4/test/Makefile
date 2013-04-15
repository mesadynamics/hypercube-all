#!/bin/make

# $Id: Makefile,v 1.3 2005/01/20 20:19:43 ingo Exp $

SHELL     = /bin/sh
PHP       = /usr/bin/php
PHPFLAGS  = -d max_execution_time=60 -d html_errors=Off


TESTCLEANDIR    = out
TEMPLATEDIR     = tmpl

PHPFILES        = $(wildcard *.php)
UNITTESTFILES   = $(wildcard unittest.php)
UNITOUTFILES    = $(patsubst %.php,%.out,$(UNITTESTFILES))
UNITTESTFILES5  = $(wildcard unittest5.php)
UNITOUTFILES5   = $(patsubst %.php,%.out5,$(UNITTESTFILES5))
TESTFILES       = $(patsubst %.php,%.tst,$(PHPFILES))
TESTCLEANFILES  = $(patsubst %.php,%.out,$(PHPFILES))
SYNTAXFILES     = $(patsubst %.php,%.stx,$(PHPFILES))

.PHONY : all
all: syntax test

.PHONY: devtest
#devtest: $(TESTFILES)
devtest: unittest

.PHONY: unittest
unittest: syntax clean $(UNITOUTFILES)
#	-cat $(TESTCLEANDIR)/apd_dump*

.PHONY : test
#test: REDIR = 2>&1 > /dev/null
#test: devtest
test: unittest

.PHONY: test5
test5: syntax clean $(UNITOUTFILES5)

.PHONY: testinit
testinit: clean $(TESTCLEANFILES)

.PHONY : syntax
syntax: $(SYNTAXFILES)
	test -d $(TESTCLEANDIR) || mkdir $(TESTCLEANDIR)

%.stx: %.php
	@$(PHP) $(PHPFLAGS) -l -f $<

%.tst: %.php
	@echo -n "$* ... ";
	@$(PHP) $(PHPFLAGS) -f $< $(TESTFLAGS) > $(TESTCLEANDIR)/$@
	@diff $(TESTCLEANDIR)/$*.out $(TESTCLEANDIR)/$@ $(REDIR) && echo "ok" || echo "failed";
	@rm $(TESTCLEANDIR)/$@

%.out: %.php
	@$(PHP) $(PHPFLAGS) $< $(TESTFLAGS) | tee $(TESTCLEANDIR)/$@

%.out5: %.php
	@$(PHP5) $(PHPFLAGS) $< $(TESTFLAGS) | tee $(TESTCLEANDIR)/$@

.PHONY: clean
clean:
	-rm $(TESTCLEANDIR)/*
