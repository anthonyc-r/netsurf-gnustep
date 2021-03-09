/* All Rights reserved */

#import <AppKit/AppKit.h>
#import "netsurf/netsurf.h"
#import "netsurf/mouse.h"
#import "Website.h"
#import "Preferences.h"
#import "VerticalTabsView.h"

struct browser_window;
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
	NSMutableArray *tabs;
	BOOL isClosing;
	id activeTab;
	id verticalTabsView;
	TabLocation currentTabLocation;
	
	
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


+(id)newTabTarget;
@end
