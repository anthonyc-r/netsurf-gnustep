/* All Rights reserved */

#import <AppKit/AppKit.h>
#import "netsurf/netsurf.h"
#import "netsurf/mouse.h"

struct browser_window;
@interface BrowserWindowController : NSWindowController<NSTextFieldDelegate> {
	id backButton;
	id forwardButton;
	id urlBar;
	struct browser_window *browser;
	id plotView;
	id scrollView;
	id refreshButton;
	id caretView;
	enum gui_pointer_shape lastRequestedPointer;
}

-(id)initWithBrowser: (struct browser_window*)aBrowser;
-(void)back: (id)sender;
-(void)forward: (id)sender;
-(void)stopOrRefresh: (id)sender;

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
-(void)findNext: (NSString*)needle matchCase: (BOOL)matchCase;
-(void)findPrevious: (NSString*)needle matchCase: (BOOL)matchCase;
-(void)showAll: (NSString*)needle matchCase: (BOOL)matchCase;
@end
