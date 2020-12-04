/* All Rights reserved */

#import <AppKit/AppKit.h>
#import "BrowserWindowController.h"
#import "PlotView.h"
#import "netsurf/browser_window.h"
#import "utils/nsurl.h"
#import "desktop/browser_history.h"

@implementation BrowserWindowController

-(id)initWithBrowser: (struct browser_window*)aBrowser {
	if ((self = [super initWithWindowNibName: @"Browser"])) {
		browser = aBrowser;
	}
	return self;
}

-(void)awakeFromNib {
	[plotView setBrowser: browser];
	[scrollView setLineScroll: 25];
	NSLog(@"Browser window loaded");
}

-(void)back: (id)sender {
	NSLog(@"Browser backward");
	if (browser_window_history_back_available(browser)) {
		browser_window_history_back(browser, false);
	}
}

-(void)forward: (id)sender {
	NSLog(@"Browser forward");
	if (browser_window_history_forward_available(browser)) {
		browser_window_history_forward(browser, false);
	}
}

-(void)stopOrRefresh: (id)sender {
	int tag = [sender tag];
	if (tag == 1 && browser_window_stop_available(browser)) {
		browser_window_stop(browser);
	} else if (browser_window_reload_available(browser)) {
		browser_window_reload(browser, true);
	}
}

-(NSSize)getBrowserSize {
	return [[plotView superview] frame].size;
}
-(NSPoint)getBrowserScroll {
	return [plotView visibleRect].origin;
}
-(void)setBrowserScroll: (NSPoint)scroll {
	[plotView scrollPoint: scroll];
}
-(void)invalidateBrowser {
	[plotView setNeedsDisplay: YES];
}
-(void)invalidateBrowser: (NSRect)rect {
	[plotView setNeedsDisplayInRect: rect];
}
-(void)updateBrowserExtent {
	int width, height;
	browser_window_get_extents(browser, false, &width, &height);
	NSLog(@"set frame to size: %d, %d", width, height);
	[plotView setFrame: NSMakeRect(0, 0, width, height)];
}
-(void)removeCaret {

}
-(void)newContent {
	NSLog(@"New content");
	
}
-(void)startThrobber {
	[refreshButton setTitle: @"Stop"];
	[refreshButton setTag: 1];
}
-(void)stopThrobber {
	[refreshButton setTitle: @"Refresh"];
	[refreshButton setTag: 0];
}
-(void)setNavigationUrl: (NSString*)urlString {
	[urlBar setStringValue: urlString];
}
-(void)setTitle: (NSString*)title {
	[[self window] setTitle: title];
}

-(BOOL)control: (NSControl*)control textShouldEndEditing: (NSText*)fieldEditor {
	NSLog(@"textShouldEndEditing");


	nserror error;
	struct nsurl *url;
	NSString *string = [fieldEditor text];
	error = nsurl_create([string cString], &url);
	if (error != NSERROR_OK) {
		NSLog(@"nsurl_create error");
		return YES;
	}
	error = browser_window_navigate(browser, url, NULL, BW_NAVIGATE_HISTORY, NULL, NULL,
		NULL);
	if (error != NSERROR_OK) {
		NSLog(@"browser_window_navigate error");
	} else {
		NSLog(@"OK");
	}	
	nsurl_unref(url);
	return YES;
}

@end
