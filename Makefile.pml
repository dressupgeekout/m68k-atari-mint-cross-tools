PACKAGE_NAME=pml
VERSION=2.03
VERSIONPATCH=-mint-20110207
SOURCE_DIR=$(BUILD_DIR)/$(PACKAGE_NAME)-$(VERSION)
COMPIL_DIR=$(BUILD_DIR)/$(PACKAGE_NAME)-$(VERSION)$(VERSIONPATCH)-$(VERSIONBIN)
PACKAGE_FILE=$(PACKAGE_NAME)-$(VERSION)$(VERSIONPATCH)-$(VERSIONBIN)-$(VERSIONBUILD).tgz

BINARY_DIR=$(COMPIL_DIR)/binary-package
LOCAL_PREFIX_DIR=$(BINARY_DIR)$(PREFIX)

M68K_PREFIX=$(PREFIX)/m68k-atari-mint
CFLAGS=

ifneq "$(GCC)" ""
  GCC_BUILD_DIR=$(dir $(GCC))
  CC=$(GCC) -B$(GCC_BUILD_DIR) -B$(M68K_PREFIX)/bin/ -B$(M68K_PREFIX)/lib/ -isystem $(M68K_PREFIX)/include -isystem $(M68K_PREFIX)/sys-include
else
  CC=m68k-atari-mint-gcc
endif


##########################################
all:		extract patch configure compile packaging install

clean:	
	rm -rf "$(COMPIL_DIR)"
	rm -rf "$(SOURCE_DIR)"
	rm -rf "$(PACKAGES_DIR)/$(PACKAGE_FILE)"


##########################################
extract:	$(SOURCE_DIR)

patch:		$(SOURCE_DIR)/_patch

configure:

compile:
	@echo CC=$(GCC) GCC build dir=$(GCC_BUILD_DIR)
	cd "$(SOURCE_DIR)/pmlsrc" && \
	sed -i ".bak" "s:^\(CROSSDIR =\).*:\1 $(M68K_PREFIX):g" Makefile Makefile.32 Makefile.16 && \
	sed -i ".bak" "s:^\(AR =\).*:\1 m68k-atari-mint-ar:g" Makefile Makefile.32 Makefile.16 && \
	sed -i ".bak" "s:^\(CC =\).*:\1 $(CC):g" Makefile Makefile.32 Makefile.16
	make --directory="$(SOURCE_DIR)/pmlsrc"
	make --directory="$(SOURCE_DIR)/pmlsrc" install CROSSDIR=$(LOCAL_PREFIX_DIR)/m68k-atari-mint

	make --directory="$(SOURCE_DIR)/pmlsrc" clean
	cd "$(SOURCE_DIR)/pmlsrc" && \
	sed -i ".bak" "s:^\(CFLAGS =.*\):\1 -m68020-60:g" Makefile.32 Makefile.16 && \
	sed -i ".bak" "s:^\(CROSSLIB =.*\):\1/m68020-60:g" Makefile
	make --directory="$(SOURCE_DIR)/pmlsrc"
	make --directory="$(SOURCE_DIR)/pmlsrc" install CROSSDIR=$(LOCAL_PREFIX_DIR)/m68k-atari-mint

	make --directory="$(SOURCE_DIR)/pmlsrc" clean
	cd "$(SOURCE_DIR)/pmlsrc" && \
	sed -i ".bak" "s:-m68020-60:-mcpu=5475:g" Makefile.32 Makefile.16 && \
	sed -i ".bak" "s:m68020-60:m5475:g" Makefile
	make --directory="$(SOURCE_DIR)/pmlsrc"
	make --directory="$(SOURCE_DIR)/pmlsrc" install CROSSDIR=$(LOCAL_PREFIX_DIR)/m68k-atari-mint

	cd "$(SOURCE_DIR)/pmlsrc" && \
	sed -i ".bak" "s:^\(CFLAGS =.*\) -m5475 -DNO_INLINE_MATH:\1:g" Makefile.32 Makefile.16 && \
	sed -i ".bak" "s:^\(CROSSLIB =.*\)/m5475:\1:g" Makefile

packaging:	$(PACKAGES_DIR)/$(PACKAGE_FILE)

install:	packaging
	tar xvzf "$(PACKAGES_DIR)/$(PACKAGE_FILE)" --directory $(dir $(PREFIX))


##########################################
# extract sources
$(SOURCE_DIR):
	tar jxvf "$(ARCHIVES_DIR)/$(PACKAGE_NAME)-$(VERSION).tar.bz2" --directory "$(BUILD_DIR)"


# apply patch to sources
$(SOURCE_DIR)/_patch:		$(SOURCE_DIR)
ifneq "$(VERSIONPATCH)" ""
	bzcat "$(ARCHIVES_DIR)/$(PACKAGE_NAME)-$(VERSION)$(VERSIONPATCH).patch.bz2" | patch -p1 --directory $<
endif
	echo "$(VERSIONPATCH)" >  $@


# build distribution package
$(PACKAGES_DIR)/$(PACKAGE_FILE): compile
	-rm -rf "$(LOCAL_PREFIX_DIR)"/lib/m68020-60/mshort
	-rm -rf "$(LOCAL_PREFIX_DIR)"/lib/m5475/mshort
	tar cvzf "$@" --directory "$(dir $(LOCAL_PREFIX_DIR))" $(notdir $(LOCAL_PREFIX_DIR)) 