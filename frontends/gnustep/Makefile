# ----------------------------------------------------------------------------
# Mac OS X target setup
# ----------------------------------------------------------------------------

POSTEXES += NetSurf.app
EXETARGET := nscocoa

SDK_FLAGS := $(gnustep-config --objc-flags)
CFLAGS :=  $(SDK_FLAGS) $(CFLAGS)
CFLAGS += -I/usr/local/include/gnustep
CFLAGS += -Ifrontends/gnustep
LDFLAGS :=  $(LDFLAGS)
CXXFLAGS :=  $(SDK_FLAGS) $(CXXFLAGS)

# for timerisset()
CFLAGS += -D_DARWIN_C_SOURCE
CFLAGS += -g
CFLAGS += -fno-objc-arc

LDFLAGS += -L/usr/lib
LDFLAGS += -L/usr/X11/lib
LDFLAGS += -lm -lcurl
LDFLAGS += -lssl -lcrypto
LDFLAGS += -lobjc2 -lgnustep-gui -lgnustep-base 

CFLAGS += -Dnscocoa -D_BSD_SOURCE -D_POSIX_C_SOURCE -std=c99 -g -Os
CFLAGS += -DFONT_SIZE_SCALE=1.0
CFLAGS += -I/usr/X11/include

VERSION_FULL := $(shell sed -n '/_version.*=.*"/{s/.*"\(.*\)".*/\1/;p;}' desktop/version.c)
VERSION_MAJ := $(shell sed -n '/_major/{s/.* = \([0-9]*\).*/\1/;p;}' desktop/version.c)
VERSION_MIN := $(shell sed -n '/_minor/{s/.* = \([0-9]*\).*/\1/;p;}' desktop/version.c)


# ----------------------------------------------------------------------------
# Source file setup
# ----------------------------------------------------------------------------

# sources purely for the Mac OS X build
S_FRONTEND := \
	AppDelegate.m	\
	BrowserWindowController.m	\
	PlotView.m	\
	NetsurfCallback.m	\
	tables/misc.m	\
	tables/bitmap.m	\
	tables/clipboard.m	\
	tables/download.m	\
	tables/fetch.m	\
	tables/layout.m	\
	tables/search.m	\
	tables/window.m	\


# This is the final source build list
# Note this is deliberately *not* expanded here as common and image
#   are not yet available
SOURCES = $(addprefix $(shell pwd)/,$(S_COMMON) $(S_IMAGE) $(S_BROWSER) $(S_FRONTEND))

# Since we prefix the sources with the pwd, also create a special
# prefixed rule so that the testament is run
$(shell pwd)/content/fetchers/about.c: testament

EXETARGET := NetSurf

R_RESOURCES := \
	ca-bundle	\
	Menu.gorm	\
	Browser.gorm	\

R_RESOURCES := $(addprefix $(FRONTEND_RESOURCES_DIR)/,$(R_RESOURCES))

LANGUAGES := en
LOCALIZED_RESOURCES := Localizable.strings

# ----------------------------------------------------------------------------
# Install target
# ----------------------------------------------------------------------------

install-cocoa: NetSurf.app

NetSurf.app: NetSurf $(FRONTEND_SOURCE_DIR)/Makefile $(R_RESOURCES) NetSurf.app/Resources/Info-gnustep.plist
	$(VQ)echo Assembling NetSurf.app bundle
	$(Q)cp NetSurf NetSurf.app/
	$(Q)mkdir -p NetSurf.app/Resources
	$(Q)cp -pLR $(R_RESOURCES) NetSurf.app/Resources

NetSurf.app/Resources/Info-gnustep.plist: $(FRONTEND_RESOURCES_DIR)/NetSurf-Info.plist $(FRONTEND_SOURCE_DIR)/Makefile
	$(VQ)echo Generating Info.plist
	$(Q)rm -rf NetSurf.app/Resources
	$(Q)mkdir -p NetSurf.app/Resources
	$(Q)sed -e 's/$${EXECUTABLE_NAME}/$(EXETARGET)/' \
	    -e 's/$${PRODUCT_NAME.*}/$(EXETARGET)/' \
	    -e 's/$${MACOSX_DEPLOYMENT_TARGET}/$(MACOSX_VERSION)/' \
	    -e 's/$${NETSURF_VERSION}/$(VERSION_FULL)/' \
		-e 's/$${NETSURF_SHORT_VERSION}/$(VERSION_MAJ).$(VERSION_MIN)/' \
	   < $(FRONTEND_RESOURCES_DIR)/NetSurf-Info.plist > NetSurf.app/Resources/Info-gnustep.plist


CLEANS += clean-package-cocoa

clean-package-cocoa:
	$(VQ)echo "   CLEAN: NetSurf.app"
	$(Q)$(RM) -r NetSurf.app 
