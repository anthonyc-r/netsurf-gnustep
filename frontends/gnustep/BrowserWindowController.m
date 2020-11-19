/* All Rights reserved */

#import <AppKit/AppKit.h>
#import "BrowserWindowController.h"
#import "PlotView.h"
#import "netsurf/browser_window.h"
#import "utils/nsurl.h"

@implementation BrowserWindowController

-(id)initWithBrowser: (struct browser_window*)aBrowser {
	if ((self = [super initWithWindowNibName: @"Browser"])) {
		browser = aBrowser;
	}
	return self;
}

-(void)awakeFromNib {
	plotView = [[PlotView alloc] initWithFrame: NSMakeRect(0, 0, 1000, 1000)];
	[plotView setBrowser: browser];
	[[scrollView contentView] addSubview: plotView];
	NSLog(@"Browser window loaded");
}

-(id)back: (id)sender {
	NSLog(@"Browser backward");
	[plotView display];
	bool ready = browser_window_redraw_ready(browser);
	if (ready) {
		NSLog(@"redraw ready!");
	}
	if (browser_window_has_content(browser)) {
		NSLog(@"has content");
	}
	struct nsurl *url = browser_window_access_url(browser);
	NSLog(@"url: '%s'", nsurl_access(url));
	
}

-(id)forward: (id)sender {
	NSLog(@"Browser forward");
}

@end
