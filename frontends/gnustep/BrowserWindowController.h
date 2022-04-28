/*
 * Copyright 2022 Anthony Cohn-Richardby <anthonyc@gmx.co.uk>
 *
 * This file is part of NetSurf, http://www.netsurf-browser.org/
 *
 * NetSurf is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 * NetSurf is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
#import <AppKit/AppKit.h>
#import "netsurf/netsurf.h"
#import "netsurf/mouse.h"
#import "Website.h"
#import "Preferences.h"
#import "VerticalTabsView.h"
#import "UrlSuggestionView.h"

struct browser_window;
struct form_control;

@interface BrowserWindowController : NSWindowController<NSTextFieldDelegate, VerticalTabsViewDelegate> {
	id backButton;
	id forwardButton;
	id urlBar;
	id tabView;
	id refreshButton;
	id caretView;
	enum gui_pointer_shape lastRequestedPointer;
	id searchBar;
	id searchImage;
	id searchLabel;
	NSMutableArray *tabs;
	BOOL isClosing;
	id activeTab;
	id verticalTabsView;
	TabLocation currentTabLocation;
	UrlSuggestionView *urlSuggestionView;
	
	
	// These three are set based on the currently focused tab.
	id scrollView;
	id plotView;
	struct browser_window *browser;
}

-(id)initWithBrowser: (struct browser_window*)aBrowser;
-(void)back: (id)sender;
-(void)forward: (id)sender;
-(void)stopOrRefresh: (id)sender;
-(NSString*)visibleUrl;
-(void)enterSearch: (id)sender;
-(void)openWebsite: (Website*)aWebsite;
-(void)newTab: (id)sender;
// Returns a tab identifier that must be provided to some of the below messages.
-(id)newTabWithBrowser: (struct browser_window*)aBrowser;
-(void)close: (id)sender;
-(id)initialTabId;

// Browser control
-(struct browser_window *)browser;
-(NSSize)getBrowserSizeForTab: (id)tab;
-(NSPoint)getBrowserScrollForTab: (id)tab;
-(void)setBrowserScroll: (NSPoint)scroll forTab: (id)tab;
-(void)invalidateBrowserForTab: (id)tab;
-(void)invalidateBrowser: (NSRect)rect forTab: (id)tab;
-(void)updateBrowserExtentForTab: (id)tab;
-(void)placeCaretAtX: (int)x y: (int)y height: (int)height inTab: (id)tab;
-(void)removeCaretInTab: (id)tab;
-(void)setPointerToShape: (enum gui_pointer_shape)shape;
-(void)newContentForTab: (id)tab;
-(void)setNavigationUrl: (NSString*)urlString forTab: (id)tab;
-(void)setTitle: (NSString*)title forTab: (id)tab;
-(void)netsurfWindowDestroyForTab: (id)tab;

-(void)startThrobber;
-(void)stopThrobber;
-(void)findNext: (NSString*)needle matchCase: (BOOL)matchCase sender: (id)sender;
-(void)findPrevious: (NSString*)needle matchCase: (BOOL)matchCase sender: (id)sender;
-(void)showAll: (NSString*)needle matchCase: (BOOL)matchCase sender: (id)sender;
-(void)bookmarkPage: (id)sender;
-(void)zoomIn: (id)sender;
-(void)zoomOut: (id)sender;
-(void)resetZoom: (id)sender;
-(void)reload: (id)sender;
-(void)stopLoading: (id)sender;

-(void)showDropdownMenuWithOptions: (NSArray*)options atLocation: (NSPoint)location inTab: (id)tab control: (struct form_control*)control;


+(id)newTabTarget;
@end
