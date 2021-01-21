/*
 * Mostly based on the cocoa port:
 * Copyright 2011 Sven Weidauer <sven.weidauer@gmail.com>
 *
 * This file is part of NetSurf, http://www.netsurf-browser.org/
 *
 * NetSurf is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 * NetSurf is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#import <Cocoa/Cocoa.h>

#import "netsurf/netsurf.h"
#import "netsurf/bitmap.h"

#define BITS_PER_SAMPLE (8)
#define SAMPLES_PER_PIXEL (4)
#define BITS_PER_PIXEL (BITS_PER_SAMPLE * SAMPLES_PER_PIXEL)
#define BYTES_PER_PIXEL (BITS_PER_PIXEL / 8)
#define RED_OFFSET (0)
#define GREEN_OFFSET (1)
#define BLUE_OFFSET (2)
#define ALPHA_OFFSET (3)

/********************/
/****** Bitmap ******/
/********************/

// Create a new bitmap of width height
static void *gnustep_bitmap_create(int width, int height, unsigned int state) {
	NSBitmapImageRep *bmp = [[NSBitmapImageRep alloc]
		initWithBitmapDataPlanes: NULL
		pixelsWide: width
		pixelsHigh: height
		bitsPerSample: BITS_PER_SAMPLE
		samplesPerPixel: SAMPLES_PER_PIXEL
		hasAlpha: YES
		isPlanar: NO
		colorSpaceName: NSDeviceRGBColorSpace
		bitmapFormat: NSAlphaNonpremultipliedBitmapFormat
		bytesPerRow: BYTES_PER_PIXEL * width
		bitsPerPixel: BITS_PER_PIXEL];
	return (void*) bmp;
}

// Destroy the specified bitmap
static void gnustep_bitmap_destroy(void *bitmap) {
	[(id)bitmap dealloc];
}

// Set whether it's opaque or not
static void gnustep_bitmap_set_opaque(void *bitmap, bool opaque) {
	if (opaque) {
		[(id)bitmap setOpaque: YES];
	} else {
		[(id)bitmap setOpaque: NO];
	}
}

// Get whether it's opaque or not
static bool gnustep_bitmap_get_opaque(void *bitmap) {
	return [(id)bitmap isOpaque];
}

// Test? whether it's opaque or not
static bool gnustep_bitmap_test_opaque(void *bitmap) {
	unsigned char *buf = [(id)bitmap bitmapData];

	const size_t height = [(id)bitmap pixelsHigh];
	const size_t width = [(id)bitmap pixelsWide];

	const size_t line_step = [(id)bitmap bytesPerRow] - BYTES_PER_PIXEL * width;

	for (size_t y = 0; y < height; y++) {
		for (size_t x = 0; x < height; x++) {
			if (buf[ALPHA_OFFSET] != 0xFF) return false;
			buf += BYTES_PER_PIXEL;
		}
		buf += line_step;
	}

	return true;
}

// Get the image buffer for the bitmap
static unsigned char *gnustep_bitmap_get_buffer(void *bitmap) {
	return [(id)bitmap bitmapData];
}

// Get the number of bytes per row of the bitmap
static size_t gnustep_bitmap_get_rowstride(void *bitmap) {
	return [(id)bitmap bytesPerRow];
}

// Get its width in pixels
static int gnustep_bitmap_get_width(void *bitmap) {
	return [(id)bitmap pixelsWide];
}

// Get height in pixels
static int gnustep_bitmap_get_height(void *bitmap) {
	return [(id)bitmap pixelsHigh];
}

// Get how many byytes pet pixel
static size_t gnustep_bitmap_get_bpp(void *bitmap) {
	return [(id)bitmap bitsPerPixel] / 8;
}

// Save the bitmap to the specified path
static bool gnustep_bitmap_save(void *bitmap, const char *path, unsigned flags) {
	NSData *tiff = [(id)bitmap TIFFRepresentation];
	return [tiff writeToFile: [NSString stringWithUTF8String: path] atomically: YES];
}

// Mark bitmap as modified
static void gnustep_bitmap_modified(void *bitmap) {
}

// Render content into the specified bitmap
static nserror gnustep_bitmap_render(struct bitmap *bitmap, struct hlcache_handle *content) {
	return NSERROR_NOT_IMPLEMENTED;
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
