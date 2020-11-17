#import <Cocoa/Cocoa.h>

#import "netsurf/netsurf.h"
#import "netsurf/bitmap.h"


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

struct gui_bitmap_table gnustep_bitmap_table = {
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
