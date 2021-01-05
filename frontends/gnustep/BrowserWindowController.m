/* All Rights reserved */

#import <AppKit/AppKit.h>
#import "BrowserWindowController.h"
#import "PlotView.h"
#import "Website.h"
#import "netsurf/browser_window.h"
#import "utils/nsurl.h"
#import "desktop/browser_history.h"
#import "netsurf/mouse.h"
#import "desktop/search.h"

@implementation BrowserWindowController

-(id)initWithBrowser: (struct browser_window*)aBrowser {
	if ((self = [super initWithWindowNibName: @"Browser"])) {
		browser = aBrowser;
		lastRequestedPointer = 999;
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
	[plotView back: sender];
}

-(void)forward: (id)sender {
	NSLog(@"Browser forward");
	[plotView forward: sender];
}

-(void)stopOrRefresh: (id)sender {
	int tag = [sender tag];
	if (tag == 1) {
		[plotView stopReloading: sender];
	} else {
		[plotView reload: sender];
	}
}

-(void)enterUrl: (id)sender {
	nserror error;
	struct nsurl *url;

	NSString *string = [sender stringValue];
	error = nsurl_create([string cString], &url);
	if (error != NSERROR_OK) {
		NSLog(@"nsurl_create error");
		return;
	}
	error = browser_window_navigate(browser, url, NULL, BW_NAVIGATE_HISTORY, NULL, NULL,
		NULL);
	if (error != NSERROR_OK) {
		NSLog(@"browser_window_navigate error");
	} else {
		NSLog(@"OK");
	}	
	nsurl_unref(url);
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
-(void)placeCaretAtX: (int)x y: (int)y height: (int)height {
	[plotView placeCaretAtX: x y: y height: height];
}
-(void)removeCaret {
	[plotView removeCaret];
}
-(void)setPointerToShape: (enum gui_pointer_shape)shape {
	if (shape == lastRequestedPointer)
		return;
	lastRequestedPointer = shape;
	NSLog(@"set pointer to shape %d", shape);
	switch (shape) {
	case GUI_POINTER_POINT: [[NSCursor pointingHandCursor] set]; break;
	case GUI_POINTER_CARET: [[NSCursor IBeamCursor] set]; break;
	case GUI_POINTER_MENU: [[NSCursor contextualMenuCursor] set]; break;
	case GUI_POINTER_UP: [[NSCursor resizeUpCursor] set]; break;
	case GUI_POINTER_DOWN: [[NSCursor resizeDownCursor] set]; break;
	case GUI_POINTER_LEFT: [[NSCursor resizeLeftCursor] set]; break;
	case GUI_POINTER_RIGHT: [[NSCursor resizeRightCursor] set]; break;
	case GUI_POINTER_CROSS: [[NSCursor crosshairCursor] set]; break;
	case GUI_POINTER_NO_DROP: [[NSCursor operationNotAllowedCursor] set]; break;
	case GUI_POINTER_NOT_ALLOWED: [[NSCursor operationNotAllowedCursor] set]; break;
	case GUI_POINTER_MOVE: [[NSCursor closedHandCursor] set]; break;
	case GUI_POINTER_HELP:
	case GUI_POINTER_PROGRESS:
	case GUI_POINTER_WAIT: 
	case GUI_POINTER_RU: 
	case GUI_POINTER_LD:
	case GUI_POINTER_LU:
	case GUI_POINTER_RD:
	case GUI_POINTER_DEFAULT:
	default: 
		[[NSCursor arrowCursor] set];
	}
}
-(void)newContent {
	NSLog(@"New content");
	struct nsurl *url = browser_window_access_url(browser);
	const char *title = browser_window_get_title(browser);
	if (title == NULL) {
		title = "";
	}
	NSString *name = [NSString stringWithCString: title];
	NSString *urlStr = [NSString stringWithCString: nsurl_access(url)];
	Website *website = [[Website alloc] initWithName: name 
		url: urlStr];
	[website addToHistory];
	[website release];
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

-(void)findNext: (NSString*)needle matchCase: (BOOL)matchCase sender: (id)sender {
	search_flags_t flags = SEARCH_FLAG_FORWARDS;
	if (matchCase) {
		flags |= SEARCH_FLAG_CASE_SENSITIVE;
	}
	browser_window_search(browser, (void*)sender, flags, [needle cString]);
}

-(void)findPrevious: (NSString*)needle matchCase: (BOOL)matchCase sender: (id)sender {
	search_flags_t flags = SEARCH_FLAG_BACKWARDS;
	if (matchCase) {
		flags |= SEARCH_FLAG_CASE_SENSITIVE;
	}
	browser_window_search(browser, (void*)sender, flags, [needle cString]);
}

-(void)showAll: (NSString*)needle matchCase: (BOOL)matchCase sender: (id)sender {
	search_flags_t flags = SEARCH_FLAG_SHOWALL;
	if (matchCase) {
		flags |= SEARCH_FLAG_CASE_SENSITIVE;
	}
	browser_window_search(browser, (void*)sender, flags, [needle cString]);
}

@end