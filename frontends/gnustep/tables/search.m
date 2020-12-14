#import <Cocoa/Cocoa.h>

#import "netsurf/netsurf.h"
#import "netsurf/search.h"


/********************/
/****** Search ******/
/********************/

// Change displayed search status found/notfound?
static void gnustep_search_status(bool found, void *p) {
	NSLog(@"gnustep_search_status");
	[(id)p setFound: found ? YES : NO];
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
	[(id)p setCanFindNext: active ? YES : NO];
}

// set the previous match button to active/inactive
static void gnustep_search_back_state(bool active, void *p) {
	NSLog(@"gnustep_search_back_state");
	[(id)p setCanFindPrevious: active ? YES : NO];
}

struct gui_search_table gnustep_search_table = {
	.status = gnustep_search_status,
	.hourglass = gnustep_search_hourglass,
	.add_recent = gnustep_search_add_recent,
	.forward_state = gnustep_search_forward_state,
	.back_state = gnustep_search_back_state
};