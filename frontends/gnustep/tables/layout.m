#import <Cocoa/Cocoa.h>

#import "netsurf/netsurf.h"
#import "netsurf/layout.h"


/********************/
/****** Layout ******/
/********************/

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

struct gui_layout_table gnustep_layout_table = {
	.width = gnustep_layout_width,
	.position = gnustep_layout_position,
	.split = gnustep_layout_split
};