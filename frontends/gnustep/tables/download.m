#import <Cocoa/Cocoa.h>

#import "netsurf/netsurf.h"
#import "netsurf/download.h"
#import "desktop/download.h"
#import "DownloadManager.h"
#import "AppDelegate.h"

/**********************/
/****** Download ******/
/**********************/

// This won't really return a window ref, but a ref to a download item.
static struct gui_download_window *gnustep_download_create(struct download_context *ctx, struct gui_window *parent) {
	NSLog(@"gnustep_download_create");
	NSURL *url = [[NSApp delegate] requestDownloadDestination];
	NSInteger dataSize = download_context_get_total_length(ctx);
	DownloadItem *download = [[DownloadManager defaultDownloadManager]
		createDownloadForDestination: url withSizeInBytes: dataSize];
	[[NSApp delegate] showDownloadsWindow: nil];
	return (struct gui_download_window*)download;
}

// ??
static nserror gnustep_download_data(struct gui_download_window *dw,	const char *data, unsigned int size) {
	NSLog(@"gnustep_download_data");

	BOOL success = [(id)dw appendToDownload: [NSData dataWithBytesNoCopy: (void*)data
		length: size freeWhenDone: NO]];
	if (success) {
		return NSERROR_OK;
	} else {
		return NSERROR_SAVE_FAILED;
	}
}

// Error occurred during download
static void gnustep_download_error(struct gui_download_window *dw, const char *error_msg) {
	NSLog(@"gnustep_download_error");
	[(id)dw failWithMessage: [NSString stringWithCString: error_msg]];
}

// Download completed
static void gnustep_download_done(struct gui_download_window *dw) {
	NSLog(@"gnustep_download_done");
	[(id)dw complete];
}

struct gui_download_table gnustep_download_table = {
	.create = gnustep_download_create,
	.data = gnustep_download_data,
	.error = gnustep_download_error,
	.done = gnustep_download_done
};