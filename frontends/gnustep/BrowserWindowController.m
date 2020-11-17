/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "BrowserWindowController.h"
#include "PlotView.h"

@implementation BrowserWindowController

-(id)initWithBrowser: (struct browser_window*)aBrowser {
	if ((self = [super initWithWindowNibName: @"Browser"])) {
		browser = aBrowser;
	}
	return self;
}

-(void)awakeFromNib {
	PlotView *plotView = [[PlotView alloc] initWithFrame: NSMakeRect(0, 0, 1000, 1000)];
	[plotView setBrowser: browser];
	[[scrollView contentView] addSubview: plotView];
	NSLog(@"Browser window loaded");
}

-(id)back: (id)sender {
	NSLog(@"Browser backward");
}

-(id)forward: (id)sender {
	NSLog(@"Browser forward");
}

@end
