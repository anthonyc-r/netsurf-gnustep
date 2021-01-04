#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "netsurf/netsurf.h"
#import "utils/nsoption.h"
#import "utils/nsurl.h"
#import "utils/log.h"

#import "AppDelegate.h"
#import "BrowserWindowController.h"
#import "tables/tables.h"
#import "tables/misc.h"
#import "netsurf/browser_window.h"
#import "DownloadsWindowController.h"
#import "FindPanelController.h"
#import "HistoryWindowController.h"
#import "Website.h"
#import "BookmarksWindowController.h"

#define MAX_RECENT_HISTORY 10

/**
 * Set option defaults for (taken from the cocoa frontend)
 *
 * @param defaults The option table to update.
 * @return error status
 */
static nserror set_defaults(struct nsoption_s *defaults)
{
        /* Set defaults for absent option strings */
        const char * const ca_bundle = [[[NSBundle mainBundle] pathForResource: @"ca-bundle" ofType: @""] UTF8String];
	if (ca_bundle == NULL) {
		return NSERROR_BAD_URL;
	}

        nsoption_setnull_charp(ca_bundle, strdup(ca_bundle));
        return NSERROR_OK;
}


@implementation AppDelegate 


-(void)applicationDidFinishLaunching: (NSNotification*)aNotification {
	NSLog(@"NSApp did finish launching..");
	[NSBundle loadNibNamed: @"Menu" owner: NSApp];
}

-(void)historyUpdated: (NSNotification*)aNotification {
	NSLog(@"history updated... %@", aNotification);
	id object = [aNotification object];
	NSMenu *historyMenu = [[[NSApp menu] itemWithTag: TAG_SUBMENU_HISTORY] submenu];
	
	if ([object isKindOfClass: [Website class]]) {
		[recentHistory insertObject: object atIndex: 0];
		NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle: [object name]
			action: @selector(open) keyEquivalent: nil] autorelease];
		[menuItem setTarget: object];
		[historyMenu insertItem: menuItem atIndex: 1];
		if ([recentHistory count] > MAX_RECENT_HISTORY) {
			[recentHistory removeLastObject];
			[historyMenu removeItemAtIndex: [historyMenu numberOfItems] - 1];
		}
	}
}

-(void)awakeFromNib {
	NSLog(@"App awake from nib");
	recentHistory = [[NSMutableArray alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver: self
		selector: @selector(historyUpdated:)
		name: WebsiteHistoryUpdatedNotificationName
		object: nil];
	[self historyUpdated: nil];
}

-(void)didTapNewWindow: (id)sender {
	NSLog(@"Will create a new window %@", self);
	struct nsurl *url;
	nserror error;

        error = nsurl_create("https://www.startpage.com", &url);

	if (error == NSERROR_OK) {
		error = browser_window_create(BW_CREATE_HISTORY, url, NULL, NULL, NULL);
		nsurl_unref(url);
	}
	if (error != NSERROR_OK) {
		NSLog(@"Failed to create window");
	}
}

-(void)showDownloadsWindow: (id)sender {
	NSLog(@"Showing downloads ...");
	if (!downloadsWindowController) {
		downloadsWindowController = [[DownloadsWindowController alloc] init];
		[downloadsWindowController loadWindow];
	} else {
		[downloadsWindowController showWindow: self];
	}
}

-(void)showFindPanel: (id)sender {
	NSLog(@"Showing find panel ...");
	if (!findPanelController) {
		findPanelController = [[FindPanelController alloc] init];
		[findPanelController loadWindow];
	} else {
		[findPanelController showWindow: self];
	}
}

-(void)showHistoryWindow: (id)sender {
	NSLog(@"Showing history ...");
	if (!historyWindowController) {
		historyWindowController = [[HistoryWindowController alloc] init];
		[historyWindowController loadWindow];
	} else {
		[historyWindowController showWindow: self];
	}
}

-(void)showBookmarksWindow: (id)sender {
	NSLog(@"Showing bookmarks...");
	if (!bookmarksWindowController) {
		bookmarksWindowController = [[BookmarksWindowController alloc] init];
		[bookmarksWindowController loadWindow];
	} else {
		[bookmarksWindowController showWindow: self];
	}
}

-(NSURL*)requestDownloadDestination {
	NSSavePanel *savePanel = [NSOpenPanel savePanel];
	[savePanel setDirectory: NSHomeDirectory()];
	[savePanel runModal];
	return [savePanel URL];
}

-(void)openWebsite: (Website*)aWebsite {
	struct nsurl *url;
	nserror error;
	
	error = nsurl_create([[aWebsite url] cString], &url);
	if (error == NSERROR_OK) {
		error = browser_window_create(BW_CREATE_HISTORY, url, NULL, NULL, NULL);
		nsurl_unref(url);
	}
	if (error != NSERROR_OK) {
		NSLog(@"Failed to create window");
	}
}

@end

int main(int argc, char **argv) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	nslog_init(NULL, &argc, argv);
       nserror error;
       struct netsurf_table gnustep_table = {
               .misc = &gnustep_misc_table,
               .window = &gnustep_window_table,
               .clipboard = &gnustep_clipboard_table,
               .download = &gnustep_download_table,
               .fetch = &gnustep_fetch_table,
               .search = &gnustep_search_table,
               .bitmap = &gnustep_bitmap_table,
               .layout = &gnustep_layout_table,
       };
       error = netsurf_register(&gnustep_table);
	NSCAssert(error == NSERROR_OK, @"NetSurf operation table failed registration");
	
       /* common initialisation */
	error = nsoption_init(set_defaults, &nsoptions, &nsoptions_default);
       NSCAssert(error == NSERROR_OK, @"Options failed to initialise");
       error = netsurf_init(NULL);
       NSCAssert(error == NSERROR_OK, @"NetSurf failed to initialise");
		
	NSApplication *app = [NSApplication sharedApplication];
	AppDelegate *delegate = [AppDelegate new];
	[app setDelegate: delegate];
	[app run];
	[pool release];
	return 0;
}