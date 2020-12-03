/* All Rights reserved */

#include <AppKit/AppKit.h>

struct browser_window;
@interface BrowserWindowController : NSWindowController<NSTextFieldDelegate> {
	id backButton;
	id forwardButton;
	id urlBar;
	struct browser_window *browser;
	id plotView;
}

-(id)initWithBrowser: (struct browser_window*)aBrowser;
-(id)back: (id)sender;
-(id)forward: (id)sender;

// Browser control
-(NSSize)getBrowserSize;
-(NSPoint)getBrowserScroll;
-(void)setBrowserScroll: (NSPoint)scroll;
-(void)invalidateBrowser;
-(void)invalidateBrowser: (NSRect)rect;
-(void)updateBrowserExtent;
-(void)removeCaret;
-(void)newContent;
-(void)startThrobber;
-(void)stopThrobber;
-(void)setNavigationUrl: (NSString*)urlString;
-(void)setTitle: (NSString*)title;
@end
