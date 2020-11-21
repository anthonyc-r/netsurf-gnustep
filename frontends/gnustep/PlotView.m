/*
 * Copyright 2011 Sven Weidauer <sven.weidauer@gmail.com>
 * Copyright 2020 Anthony Cohn-Richardby <anthonyc@gmx.co.uk>
 *
 * This file is part of NetSurf, http://www.netsurf-browser.org/
 *
 * NetSurf is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 * NetSurf is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <AppKit/AppKit.h>
#import "PlotView.h"
#import "utils/errors.h"
#import "netsurf/plotters.h"
#import "netsurf/browser_window.h"

#define colour_red_component( c )		(((c) >>  0) & 0xFF)
#define colour_green_component( c )		(((c) >>  8) & 0xFF)
#define colour_blue_component( c )		(((c) >> 16) & 0xFF)
#define colour_alpha_component( c )		(((c) >> 24) & 0xFF)
#define colour_from_rgba( r, g, b, a)	((((colour)(r)) <<  0) | \
	(((colour)(g)) <<  8) | \
	(((colour)(b)) << 16) | \
	(((colour)(a)) << 24))
#define colour_from_rgb( r, g, b ) colour_from_rgba( (r), (g), (b), 0xFF )

static NSRect cocoa_plot_clip_rect;

static NSColor *cocoa_convert_colour( colour clr )
{
	return [NSColor colorWithDeviceRed: (float)colour_red_component( clr ) / 0xFF 
		green: (float)colour_green_component( clr ) / 0xFF
		blue: (float)colour_blue_component( clr ) / 0xFF 
		alpha: 1.0];
}


static void cocoa_plot_path_set_stroke_pattern(NSBezierPath *path, const plot_style_t *pstyle) 
{
	static const CGFloat dashed_pattern[2] = { 5.0, 2.0 };
	static const CGFloat dotted_pattern[2] = { 2.0, 2.0 };
	
	switch (pstyle->stroke_type) {
		case PLOT_OP_TYPE_DASH: 
			[path setLineDash: dashed_pattern count: 2 phase: 0];
			break;
			
		case PLOT_OP_TYPE_DOT: 
			[path setLineDash: dotted_pattern count: 2 phase: 0];
			break;
			
		default:
			// ignore
			break;
	}

	[path setLineWidth: pstyle->stroke_width > 0 ? pstyle->stroke_width : 1];
}

void cocoa_plot_render_path(NSBezierPath *path, const plot_style_t *pstyle) 
{
	[NSGraphicsContext saveGraphicsState];
	[NSBezierPath clipRect: cocoa_plot_clip_rect];
	
	if (pstyle->fill_type != PLOT_OP_TYPE_NONE) {
		[cocoa_convert_colour( pstyle->fill_colour ) setFill];
		[path fill];
	}
	
	if (pstyle->stroke_type != PLOT_OP_TYPE_NONE) {
		if (pstyle->stroke_width == 0 || pstyle->stroke_width % 2 != 0)
			;
			//cocoa_center_pixel( true, true );
		
		cocoa_plot_path_set_stroke_pattern(path,pstyle);
		
		[cocoa_convert_colour( pstyle->stroke_colour ) set];
		
		[path stroke];
	}
	
	[NSGraphicsContext restoreGraphicsState];
}

static nserror plot_clip(const struct redraw_context *ctx, const struct rect *clip) {
	NSLog(@"plot_clip");
	cocoa_plot_clip_rect = NSMakeRect(clip->x0, clip->y0, clip->x1, clip->y1);
	//[NSBezierPath clipRect: ];
	return NSERROR_OK;
}

static nserror plot_arc(const struct redraw_context *ctx, const plot_style_t *pstyle, int x, int y, int radius, int angle1, int angle2) {
	NSLog(@"plot_arc");
	return NSERROR_OK;
}

static nserror plot_disc(const struct redraw_context *ctx, const plot_style_t *pstyle, int x, int y, int radius) {
	NSLog(@"plot_disc");
	return NSERROR_OK;
}

static nserror plot_line(const struct redraw_context *ctx, const plot_style_t *pstyle, const struct rect *line) {
	NSLog(@"plot_line");
	return NSERROR_OK;
}

static nserror plot_rectangle(const struct redraw_context *ctx, const plot_style_t *pstyle, const struct rect *rectangle) {
	NSLog(@"plot_rectangle");
	NSRect nsrect = NSMakeRect(rectangle->x0, rectangle->y0, rectangle->x1, 
		rectangle->y1);
	NSBezierPath *path = [NSBezierPath bezierPathWithRect: nsrect];
	cocoa_plot_render_path(path, pstyle);
	
	return NSERROR_OK;
}

static nserror plot_polygon(const struct redraw_context *ctx, const plot_style_t *pstyle, const int *p, unsigned int n) {
	NSLog(@"plot_polygon");
	return NSERROR_OK;
}

static nserror plot_path(const struct redraw_context *ctx, const plot_style_t *pstyle, const float *p, unsigned int n, const float transform[6]) {
	NSLog(@"plot_path");
	return NSERROR_OK;
}

static nserror plot_bitmap(const struct redraw_context *ctx, struct bitmap *bitmap, int x, int y, int width, int height, colour bg, bitmap_flags_t flags) {
	NSLog(@"plot_bitmap");
	return NSERROR_OK;
}

static nserror plot_text(const struct redraw_context *ctx, const plot_font_style_t *fstyle, int x, int y, const char *text, size_t length) {
	NSLog(@"plot_text");
	return NSERROR_OK;
}

static const struct plotter_table gnustep_plotters = {
	.clip = plot_clip,
	.arc = plot_arc,
	.disc = plot_disc,
	.line = plot_line,
	.rectangle = plot_rectangle,
	.polygon = plot_polygon,
	.path = plot_path,
	.bitmap = plot_bitmap,
	.text = plot_text,
	.option_knockout = true
};

@implementation PlotView

-(void)setBrowser: (void*)aBrowser {
	browser = aBrowser;
}

-(void)drawRect: (NSRect)rect {
	NSLog(@"Drawing plotview");
	struct redraw_context ctx = {
		.interactive = true,
		.background_images = true,
		.plot = &gnustep_plotters
	};
	const struct rect clip = {
		.x0 = NSMinX(rect),
		.y0 = NSMinY(rect),
		.x1 = NSMaxX(rect),
		.y1 = NSMaxY(rect)
	};
	browser_window_redraw(browser, 0, 0, &clip, &ctx);
}

@end
