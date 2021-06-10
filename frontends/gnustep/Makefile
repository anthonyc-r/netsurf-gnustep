# ----------------------------------------------------------------------------
# Mac OS X target setup
# ----------------------------------------------------------------------------

POSTEXES += NetSurf.app
EXETARGET := nscocoa

SDK_CFLAGS := $(shell gnustep-config --objc-flags)
SDK_LDFLAGS := $(shell gnustep-config --gui-libs)

CFLAGS :=  $(SDK_CFLAGS) $(CFLAGS)
CFLAGS += -I/usr/local/include/gnustep
CFLAGS += -Ifrontends/gnustep
LDFLAGS :=  $(SDK_LDFLAGS) $(LDFLAGS)
CXXFLAGS :=  $(SDK_CFLAGS) $(CXXFLAGS)

CFLAGS += -g

# GCC has no -fno-objc-arc
ifeq ($(shell $(CC) -v 2>&1 | grep -c "gcc version"), 1)
CFLAGS += -fno-objc-gc
else
CFLAGS += -fno-objc-arc
endif

LDFLAGS += -L/usr/lib
LDFLAGS += -L/usr/X11/lib
LDFLAGS += -lm -lcurl
LDFLAGS += -lssl -lcrypto

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
	DownloadsWindowController.m	\
	DownloadManager.m	\
	PlotView.m	\
	NetsurfCallback.m	\
	ProgressBarCell.m	\
	FindPanelController.m	\
	HistoryWindowController.m	\
	BookmarksWindowController.m	\
	CreateBookmarkPanelController.m	\
	PreferencesWindowController.m	\
	VerticalTabsView.m	\
	UrlSuggestionView.m	\
	NotifyingTextField.m	\
	Website.m	\
	BookmarkFolder.m	\
	SearchProvider.m	\
	Preferences.m	\
	tables/misc.m	\
	tables/bitmap.m	\
	tables/clipboard.m	\
	tables/download.m	\
	tables/fetch.m	\
	tables/search.m	\
	tables/window.m	\
	tables/font.m	\


# This is the final source build list
# Note this is deliberately *not* expanded here as common and image
#   are not yet available
SOURCES = $(addprefix $(shell pwd)/,$(S_COMMON) $(S_IMAGE) $(S_BROWSER) $(S_FRONTEND))

# Since we prefix the sources with the pwd, also create a special
# prefixed rule so that the testament is run
$(shell pwd)/content/fetchers/about/about.c: testament

EXETARGET := NetSurf

R_RESOURCES := \
	Menu.gorm	\
	Browser.gorm	\
	Downloads.gorm	\
	Find.gorm	\
	History.gorm	\
	Bookmarks.gorm	\
	CreateBookmark.gorm	\
	Preferences.gorm	\

R_RESOURCES := $(addprefix $(FRONTEND_RESOURCES_DIR)/,$(R_RESOURCES))

E_RESOURCES := \
	adblock.css	\
	ca-bundle	\
	default.css	\
	internal.css	\
	quirks.css	\
	SearchEngines	\
	forward.png	\
	back.png	\
	refresh.png	\
	search.png	\

E_RESOURCES := $(addprefix resources/,$(E_RESOURCES))
	

LANGUAGES := en
LOCALIZED_RESOURCES := Localizable.strings

# ----------------------------------------------------------------------------
# Install target
# ----------------------------------------------------------------------------

install-cocoa: NetSurf.app

NetSurf.app: NetSurf $(FRONTEND_SOURCE_DIR)/Makefile $(R_RESOURCES) NetSurf.app/Resources/Info-gnustep.plist
	$(VQ)echo Assembling NetSurf.app bundle
	$(Q)cp NetSurf NetSurf.app/
	$(Q)cp $(FRONTEND_RESOURCES_DIR)/NetSurf.icns NetSurf.app
	$(Q)mkdir -p NetSurf.app/Resources
	$(Q)cp -pLR $(R_RESOURCES) NetSurf.app/Resources
	$(Q)cp -pLR $(E_RESOURCES) NetSurf.app/

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
