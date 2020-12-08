#import <Cocoa/Cocoa.h>

#import "netsurf/netsurf.h"
#import "netsurf/download.h"


/**********************/
/****** Download ******/
/**********************/

// This won't really return a window ref, but a ref to a download item.
static struct gui_download_window *gnustep_download_create(struct download_context *ctx, struct gui_window *parent) {
	NSLog(@"gnustep_download_create");
	// Save dialog.. then...
	[[NSApp delegate] showDownloadsWindow];
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

struct gui_download_table gnustep_download_table = {
	.create = gnustep_download_create,
	.data = gnustep_download_data,
	.error = gnustep_download_error,
	.done = gnustep_download_done
};