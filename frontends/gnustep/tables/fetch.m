#import <Cocoa/Cocoa.h>

#import "netsurf/netsurf.h"
#import "netsurf/fetch.h"

/*******************/
/****** Fetch ******/ 
/*******************/

// Return the MIME type of the specified file. Returned string can be inval on next req.
static const char *gnustep_fetch_filetype(const char *unix_path) {
	static char filetype[100];
	filetype[0] = '\0';
	return filetype;
}

struct gui_fetch_table gnustep_fetch_table = {
	.filetype = gnustep_fetch_filetype
};