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
	plotView = [[PlotView alloc] initWithFrame: NSMakeRect(0, 0, 800, 600)];
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

-(NSSize)getBrowserSize {
	return [plotView frame].size;
}
-(void)invalidateBrowser {
	[plotView setNeedsDisplay: YES];
}
-(void)invalidateBrowser: (NSRect)rect {
	[plotView setNeedsDisplayInRect: rect];
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
