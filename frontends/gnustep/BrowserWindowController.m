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

#define TAB_TITLE_LEN 20
// Everything above the browser. Used to calculate the tabview's height.
#define TOP_CONTENT_HEIGHT 74
// Any way to get this programatically?
#define TAB_ITEM_HEIGHT 13

static id newTabTarget;

@interface TabContents: NSObject {
	id scrollView;
	id plotView;
	struct browser_window *browser;
	id tabItem;
}
@end
@implementation TabContents
-(id)initWithScroll: (id)scroll plot: (id)plot browser: (struct browser_window *)brows tabItem: (NSTabViewItem*)aTabItem {
	if ((self = [super init])) {
		scrollView = scroll;
		plotView = plot;
		browser = brows;
		tabItem = aTabItem;
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
-(id)tabItem {
	return tabItem;
}
@end

@interface BrowserWindowController (Private)
-(void)openUrlString: (NSString*)aUrlString;
-(id)addTab: (struct browser_window*)aBrowser;
-(void)reconfigureTabLayout;
-(void)setActive: (TabContents*)tabContents;
-(Website*)currentWebsiteForTab: (id)tab;
-(void)updateTabsVisibility;
-(void)onPreferencesUpdated: (id)sender;
@end

@implementation BrowserWindowController

-(id)initWithBrowser: (struct browser_window*)aBrowser {
	if ((self = [super initWithWindowNibName: @"Browser"])) {
		browser = aBrowser;
		lastRequestedPointer = 999;
		tabs = [[NSMutableArray alloc] init];
		isClosing = NO;
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
	[[NSNotificationCenter defaultCenter] addObserver: self
		selector: @selector(onPreferencesUpdated:)
		name: PreferencesUpdatedNotificationName
		object: nil];
	NSLog(@"Browser window loaded");
}

-(id)newTabWithBrowser: (struct browser_window*)aBrowser {
	return [self addTab: aBrowser];
}

-(void)newTab: (id)sender {
	NSLog(@"Create new tab");
	struct nsurl *url;
	nserror error;
	NSString *startupUrl;
	if ([sender isKindOfClass: [NSString class]]) {
		startupUrl = sender;
	} else {
		startupUrl = [[Preferences defaultPreferences] startupUrl];
	}
	
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

-(void)windowWillClose: (NSNotification*)aNotification {
	NSLog(@"Window will close...");
	isClosing = YES;
	for (NSUInteger i = 0; i < [tabs count]; i++) {
		browser_window_destroy([[tabs objectAtIndex: i] browser]);
	}
	[[NSNotificationCenter defaultCenter] removeObserver: self];
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
-(void)netsurfWindowDestroyForTab: (id)tab {
	NSLog(@"ns destroy");
	// If we're closing anyway, don't bother with tab cleanup.
	if (isClosing) {
		return;
	}
	NSInteger idx = [tabView indexOfTabViewItem: [tab tabItem]];
	if (idx == NSNotFound) {
		NSLog(@"Tab not found.");
		return;
	}
	[tabView removeTabViewItem: [tab tabItem]];
	[tabs removeObjectAtIndex: idx];
	if (activeTab == tab) {
		activeTab = nil;
	}
	if ([tabs count] < 1) {
		[super close];
	} else {
		[self updateTabsVisibility];
	}
}

// The identifier for the first tab created. Used by window.m after creation.
// This is actually a TabContents object, for easy access to the required objects.
-(id)initialTabId {
	return [tabs objectAtIndex: 0];
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

-(NSSize)getBrowserSizeForTab: (id)tab {
	return [[[tab plotView] superview] frame].size;
}
-(NSPoint)getBrowserScrollForTab: (id)tab {
	return [[tab plotView] visibleRect].origin;
}
-(void)setBrowserScroll: (NSPoint)scroll forTab: (id)tab {
	[[tab plotView] scrollPoint: scroll];
}
-(void)invalidateBrowserForTab: (id)tab {
	[[tab plotView] setNeedsDisplay: YES];
}
-(void)invalidateBrowser: (NSRect)rect forTab: (id)tab {
	[[tab plotView] setNeedsDisplayInRect: rect];
}
-(void)updateBrowserExtentForTab: (id)tab {
	int width, height;
	browser_window_get_extents([tab browser], false, &width, &height);
	NSLog(@"set frame to size: %d, %d", width, height);
	[[tab plotView] setFrame: NSMakeRect(0, 0, width, height)];
}
-(void)placeCaretAtX: (int)x y: (int)y height: (int)height inTab: (id)tab {
	NSLog(@"Place caret... on %@", plotView);
	[[tab plotView] placeCaretAtX: x y: y height: height];
}
-(void)removeCaretInTab: (id)tab {
	[[tab plotView] removeCaret];
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
-(void)newContentForTab: (id)tab {
	NSLog(@"New content");
	Website *website = [self currentWebsiteForTab: activeTab];
	[website addToHistory];
}
-(void)startThrobber {
	[refreshButton setTitle: @"Stop"];
	[refreshButton setTag: 1];
}
-(void)stopThrobber {
	[refreshButton setTitle: @"Refresh"];
	[refreshButton setTag: 0];
}
-(void)setNavigationUrl: (NSString*)urlString forTab: (id)tab {
	[urlBar setStringValue: urlString];
}
-(void)setTitle: (NSString*)title forTab: (id)tab {
	[[self window] setTitle: title];
	NSString *tabTitle = title;
	if ([tabTitle length] > TAB_TITLE_LEN) {
		tabTitle = [title substringToIndex: TAB_TITLE_LEN];
	}
	[[tab tabItem] setLabel: tabTitle];
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
	Website *website = [self currentWebsiteForTab: activeTab];
	CreateBookmarkPanelController *bmController = [[CreateBookmarkPanelController alloc] 
		initForWebsite: website];
	[NSApp runModalForWindow: [bmController window]];
	[bmController release];
}

-(NSString*)visibleUrl {
	return [[self currentWebsiteForTab: activeTab] url];
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

-(id)addTab: (struct browser_window*)aBrowser {
	NSString *identity = @"New Tab";
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
		newPlotView browser: aBrowser tabItem: tabItem];
	[self setActive: tc];
	[tabs addObject: tc];
	[tabView selectTabViewItem: tabItem];
	
	[tabItem release];
	[tc release];
	[newPlotView release];
	[newScrollView release];
	@try {
	[self updateTabsVisibility];
	}
	@catch (NSException *e) {
		NSLog(@"%@", e);
	}
	return tc;
}

-(void)reconfigureTabLayout {

}

-(void)setActive: (TabContents*)tabContents {
	plotView = [tabContents plotView];
	scrollView = [tabContents scrollView];
	browser = [tabContents browser];
	activeTab = tabContents;
	Website *website = [self currentWebsiteForTab: activeTab];
	[urlBar setStringValue: [website url]];
	[[self window] setTitle: [website name]];
}

-(Website*)currentWebsiteForTab: (id)tab {
	struct nsurl *url = browser_window_access_url(browser);
	const char *title = browser_window_get_title(browser);
	if (title == NULL) {
		title = "";
	}
	NSString *name = [NSString stringWithCString: title];
	NSString *urlStr = [NSString stringWithCString: nsurl_access(url)];
	Website *website = [[Website alloc] initWithName: name 
		url: urlStr];
	return [website autorelease];
}

-(void)updateTabsVisibility {
	BOOL hideTabs = [tabs count] < 2 && ![[Preferences defaultPreferences] 
		alwaysShowTabs];
	NSRect rect = [tabView frame];
	rect.size.height = [[self window] frame].size.height - TOP_CONTENT_HEIGHT;
	if (hideTabs) {
		[tabView setTabViewType: NSNoTabsNoBorder];
	} else {
		[tabView setTabViewType: NSTopTabsBezelBorder];
	}
	[tabView setFrame: rect];
	// Work around a graphical glitch where the tab view doesn't properly readjust itself
	[tabView selectTabViewItem: [activeTab tabItem]];
}

-(void)onPreferencesUpdated: (id)sender {
	id dict = [sender object];
	PreferenceType type = (PreferenceType)[[dict objectForKey: @"type"] integerValue];
	if (type == PreferenceTypeAlwaysShowTabs) {
		[self updateTabsVisibility];
	}
}

+(id)newTabTarget {
	return newTabTarget;
}
@end
