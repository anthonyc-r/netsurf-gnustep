#import <Cocoa/Cocoa.h>

#import "BrowserWindowController.h"
#import "netsurf/netsurf.h"
#import "netsurf/window.h"
#import "netsurf/types.h"
#import "utils/nsurl.h"
#import "netsurf/mouse.h"

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
	if (rect == NULL) {
		[(id)gw invalidateBrowser];
	} else {
		[(id)gw invalidateBrowser: NSMakeRect(rect->x0, rect->y0, 
			rect->x1, rect->y1)];
	}
	return NSERROR_OK;
}

// Put the current scroll offset into sx and sy
static bool gnustep_window_get_scroll(struct gui_window *gw, int *sx, int *sy) {
	NSLog(@"gnustep_window_get_scroll");
	NSPoint scroll = [(id)gw getBrowserScroll];
	*sx = scroll.x;
	*sy = scroll.y;
	return true;
}

// Set the current scroll offset
static nserror gnustep_window_set_scroll(struct gui_window *gw, const struct rect *rect) {
	NSLog(@"gnustep_window_set_scroll");
	[(id)gw setBrowserScroll: NSMakePoint(rect->x0, rect->y0)];
	return NSERROR_OK;
}

// Put the dimensions of the specified window into width, height
static nserror gnustep_window_get_dimensions(struct gui_window *gw, int *width, int *height) {
	NSSize size = [(id)gw getBrowserSize];
	*width = size.width;
	*height = size.height;
	NSLog(@"gnustep_window_get_dimensions (%d, %d)", *width, *height);
	return NSERROR_OK;
}

// Some kind of event happened
static nserror gnustep_window_event(struct gui_window *gw, enum gui_window_event event) {
	NSLog(@"gnustep_window_event");
	switch (event) {
	case GW_EVENT_UPDATE_EXTENT:
		NSLog(@"GW_EVENT_UPDATE_EXTENT");
		[(id)gw updateBrowserExtent];
		break;
	case GW_EVENT_REMOVE_CARET:
		NSLog(@"GW_EVENT_REMOVE_CARET");
		[(id)gw removeCaret];
		break;
	case GW_EVENT_NEW_CONTENT:
		NSLog(@"GW_EVENT_NEW_CONTENT");
		[(id)gw newContent];
		break;
	case GW_EVENT_START_THROBBER:
		NSLog(@"GW_EVENT_START_THROBBER");
		[(id)gw startThrobber];
		break;
	case GW_EVENT_STOP_THROBBER:
		NSLog(@"GW_EVENT_STOP_THROBBER");
		[(id)gw stopThrobber];
		break;
	default:
		NSLog(@"Unknown window event.");
		break;
	}
	return NSERROR_OK;
}

static void gnustep_window_set_title(struct gui_window *gw, const char *title) {
	[(id)gw setTitle: [NSString stringWithUTF8String: title]];
}

static nserror gnustep_window_set_url(struct gui_window *gw, struct nsurl *url) {
	NSString *urlStr = [NSString stringWithUTF8String: nsurl_access(url)];
	[(id)gw setNavigationUrl: urlStr];
	return NSERROR_OK;
}

static void gnustep_window_set_pointer(struct gui_window *gw, enum gui_pointer_shape shape) {
	[(id)gw setPointerToShape: shape];
}

static void gnustep_window_place_caret(struct gui_window *gw, int x, int y, int height, const struct rect *clip) {
	[(id)gw placeCaretAt: NSMakePoint(x, y) withHeight: height clipTo: NSMakeRect(
		clip->x0, clip->y0,
		clip->x1 - clip->x0,
		clip->y1 - clip->y0)];
}

struct gui_window_table gnustep_window_table = {
	.create = gnustep_window_create,
	.destroy = gnustep_window_destroy,
	.invalidate = gnustep_window_invalidate,
	.get_scroll = gnustep_window_get_scroll,
	.set_scroll = gnustep_window_set_scroll,
	.get_dimensions = gnustep_window_get_dimensions,
	.event = gnustep_window_event,
	.set_title = gnustep_window_set_title,
	.set_url = gnustep_window_set_url,
	.place_caret = gnustep_window_place_caret,
	.set_pointer = gnustep_window_set_pointer
};
