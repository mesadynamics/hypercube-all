#!/usr/bin/make

M4        = /usr/bin/m4
M4FLAGS   = --define=M4YEAR=`date +"%Y"` --define=M4NAME=$(NAME) --define=M4VERSION=$(DOTVERSION)


.PHONY : dist
dist:
	$(M4) $(M4FLAGS) $(NAME).pod > $(NAME).pod.m4
	cp $(NAME).pod.m4 $(NAME).pod
	rm $(NAME).pod.m4