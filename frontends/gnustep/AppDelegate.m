#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


#import "AppDelegate.h"
#import "BrowserWindowController.h"

#import "netsurf/netsurf.h"
#import "netsurf/misc.h"
#import "netsurf/window.h"
#import "netsurf/clipboard.h"
#import "netsurf/download.h"
#import "netsurf/fetch.h"
#import "netsurf/search.h"
#import "netsurf/bitmap.h"
#import "netsurf/layout.h"
#import "netsurf/browser_window.h"
#import "utils/nsoption.h"
#import "utils/nsurl.h"

/*******************/
/****** Misc *******/
/*******************/

// Schedule a callback to be run after t ms, or removed if ngtv, func and param.
static nserror gnustep_misc_schedule(int t, void (*callback)(void *p), void *p) {
	NSLog(@"gnustep_misc_schedule");
	return NSERROR_OK;
}

static struct gui_misc_table gnustep_misc_table = {
	.schedule = gnustep_misc_schedule
};

/********************/
/****** Window ******/
/********************/

// Create and open a browser window
static struct gui_window *gnustep_window_create(struct browser_window *bw,
			struct gui_window *existing,
			gui_window_create_flags flags) {
	NSLog(@"gnustep_window_create");
	BrowserWindowController *controller = [[BrowserWindowController alloc] 
		initWithWindowNibName: @"Browser"];
	[controller loadWindow];
	return (struct gui_window*)controller;
}

// Destroy the specified window
static void gnustep_window_destroy(struct gui_window *gw) {
	NSLog(@"gnustep_window_destroy");
}

// Trigger a redraw of the specified area, or the entire window if null
static nserror gnustep_window_invalidate(struct gui_window *gw, const struct rect *rect) {
	NSLog(@"gnustep_window_invalidate");
	return NSERROR_OK;
}

// Put the current scroll offset into sx and sy
static bool gnustep_window_get_scroll(struct gui_window *gw, int *sx, int *sy) {
	NSLog(@"gnustep_window_get_scroll");
	return true;
}

// Set the current scroll offset
static nserror gnustep_window_set_scroll(struct gui_window *gw, const struct rect *rect) {
	NSLog(@"gnustep_window_set_scroll");
	return NSERROR_OK;
}

// Put the dimensions of the specified window into width, height
static nserror gnustep_window_get_dimensions(struct gui_window *gw, int *width, int *height) {
	NSLog(@"gnustep_window_get_dimensions");
	return NSERROR_OK;
}

// Some kind of event happened
static nserror gnustep_window_event(struct gui_window *gw, enum gui_window_event event) {
	NSLog(@"gnustep_window_event");
	return NSERROR_OK;
}

static struct gui_window_table gnustep_window_table = {
	.create = gnustep_window_create,
	.destroy = gnustep_window_destroy,
	.invalidate = gnustep_window_invalidate,
	.get_scroll = gnustep_window_get_scroll,
	.set_scroll = gnustep_window_set_scroll,
	.get_dimensions = gnustep_window_get_dimensions,
	.event = gnustep_window_event
};

/***********************/
/****** Clipboard ******/
/***********************/

// Put content of clipboard into buffer up to a maximum length
static void gnustep_clipboard_get(char **buffer, size_t *length) {
	NSLog(@"gnustep_clipboard_get");
}

// Save the provided clipboard for later retreival above
static void gnustep_clipboard_set(const char *buffer, size_t length, nsclipboard_styles styles[], int n_styles) {
	NSLog(@"gnustep_clipboard_set");
}

static struct gui_clipboard_table gnustep_clipboard_table = {
	.get = gnustep_clipboard_get,
	.set = gnustep_clipboard_set
};

/**********************/
/****** Download ******/
/**********************/

// Create and display a downloads window?
static struct gui_download_window *gnustep_download_create(struct download_context *ctx, struct gui_window *parent) {
	NSLog(@"gnustep_download_create");
	return NULL;
}

// ??
static nserror gnustep_download_data(struct gui_download_window *dw,	const char *data, unsigned int size) {
	NSLog(@"gnustep_download_data");
	return NSERROR_OK;
}

// Error occurred during download
static void gnustep_download_error(struct gui_download_window *dw, const char *error_msg) {
	NSLog(@"gnustep_download_error");
}

// Download completed
static void gnustep_download_done(struct gui_download_window *dw) {
	NSLog(@"gnustep_download_done");
}

static struct gui_download_table gnustep_download_table = {
	.create = gnustep_download_create,
	.data = gnustep_download_data,
	.error = gnustep_download_error,
	.done = gnustep_download_done
};

/*******************/
/****** Fetch ******/ 
/*******************/

// Return the MIME type of the specified file. Returned string can be inval on next req.
static const char *gnustep_fetch_filetype(const char *unix_path) {
	static char filetype[100];
	filetype[0] = '\0';
	return filetype;
}

static struct gui_fetch_table gnustep_fetch_table = {
	.filetype = gnustep_fetch_filetype
};

/********************/
/****** Search ******/
/********************/

// Change displayed search status found/notfound?
static void gnustep_search_status(bool found, void *p) {
	NSLog(@"gnustep_search_status");
}

// Show hourglass if active else stop hourglass
static void gnustep_search_hourglass(bool active, void *p) {
	NSLog(@"gnustep_search_hourglass");
}

// Add search string to recent searches list
static void gnustep_search_add_recent(const char *string, void *p) {
	NSLog(@"gnustep_search_add_recent");
}

