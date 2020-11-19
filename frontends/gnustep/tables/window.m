#import <Cocoa/Cocoa.h>

#import "BrowserWindowController.h"
#import "netsurf/netsurf.h"
#import "netsurf/window.h"

/********************/
/****** Window ******/
/********************/

// Create and open a browser window
static struct gui_window *gnustep_window_create(struct browser_window *bw,
			struct gui_window *existing,
			gui_window_create_flags flags) {
	NSLog(@"gnustep_window_create");
	BrowserWindowController *controller = [[BrowserWindowController alloc]
		initWithBrowser: bw]; 
		
	[controller loadWindow];
	return (struct gui_window*)controller;
}

// Destroy the specified window
static void gnustep_window_destroy(struct gui_window *gw) {
	NSLog(@"gnustep_window_destroy");
	[(id)gw release];
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
	switch (event) {
	case GW_EVENT_UPDATE_EXTENT:
		NSLog(@"GW_EVENT_UPDATE_EXTENT");
		break;
	case GW_EVENT_REMOVE_CARET:
		NSLog(@"GW_EVENT_REMOVE_CARET");
		break;
	case GW_EVENT_NEW_CONTENT:
		NSLog(@"GW_EVENT_NEW_CONTENT");
		break;
	case GW_EVENT_START_THROBBER:
		NSLog(@"GW_EVENT_START_THROBBER");
		break;
	case GW_EVENT_STOP_THROBBER:
		NSLog(@"GW_EVENT_STOP_THROBBER");
		break;
	default:
		NSLog(@"Unknown window event.");
		break;
	}
	return NSERROR_OK;
}

struct gui_window_table gnustep_window_table = {
	.create = gnustep_window_create,
	.destroy = gnustep_window_destroy,
	.invalidate = gnustep_window_invalidate,
	.get_scroll = gnustep_window_get_scroll,
	.set_scroll = gnustep_window_set_scroll,
	.get_dimensions = gnustep_window_get_dimensions,
	.event = gnustep_window_event
};
