EPREFIX ?=

CFLAGS ?= -O2 -g
CFLAGS += -Wall -Wextra
CPPFLAGS += '-DEPREFIX="$(EPREFIX)"'

PN = gcc-config
PV = git
P = $(PN)-$(PV)

PREFIX = $(EPREFIX)/usr
BINDIR = $(PREFIX)/bin
DOCDIR = $(PREFIX)/share/doc/$(P)
ESELECTDIR = $(PREFIX)/share/eselect/modules

SUBLIBDIR = lib
LIBDIR = $(PREFIX)/$(SUBLIBDIR)

MKDIR_P = mkdir -p -m 755
INSTALL_EXE = install -m 755
INSTALL_DATA = install -m 644

all: .gcc-config

clean:
	rm -f .gcc-config

.gcc-config: gcc-config
	sed \
		-e '1s:/:$(EPREFIX)/:' \
		-e 's:@GENTOO_EPREFIX@:$(EPREFIX):g' \
		-e 's:@GENTOO_LIBDIR@:$(SUBLIBDIR):g' \
		-e 's:@PV@:$(PV):g' \
		$< > $@
	chmod a+rx $@

install: all
	$(MKDIR_P) $(DESTDIR)$(BINDIR) $(DESTDIR)$(ESELECTDIR) $(DESTDIR)$(DOCDIR)
	$(INSTALL_EXE) .gcc-config $(DESTDIR)$(BINDIR)/gcc-config
	$(INSTALL_DATA) gcc.eselect $(DESTDIR)$(ESELECTDIR)
	$(INSTALL_DATA) README $(DESTDIR)$(DOCDIR)

test check: .gcc-config
	cd tests && ./run_tests

dist:
	@if [ "$(PV)" = "git" ] ; then \
		printf "please run: make dist PV=xxx\n(where xxx is a git tag)\n" ; \
		exit 1 ; \
	fi
	git archive --prefix=$(P)/ v$(PV) | xz > $(P).tar.xz

distcheck: dist
	@set -ex; \
	rm -rf $(P); \
	tar xf $(P).tar.xz; \
	pushd $(P) >/dev/null; \
	$(MAKE) install DESTDIR=`pwd`/foo; \
	rm -rf foo; \
	$(MAKE) check; \
	popd >/dev/null; \
	rm -rf $(P)

.PHONY: all clean dist install
