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
	[self didTapNewWindow: self];
}

-(void)didTapNewWindow: (id)sender {
	NSLog(@"Will create a new window");
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

-(void)showHistoryWindowController: (id)sender {
	NSLog(@"Showing history ...");
	if (!historyWindowController) {
		historyWindowController = [[HistoryWindowController alloc] init];
		[historyWindowController loadWindow];
	} else {
		[historyWindowController showWindow: self];
	}
}

-(NSURL*)requestDownloadDestination {
	NSSavePanel *savePanel = [NSOpenPanel savePanel];
	[savePanel setDirectory: NSHomeDirectory()];
	[savePanel runModal];
	return [savePanel URL];
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