// Set the next match button to active/inactive
static void gnustep_search_forward_state(bool active, void *p) {
	NSLog(@"gnustep_search_forward_state");
}

// set the previous match button to active/inactive
static void gnustep_search_back_state(bool active, void *p) {
	NSLog(@"gnustep_search_back_state");
}

static struct gui_search_table gnustep_search_table = {
	.status = gnustep_search_status,
	.hourglass = gnustep_search_hourglass,
	.add_recent = gnustep_search_add_recent,
	.forward_state = gnustep_search_forward_state,
	.back_state = gnustep_search_back_state
};

/********************/
/****** Bitmap ******/
/********************/

// Create a new bitmap of width height
static void *gnustep_bitmap_create(int width, int height, unsigned int state) {
	NSLog(@"gnustep_bitmap_create");
	return NULL;
}

// Destroy the specified bitmap
static void gnustep_bitmap_destroy(void *bitmap) {
	NSLog(@"gnustep_bitmap_destroy");
}

// Set whether it's opaque or not
static void gnustep_bitmap_set_opaque(void *bitmap, bool opaque) {
	NSLog(@"gnustep_bitmap_set_opaque");
}

// Get whether it's opaque or not
static bool gnustep_bitmap_get_opaque(void *bitmap) {
	NSLog(@"gnustep_bitmap_get_opaque");
	return 0;
}

// Test? whether it's opaque or not
static bool gnustep_bitmap_test_opaque(void *bitmap) {
	NSLog(@"gnustep_bitmap_test_opaque");
	return 0;
}

// Get the image buffer for the bitmap
static unsigned char *gnustep_bitmap_get_buffer(void *bitmap) {
	NSLog(@"gnustep_bitmap_get_buffer");
	return NULL;
}

// Get the number of bytes per row of the bitmap
static size_t gnustep_bitmap_get_rowstride(void *bitmap) {
	NSLog(@"gnustep_bitmap_get_rowstride");
	return 0;
}

// Get its width in pixels
static int gnustep_bitmap_get_width(void *bitmap) {
	NSLog(@"gnustep_bitmap_get_width");
	return 0;
}

// Get height in pixels
static int gnustep_bitmap_get_height(void *bitmap) {
	NSLog(@"gnustep_bitmap_get_height");
	return 0;
}

// Get how many byytes pet pixel
static size_t gnustep_bitmap_get_bpp(void *bitmap) {
	NSLog(@"gnustep_bitmap_get_bpp");
	return 0;
}

// Save the bitmap to the specified path
static bool gnustep_bitmap_save(void *bitmap, const char *path, unsigned flags) {
	NSLog(@"gnustep_bitmap_save");
	return 0;
}

// Mark bitmap as modified
static void gnustep_bitmap_modified(void *bitmap) {
	NSLog(@"gnustep_bitmap_modified");
}

// Render content into the specified bitmap
static nserror gnustep_bitmap_render(struct bitmap *bitmap, struct hlcache_handle *content) {
	NSLog(@"gnustep_bitmap_render");
	return NSERROR_OK;
}

static struct gui_bitmap_table gnustep_bitmap_table = {
	.create = gnustep_bitmap_create,
	.destroy = gnustep_bitmap_destroy,
	.set_opaque = gnustep_bitmap_set_opaque,
	.get_opaque = gnustep_bitmap_get_opaque,
	.test_opaque = gnustep_bitmap_test_opaque,
	.get_buffer = gnustep_bitmap_get_buffer,
	.get_rowstride = gnustep_bitmap_get_rowstride,
	.get_width = gnustep_bitmap_get_width,
	.get_height = gnustep_bitmap_get_height,
	.get_bpp = gnustep_bitmap_get_bpp,
	.save = gnustep_bitmap_save,
	.modified = gnustep_bitmap_modified,
	.render = gnustep_bitmap_render
};

/****** Layout ******/

// Put the measured width of the string into width
static nserror gnustep_layout_width(const struct plot_font_style *fstyle, const char *string, size_t length, int *width) {
	*width = 0;
	NSLog(@"gnustep_layout_width");
}

// Put the character offset and actual x coordinate of the character for which the x 
// coordinate is nearest to
static nserror gnustep_layout_position(const struct plot_font_style *fstyle, const char *string, size_t length, int x, size_t *char_offset, int *actual_x) {
	*char_offset = 0;
	*actual_x = 0;
	NSLog(@"gnustep_layout_position");
}

// Put the char offset and x coordinate of where to split a string so it fits in width x
static nserror gnustep_layout_split(const struct plot_font_style *fstyle, const char *string, size_t length, int x, size_t *char_offset, int *actual_x) {
	*char_offset = 0;
	*actual_x = 0;
	NSLog(@"gnustep_layout_split");
}

static struct gui_layout_table gnustep_layout_table = {
	.width = gnustep_layout_width,
	.position = gnustep_layout_position,
	.split = gnustep_layout_split
};

/**
 * Set option defaults for (taken from the cocoa frontend)
 *
 * @param defaults The option table to update.
 * @return error status.
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

-(void)didTapNewWindow: (id)sender {
	NSLog(@"Will create a new window");
	struct nsurl *url;
	nserror error;
        if (nsoption_charp(homepage_url) != NULL) {
                error = nsurl_create(nsoption_charp(homepage_url), &url);
	} else {
                error = nsurl_create(NETSURF_HOMEPAGE, &url);
	}

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