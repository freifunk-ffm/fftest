DESTDIR=
PREFIX=/usr
BINDIR=$(PREFIX)/bin

MKDIR	:= mkdir -p
CP	:= cp -f
CHMOD	:= chmod
CAT	:= cat
GREP	:= grep
AWK	:= awk
SED	:= sed
SORT	:= sort
INSTALL	:= install
GZIP	:= gzip
LATEX	:= latex
TAR	:= tar
ECHO    := echo
MAKE    := make

# Retrieve the version
revi=$(shell svn info|grep Revision|cut -d" " -f2)
#revi=$(shell [ -d CVS ] && find |grep "CVS/Entries"|xargs cat|grep -v ^D|cut -d/ -f3|awk -F"." '{sum=sum+$$2} END {print "-cvs"sum}')
VERSION=$(shell cat ./VERSION)-$(revi)

check: functions/*.sh
	@$(ECHO) '#!/bin/bash' > checker
	@$(ECHO) 'set -ix' >> checker
	@$(ECHO) 'shopt -s extglob' >> checker
	@$(CAT) functions/*.sh >>checker
	@$(ECHO) "set +ix" >> checker
	@$(ECHO) "exit 0" >> checker
	@$(CHMOD) +x checker
	@bash checker && echo syntax check successful
	@rm checker

darbackup: darbackup.head.sh darbackup.tail.sh functions/*.sh functions/db/*.sh languages/$(LANGUAGE)/messages.lng
	$(MAKE) check
	$(CP) darbackup.head.sh darbackup.head1
	$(CHMOD) 644 darbackup.head1
	@echo "VERSION=$(VERSION)" >>darbackup.head1 
	@echo creating script using language "$(LANGUAGE)" from locales
	$(CAT) darbackup.head1 functions/*.sh functions/db/*.sh languages/$(LANGUAGE)/shorthelp.sh languages/$(LANGUAGE)/transferusage.sh darbackup.tail.sh > darbackup.temp
	$(CHMOD) 644 darbackup.temp
	$(SORT) -r ./languages/$(LANGUAGE)/messages.lng | $(SED) -e 's/=/\\=/g' -e 's/\\=/=/' | $(GREP) -v "^$$" | $(GREP) -v "^#"| $(AWK) '{print "s=" $$0 "=g"}' | $(SED) 's/=g$$/$${NORMAL}=g/g' > $(LANGUAGE)-$(VERSION)-sed
	$(CAT) darbackup.temp | $(SED) -f $(LANGUAGE)-$(VERSION)-sed > darbackup
	$(CHMOD) 755 darbackup
	@echo "darbackup successfully built. run 'make install' next"

install: darbackup
	$(MKDIR) $(DESTDIR)$(BINDIR)
	$(INSTALL) -m 755 darbackup $(DESTDIR)$(BINDIR)/darbackup
	
	$(MKDIR) $(DESTDIR)$(MANDIR)
	$(INSTALL) -m 644 darbackup.1 $(DESTDIR)$(MANDIR)/darbackup.1
	$(GZIP) -f $(DESTDIR)$(MANDIR)/darbackup.1
	
#	mkdir -p /etc/bash_completion.d
#	cp darbackup.bash_completion /etc/bash_completion.d/darbackup
#	echo "installed darbackup.bash_completion to /etc/bash_completion.d/darbackup"

.PHONY: clean distclean

