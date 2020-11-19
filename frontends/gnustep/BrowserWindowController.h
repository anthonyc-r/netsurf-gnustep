/* All Rights reserved */

#include <AppKit/AppKit.h>

struct browser_window;
@interface BrowserWindowController : NSWindowController<NSTextFieldDelegate> {
	id backButton;
	id forwardButton;
	id scrollView;
	id urlBar;
	struct browser_window *browser;
	id plotView;
}

-(id)initWithBrowser: (struct browser_window*)aBrowser;
-(id)back: (id)sender;
-(id)forward: (id)sender;
@end
