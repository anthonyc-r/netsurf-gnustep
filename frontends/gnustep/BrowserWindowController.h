/* All Rights reserved */

#import <AppKit/AppKit.h>
#import "netsurf/netsurf.h"
#import "netsurf/mouse.h"
#import "Website.h"

struct browser_window;
@interface BrowserWindowController : NSWindowController<NSTextFieldDelegate> {
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
-(void)newTab: (struct browser_window*)aBrowser;

// Browser control
-(NSSize)getBrowserSize;
-(NSPoint)getBrowserScroll;
-(void)setBrowserScroll: (NSPoint)scroll;
-(void)invalidateBrowser;
-(void)invalidateBrowser: (NSRect)rect;
-(void)updateBrowserExtent;
-(void)placeCaretAtX: (int)x y: (int)y height: (int)height;
-(void)removeCaret;
-(void)setPointerToShape: (enum gui_pointer_shape)shape;
-(void)newContent;
-(void)startThrobber;
-(void)stopThrobber;
-(void)setNavigationUrl: (NSString*)urlString;
-(void)setTitle: (NSString*)title;
-(void)findNext: (NSString*)needle matchCase: (BOOL)matchCase sender: (id)sender;
-(void)findPrevious: (NSString*)needle matchCase: (BOOL)matchCase sender: (id)sender;
-(void)showAll: (NSString*)needle matchCase: (BOOL)matchCase sender: (id)sender;
-(void)bookmarkPage: (id)sender;

@end
