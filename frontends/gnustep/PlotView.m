#import <AppKit/AppKit.h>
#import "PlotView.h"
#import "utils/errors.h"
#import "netsurf/plotters.h"
#import "netsurf/browser_window.h"

static nserror plot_clip(const struct redraw_context *ctx, const struct rect *clip) {
	NSLog(@"plot_clip");
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
