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
#import "BookmarkFolder.h"
#import "CreateBookmarkPanelController.h"
#import "Preferences.h"
#import "SearchProvider.h"

static id newTabTarget;

@interface TabContents: NSObject {
	id scrollView;
	id plotView;
	struct browser_window *browser;
}
@end
@implementation TabContents
-(id)initWithScroll: (id)scroll plot: (id)plot browser: (struct browser_window *)brows {
	if ((self = [super init])) {
		scrollView = scroll;
		plotView = plot;
		browser = brows;
	}
	return self;
}
-(id)scrollView {
	return scrollView;
}
-(id)plotView {
	return plotView;
}
-(struct browser_window *)browser {
	return browser;
}
@end

@interface BrowserWindowController (Private)
-(void)openUrlString: (NSString*)aUrlString;
-(void)addTab: (struct browser_window*)aBrowser;
-(void)removeTab: (struct browser_window*)aBrowser;
-(void)reconfigureTabLayout;
-(void)setActive: (TabContents*)tabContents;
@end

@implementation BrowserWindowController

-(id)initWithBrowser: (struct browser_window*)aBrowser {
	if ((self = [super initWithWindowNibName: @"Browser"])) {
		browser = aBrowser;
		lastRequestedPointer = 999;
		tabs = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)dealloc {
	[tabs release];
	[super dealloc];
}

-(void)awakeFromNib {
	[tabView removeTabViewItem: [tabView tabViewItemAtIndex: 0]];
	[self addTab: browser];
	NSLog(@"Browser window loaded");
}

-(void)newTabWithBrowser: (struct browser_window*)aBrowser {
	[self addTab: aBrowser];
}

-(void)newTab: (id)sender {
	NSLog(@"Create new tab");
	struct nsurl *url;
	nserror error;
	NSString *startupUrl = [[Preferences defaultPreferences] startupUrl];

        error = nsurl_create([startupUrl cString], &url);

	if (error == NSERROR_OK) {
		newTabTarget = self;
		error = browser_window_create(BW_CREATE_HISTORY | BW_CREATE_TAB, url, 
			NULL, NULL, NULL);
		nsurl_unref(url);
	}
	if (error != NSERROR_OK) {
		NSLog(@"Failed to create window");
	}
}

-(void)close: (id)sender {
	NSLog(@"Close");
	NSTabViewItem *selectedTab = [tabView selectedTabViewItem];
	NSInteger idx = [tabView indexOfTabViewItem: selectedTab];
	if (idx == NSNotFound) {
		NSLog(@"Tab not found.");
		return;
	}
	TabContents *tc = [tabs objectAtIndex: idx];
	// This will call into netsurfWindowDestroy in the window.m callback...
	browser_window_destroy([tc browser]);

}
-(void)netsurfWindowDestroy {
	NSLog(@"ns destroy");
	NSTabViewItem *selectedTab = [tabView selectedTabViewItem];
	NSInteger idx = [tabView indexOfTabViewItem: selectedTab];
	if (idx == NSNotFound) {
		NSLog(@"Tab not found.");
		return;
	}
	[tabView removeTabViewItem: selectedTab];
	TabContents *tc = [tabs objectAtIndex: idx];
	[tabs removeObjectAtIndex: idx];
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
	NSString *string = [sender stringValue];
	if ([[Preferences defaultPreferences] searchFromUrlBar]) {
		SearchProvider *searchProvider = [[Preferences defaultPreferences] searchProvider];
		Website *website = [searchProvider websiteForQuery: [sender stringValue]];
		[self openWebsite: website];
	} else {
		[self openUrlString: string];
	}
}

-(void)enterSearch: (id)sender {
	NSLog(@"Searched for %@", [sender stringValue]);
	SearchProvider *searchProvider = [[Preferences defaultPreferences] searchProvider];
	Website *website = [searchProvider websiteForQuery: [sender stringValue]];
	[self openWebsite: website];
}

-(void)openWebsite: (Website*)aWebsite {
	[self openUrlString: [aWebsite url]];
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

-(void)bookmarkPage: (id)sender {
	struct nsurl *url = browser_window_access_url(browser);
	const char *title = browser_window_get_title(browser);
	if (title == NULL) {
		title = "";
	}
	NSString *name = [NSString stringWithCString: title];
	NSString *urlStr = [NSString stringWithCString: nsurl_access(url)];
	Website *website = [[Website alloc] initWithName: name 
		url: urlStr];
	CreateBookmarkPanelController *bmController = [[CreateBookmarkPanelController alloc] 
		initForWebsite: website];
	[NSApp runModalForWindow: [bmController window]];
	[bmController release];
	[website release];
}

-(NSString*)visibleUrl {
	struct nsurl *url = browser_window_access_url(browser);
	NSString *urlStr = [NSString stringWithCString: nsurl_access(url)];
	return urlStr;
}

-(void)openUrlString: (NSString*)aUrlString {
	nserror error;
	struct nsurl *url;

	error = nsurl_create([aUrlString cString], &url);
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

// MARK: - TabViewDelegate
-(void)tabView: (NSTabView*)aTabView didSelectTabViewItem: (NSTabViewItem*)aTabViewItem {
	NSLog(@"Selected tab");
	NSInteger idx = [aTabView indexOfTabViewItem: aTabViewItem];
	if (idx == NSNotFound || (NSInteger)[tabs count] <= idx) {
		NSLog(@"Tab not found...");
		return;
	}
	TabContents *tc = [tabs objectAtIndex: idx];
	[self setActive: tc];
}

-(void)addTab: (struct browser_window*)aBrowser {
	NSString *identity = @"tab";
	NSTabViewItem *tabItem = [[NSTabViewItem alloc] initWithIdentifier: 
		identity];
	[tabItem setLabel: identity];
	NSLog(@"TabView: %@", tabItem);
	NSView *innerView = [tabItem view];
	NSLog(@"Inner view: %@", innerView);
	PlotView *newPlotView = [[PlotView alloc] initWithFrame: [innerView bounds]];
	NSScrollView *newScrollView = [[NSScrollView alloc] initWithFrame: [innerView bounds]];
	[newScrollView setHasVerticalScroller: YES];
	[newScrollView setHasHorizontalScroller: YES];
	[newScrollView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
	[newScrollView setDocumentView: newPlotView];
	[innerView addSubview: newScrollView];
	
	[newPlotView setBrowser: aBrowser];
	[newScrollView setLineScroll: 25];
	NSInteger num = [tabView numberOfTabViewItems];
	[tabView insertTabViewItem: tabItem atIndex: num];
	
	TabContents *tc = [[TabContents alloc] initWithScroll: newScrollView plot:
		newPlotView browser: aBrowser];
	[self setActive: tc];
	[tabs addObject: tc];
	[tabView selectTabViewItem: tabItem];
	
	[tabItem release];
	[tc release];
	[newPlotView release];
	[newScrollView release];
}

-(void)removeTab: (struct browser_window*)aBrowser {

}

-(void)reconfigureTabLayout {

}

-(void)setActive: (TabContents*)tabContents {
	plotView = [tabContents plotView];
	scrollView = [tabContents scrollView];
	browser = [tabContents browser];
}

+(id)newTabTarget {
	return newTabTarget;
}
@end
