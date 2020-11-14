/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "BrowserWindowController.h"

@implementation BrowserWindowController

-(void)windowDidLoad {
	NSLog(@"Browser window loaded");
}

-(id)back: (id)sender {
	NSLog(@"Browser backward");
}

-(id)forward: (id)sender {
	NSLog(@"Browser forward");
}

@end
