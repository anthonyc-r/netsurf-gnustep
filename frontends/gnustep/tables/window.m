#import <Cocoa/Cocoa.h>

#import "AppDelegate.h"
#import "BrowserWindowController.h"
#import "netsurf/browser_window.h"
#import "netsurf/netsurf.h"
#import "netsurf/window.h"
#import "netsurf/types.h"
#import "utils/nsurl.h"
#import "netsurf/mouse.h"

struct window_tab {
	BrowserWindowController *window;
	id tab;
};

/********************/
/****** Window ******/
/********************/

// Create and open a browser window
static struct gui_window *gnustep_window_create(struct browser_window *bw,
			struct gui_window *existing,
			gui_window_create_flags flags) {
	NSLog(@"gnustep_window_create");
	BrowserWindowController *controller = nil;
	id tabId;
	if (flags & BW_CREATE_TAB) {
		controller = [BrowserWindowController newTabTarget];
		tabId = [controller newTabWithBrowser: bw];
	}
	if (controller == nil) {
		controller = [[BrowserWindowController alloc]
		initWithBrowser: bw]; 
		[controller loadWindow];
		tabId = [controller initialTabId];
	}
	struct window_tab *wtab = malloc(sizeof (struct window_tab));
	wtab->window = controller;
	wtab->tab = tabId;
	return (struct gui_window*)wtab;
}

// Destroy the specified window
static void gnustep_window_destroy(struct gui_window *gw) {
	NSLog(@"gnustep_window_destroy");
	struct window_tab *wtab = (struct window_tab*)gw;
	[wtab->window netsurfWindowDestroyForTab: wtab->tab];
	free(wtab);
}

// Trigger a redraw of the specified area, or the entire window if null
static nserror gnustep_window_invalidate(struct gui_window *gw, const struct rect *rect) {
	NSLog(@"gnustep_window_invalidate");
	struct window_tab *wtab = (struct window_tab*)gw;
	if (rect == NULL) {
		[wtab->window invalidateBrowserForTab: wtab->tab];
	} else {
		[wtab->window invalidateBrowser: NSMakeRect(rect->x0, rect->y0, 
			rect->x1, rect->y1) forTab: wtab->tab];
	}
	return NSERROR_OK;
}

// Put the current scroll offset into sx and sy
static bool gnustep_window_get_scroll(struct gui_window *gw, int *sx, int *sy) {
	NSLog(@"gnustep_window_get_scroll");
	struct window_tab *wtab = (struct window_tab*)gw;
	NSPoint scroll = [wtab->window getBrowserScrollForTab: wtab->tab];
	*sx = scroll.x;
	*sy = scroll.y;
	return true;
}

// Set the current scroll offset
static nserror gnustep_window_set_scroll(struct gui_window *gw, const struct rect *rect) {
	NSLog(@"gnustep_window_set_scroll");
	struct window_tab *wtab = (struct window_tab*)gw;
	[wtab->window setBrowserScroll: NSMakePoint(rect->x0, rect->y0) forTab: 
		wtab->tab];
	return NSERROR_OK;
}

// Put the dimensions of the specified window into width, height
static nserror gnustep_window_get_dimensions(struct gui_window *gw, int *width, int *height) {
	struct window_tab *wtab = (struct window_tab*)gw;
	NSSize size = [wtab->window getBrowserSizeForTab: wtab->tab];
	*width = size.width;
	*height = size.height;
	NSLog(@"gnustep_window_get_dimensions (%d, %d)", *width, *height);
	return NSERROR_OK;
}

// Some kind of event happened
static nserror gnustep_window_event(struct gui_window *gw, enum gui_window_event event) {
	NSLog(@"gnustep_window_event");
	struct window_tab *wtab = (struct window_tab*)gw;
	switch (event) {
	case GW_EVENT_UPDATE_EXTENT:
		NSLog(@"GW_EVENT_UPDATE_EXTENT");
		[wtab->window updateBrowserExtentForTab: wtab->tab];
		break;
	case GW_EVENT_REMOVE_CARET:
		NSLog(@"GW_EVENT_REMOVE_CARET");
		[wtab->window removeCaretInTab: wtab->tab];
		break;
	case GW_EVENT_NEW_CONTENT:
		NSLog(@"GW_EVENT_NEW_CONTENT");
		[wtab->window newContentForTab: wtab->tab];
		break;
	case GW_EVENT_START_THROBBER:
		NSLog(@"GW_EVENT_START_THROBBER");
		[wtab->window startThrobber];
		break;
	case GW_EVENT_STOP_THROBBER:
		NSLog(@"GW_EVENT_STOP_THROBBER");
		[wtab->window stopThrobber];
		break;
	default:
		NSLog(@"Unknown window event.");
		break;
	}
	return NSERROR_OK;
}

static void gnustep_window_set_title(struct gui_window *gw, const char *title) {
	struct window_tab *wtab = (struct window_tab*)gw;
	[wtab->window setTitle: [NSString stringWithUTF8String: title] forTab: 
		wtab->tab];
}

static nserror gnustep_window_set_url(struct gui_window *gw, struct nsurl *url) {
	struct window_tab *wtab = (struct window_tab*)gw;
	NSString *urlStr = [NSString stringWithUTF8String: nsurl_access(url)];
	[wtab->window setNavigationUrl: urlStr forTab: wtab->tab];
	return NSERROR_OK;
}

static void gnustep_window_set_pointer(struct gui_window *gw, enum gui_pointer_shape shape) {
	struct window_tab *wtab = (struct window_tab*)gw;
	[wtab->window setPointerToShape: shape];
}

static void gnustep_window_place_caret(struct gui_window *gw, int x, int y, int height, const struct rect *clip) {
	struct window_tab *wtab = (struct window_tab*)gw;
	[wtab->window placeCaretAtX: x y: y height: height inTab: wtab->tab];
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
