#import <Cocoa/Cocoa.h>

#import "netsurf/netsurf.h"
#import "netsurf/clipboard.h"

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

struct gui_clipboard_table gnustep_clipboard_table = {
	.get = gnustep_clipboard_get,
	.set = gnustep_clipboard_set
};
