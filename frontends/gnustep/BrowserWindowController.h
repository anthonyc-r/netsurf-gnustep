/* All Rights reserved */

#include <AppKit/AppKit.h>

@interface BrowserWindowController : NSWindowController<NSTextFieldDelegate>
{
  id backButton;
  id forwardButton;
  id scrollView;
  id urlBar;
}

-(id)back: (id)sender;
-(id)forward: (id)sender;
@end
