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
#import "netsurf/keypress.h"
#import "utils/nsurl.h"
#import "utils/utils.h"
#import "netsurf/content.h"
#import "utils/nsoption.h"
#import "utils/messages.h"

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
	if (pstyle->stroke_width == 0) {
		[path setLineWidth: 1];
	} else {
		[path setLineWidth: plot_style_fixed_to_double(pstyle->stroke_width)];	
	}
}

static void cocoa_plot_render_path(NSBezierPath *path, const plot_style_t *pstyle) 
{
	[NSGraphicsContext saveGraphicsState];
	[NSBezierPath clipRect: cocoa_plot_clip_rect];
	
	if (pstyle->fill_type != PLOT_OP_TYPE_NONE) {
		[cocoa_convert_colour( pstyle->fill_colour ) setFill];
		[path fill];
	}
	
	if (pstyle->stroke_type != PLOT_OP_TYPE_NONE) {
		cocoa_plot_path_set_stroke_pattern(path,pstyle);
		
		[cocoa_convert_colour( pstyle->stroke_colour ) set];
		
		[path stroke];
	}
	
	[NSGraphicsContext restoreGraphicsState];
}

static nserror plot_clip(const struct redraw_context *ctx, const struct rect *clip) {
	cocoa_plot_clip_rect = NSMakeRect(clip->x0, clip->y0, 
		clip->x1 - clip->x0, 
		clip->y1 - clip->y0);
	return NSERROR_OK;
}

static nserror plot_arc(const struct redraw_context *ctx, const plot_style_t *pstyle, int x, int y, int radius, int angle1, int angle2) {
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path appendBezierPathWithArcWithCenter: NSMakePoint( x, y ) radius: radius
		startAngle: angle1 endAngle: angle2 clockwise: NO];
	
	cocoa_plot_render_path(path, pstyle);
	
	return NSERROR_OK;
}

static nserror plot_disc(const struct redraw_context *ctx, const plot_style_t *pstyle, int x, int y, int radius) {
	NSBezierPath *path  = [NSBezierPath bezierPathWithOvalInRect:
		NSMakeRect( x - radius, y-radius, 2*radius, 2*radius )];
	
	cocoa_plot_render_path( path, pstyle );
	
	return NSERROR_OK;
}

static nserror plot_line(const struct redraw_context *ctx, const plot_style_t *pstyle, const struct rect *line) {
	int x0 = line->x0;
	int y0 = line->y0;
	int x1 = line->x1;
	int y1 = line->y1;

	if (pstyle->stroke_type == PLOT_OP_TYPE_NONE) return NSERROR_OK;

	[NSGraphicsContext saveGraphicsState];
	[NSBezierPath clipRect: cocoa_plot_clip_rect];
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint: NSMakePoint( x0, y0 )];
	[path lineToPoint: NSMakePoint( x1, y1 )];
	cocoa_plot_path_set_stroke_pattern( path, pstyle );
	
	[cocoa_convert_colour( pstyle->stroke_colour ) set];
	[path stroke];
	
	[NSGraphicsContext restoreGraphicsState];
	
	return NSERROR_OK;
}

static nserror plot_rectangle(const struct redraw_context *ctx, const plot_style_t *pstyle, const struct rect *rectangle) {
	NSRect nsrect = NSMakeRect(rectangle->x0, rectangle->y0, 
		rectangle->x1 - rectangle->x0, 
		rectangle->y1 - rectangle->y0);
	NSBezierPath *path = [NSBezierPath bezierPathWithRect: nsrect];
	cocoa_plot_render_path(path, pstyle);
	
	return NSERROR_OK;
}

static nserror plot_polygon(const struct redraw_context *ctx, const plot_style_t *pstyle, const int *p, unsigned int n) {
	if (n <= 1) return NSERROR_OK;
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint: NSMakePoint(p[0], p[1])];
	for (unsigned int i = 1; i < n; i++) {
		[path lineToPoint: NSMakePoint(p[2*i], p[2*i+1])];
	}
	[path closePath];
	
	cocoa_plot_render_path( path, pstyle );
	
	return NSERROR_OK;
}

static nserror plot_path(const struct redraw_context *ctx, const plot_style_t *pstyle, const float *p, unsigned int n, const float transform[6]) {
	return NSERROR_OK;
}

static nserror plot_bitmap(const struct redraw_context *ctx, struct bitmap *bitmap, int x, int y, int width, int height, colour bg, bitmap_flags_t flags) {
	[NSGraphicsContext saveGraphicsState];
	[NSBezierPath clipRect: cocoa_plot_clip_rect];
	
	NSBitmapImageRep *bmp = (id)bitmap;

	NSRect rect = NSMakeRect(x, y, width, height );

	NSAffineTransform *tf = [GSCurrentContext() GSCurrentCTM];
	int offset = (y + (height / 2));
	[tf translateXBy: 0 yBy: offset];
	[tf scaleXBy: 1.0 yBy: -1.0];
	[tf translateXBy: 0 yBy: -offset];
	[GSCurrentContext() GSSetCTM: tf];
	[[NSColor redColor] set];
	[GSCurrentContext() setCompositingOperation: NSCompositeSourceOver];
	[bmp drawInRect: rect];
	
	[NSGraphicsContext restoreGraphicsState];
	
	return NSERROR_OK;
}

static NSLayoutManager *cocoa_prepare_layout_manager( const char *bytes, size_t length, const plot_font_style_t *style );

extern NSTextStorage *cocoa_text_storage;
extern NSTextContainer *cocoa_text_container;
static void gnustep_draw_string( CGFloat x, CGFloat y, const char *bytes, size_t length, const plot_font_style_t *style )
{ 
	NSLayoutManager *layout = cocoa_prepare_layout_manager( bytes, length, style );
	if (layout == nil) return;
	NSFont *font = [cocoa_text_storage attribute: NSFontAttributeName atIndex: 0 effectiveRange: NULL];

	CGFloat baseline = [font defaultLineHeightForFont] * 3.0 / 4.0;
	
	NSRange glyphRange = [layout glyphRangeForTextContainer: cocoa_text_container];
	[layout drawGlyphsForGlyphRange: glyphRange atPoint: NSMakePoint( x, y - baseline )];
}

static nserror plot_text(const struct redraw_context *ctx, const plot_font_style_t *fstyle, int x, int y, const char *text, size_t length) {
	[NSGraphicsContext saveGraphicsState];
	[NSBezierPath clipRect: cocoa_plot_clip_rect];
	gnustep_draw_string(x, y, text, length, fstyle);
	
	[NSGraphicsContext restoreGraphicsState];
	
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

-(void)awakeFromNib {
	didResize = NO;
	reallyDraw = NO;
	caretRect = NSMakeRect(0, 0, 1, 0);
}

-(BOOL)resignFirstResponder {
	[self removeCaret];
	return [super resignFirstResponder];
}

-(void)setBrowser: (void*)aBrowser {
	browser = aBrowser;
}

-(void)placeCaretAtX: (int)x y: (int)y height: (int)height {
	if (showCaret) {
		[self setNeedsDisplayInRect: caretRect];
	}
	showCaret = YES;
	caretRect.origin.x = x;
	caretRect.origin.y = y;
	caretRect.size.height = height;
	[self setNeedsDisplayInRect: caretRect];
}

-(void)removeCaret {
	showCaret = NO;
	[self setNeedsDisplayInRect: caretRect];
}

/*
* inLiveRedraw doesn't seem to be implemented so this works around it by only triggering a 
* redraw after a 0.01 sec delay. So if we're in the middle of a resize it won't do the
* expensive draws.
*/
-(void)drawRect: (NSRect)rect {
	NSSize newSize = [[self superview] frame].size;
	BOOL sizeChanged = newSize.width != lastSize.width || 
		newSize.height != lastSize.height;
	if (!reallyDraw && sizeChanged) {
		[NSObject cancelPreviousPerformRequestsWithTarget: self];
		didResize = YES;
		[self performSelector: @selector(reallyTriggerDraw) withObject: nil
			afterDelay: 0.01];
		return;
	}
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
	if (didResize) {
		browser_window_schedule_reformat(browser);
		didResize = NO;
	}
	browser_window_redraw(browser, 0, 0, &clip, &ctx);
	if (showCaret && NSIntersectsRect(rect, caretRect)) {
		[[NSColor blackColor] set];
		[NSBezierPath fillRect: caretRect];
	}
	lastSize = newSize;
}

-(void)reallyTriggerDraw {
	reallyDraw = YES;
	[self display];
	reallyDraw = NO;
}

-(BOOL)isFlipped {
	return YES;
}

- (void) popUpContextMenuForEvent: (NSEvent *) event
{
        NSMenu *popupMenu = [[NSMenu alloc] initWithTitle: @""];
        NSPoint point = [self convertMousePoint: event];

        struct browser_window_features cont;

        browser_window_get_features(browser, point.x, point.y, &cont);

        if (cont.object != NULL) {
		id bitmap = (id)content_get_bitmap( cont.object );
		const char *cstr = nsurl_access(hlcache_handle_get_url( cont.object ));
               NSString *imageURL = [NSString stringWithUTF8String: cstr];

               [[popupMenu addItemWithTitle: @"Open image in new tab"
			action: @selector(cmOpenURLInTab:)
			keyEquivalent: @""] setRepresentedObject: imageURL];

               [[popupMenu addItemWithTitle: @"Open image in new window"
			action: @selector(cmOpenURLInWindow:)
			keyEquivalent: @""] setRepresentedObject: imageURL];
               [[popupMenu addItemWithTitle: @"Save image as"
			action: @selector(cmDownloadURL:)
			keyEquivalent: @""] setRepresentedObject: imageURL];
               [[popupMenu addItemWithTitle: @"Copy image"
			action: @selector(cmImageCopy:)
			keyEquivalent: @""] setRepresentedObject: bitmap];

		[popupMenu addItem: [NSMenuItem separatorItem]];
        }

        if (cont.link != NULL) {
                NSString *target = [NSString stringWithUTF8String: nsurl_access(cont.link)];

		[[popupMenu addItemWithTitle: @"Open link in new tab"
			action: @selector(cmOpenURLInTab:)
			keyEquivalent: @""] setRepresentedObject: target];
		[[popupMenu addItemWithTitle: @"Open link in new window"
  			action: @selector(cmOpenURLInWindow:)
			keyEquivalent: @""] setRepresentedObject: target];
		[[popupMenu addItemWithTitle: @"Save link target"
			action: @selector(cmDownloadURL:)
			keyEquivalent: @""] setRepresentedObject: target];
		[[popupMenu addItemWithTitle: @"Copy link"
			action: @selector(cmLinkCopy:)
			keyEquivalent: @""] setRepresentedObject: target];

                [popupMenu addItem: [NSMenuItem separatorItem]];
        }
	[popupMenu addItemWithTitle: @"Back"
		action: @selector(back:) keyEquivalent: @""];
	[popupMenu addItemWithTitle:  @"Forward"
		action: @selector(forward:) keyEquivalent: @""];
	[popupMenu addItemWithTitle: @"Stop"
		action: @selector(stopReloading:) keyEquivalent: @""];
	[popupMenu addItemWithTitle: @"Reload"
		action: @selector(reload:) keyEquivalent: @""];


	[NSMenu popUpContextMenu: popupMenu withEvent: event forView: self];

	[popupMenu release];
}

static browser_mouse_state cocoa_mouse_flags_for_event( NSEvent *evt ) {
	browser_mouse_state result = 0;
	NSUInteger flags = [evt modifierFlags];

	if (flags & NSShiftKeyMask) result |= BROWSER_MOUSE_MOD_1;
	if (flags & NSAlternateKeyMask) result |= BROWSER_MOUSE_MOD_2;

	return result;
}

- (NSPoint) convertMousePoint: (NSEvent *)event {
	NSPoint location = [self convertPoint: [event locationInWindow] fromView: nil];
	float bscale = browser_window_get_scale(browser);

	location.x /= bscale;
	location.y /= bscale;

	return location;
}

-(void)scrollWheel: (NSEvent*)theEvent {
	NSPoint loc = [self convertMousePoint: theEvent];
	int scroll = (int)[theEvent deltaY] * -25; //todo:- linescroll
	if (!browser_window_scroll_at_point(browser, loc.x, loc.y, 0, scroll)) {
		[[self nextResponder] scrollWheel: theEvent];
	}
}

- (void) mouseDown: (NSEvent *)theEvent {
	if ([theEvent modifierFlags] & NSControlKeyMask) {
		[self popUpContextMenuForEvent: theEvent];
		return;
	}
	dragStart = [self convertMousePoint: theEvent];
	browser_window_mouse_click(browser,
		BROWSER_MOUSE_PRESS_1 | cocoa_mouse_flags_for_event( theEvent ),
 		dragStart.x,
 		dragStart.y );
}

- (void) rightMouseDown: (NSEvent *)theEvent {
        [self popUpContextMenuForEvent: theEvent];
}

- (void) mouseUp: (NSEvent *)theEvent {
        NSPoint location = [self convertMousePoint: theEvent];
        browser_mouse_state modifierFlags = cocoa_mouse_flags_for_event(theEvent);
        if (isDragging) {
                isDragging = NO;
                browser_window_mouse_track(browser, (browser_mouse_state)0, location.x, 
			location.y);
        } else {
                modifierFlags |= BROWSER_MOUSE_CLICK_1;
                if ([theEvent clickCount] == 2) modifierFlags |= BROWSER_MOUSE_DOUBLE_CLICK;
                browser_window_mouse_click(browser, modifierFlags, location.x, location.y);
        }
}


#define squared(x) ((x)*(x))
#define MinDragDistance (5.0)

- (void) mouseDragged: (NSEvent *)theEvent {
       NSPoint location = [self convertMousePoint: theEvent];
	browser_mouse_state modifierFlags = cocoa_mouse_flags_for_event( theEvent );

	if (!isDragging) {
		const CGFloat distance = squared( dragStart.x - location.x ) + 
			squared( dragStart.y - location.y );

                if (distance >= squared( MinDragDistance)) {
                        isDragging = YES;
                        browser_window_mouse_click(browser, BROWSER_MOUSE_DRAG_1 | 
				modifierFlags, dragStart.x, dragStart.y);
                }
        }
        if (isDragging) {
                browser_window_mouse_track(browser, BROWSER_MOUSE_HOLDING_1 | 
			BROWSER_MOUSE_DRAG_ON | modifierFlags, location.x, location.y );
        }
}

- (void) mouseMoved: (NSEvent *)theEvent {
	NSPoint location = [self convertMousePoint: theEvent];
	browser_window_mouse_track(browser, cocoa_mouse_flags_for_event(theEvent),
		location.x, location.y);
}

- (void) mouseExited: (NSEvent *) theEvent {
        [[NSCursor arrowCursor] set];
}

- (void) keyDown: (NSEvent *)theEvent {
	[self interpretKeyEvents: [NSArray arrayWithObject: theEvent]];
}


- (void) insertText: (id)string {
        for (NSUInteger i = 0, length = [string length]; i < length; i++) {
                unichar ch = [string characterAtIndex: i];
                if (!browser_window_key_press( browser, ch )) {
                        if (ch == ' ') [self scrollPageDown: self];
                        break;
                }
        }
}

- (void) moveLeft: (id)sender {
        if (browser_window_key_press( browser, NS_KEY_LEFT )) return;
        [self scrollHorizontal: -[[self enclosingScrollView] horizontalLineScroll]];
}

- (void) moveRight: (id)sender {
        if (browser_window_key_press( browser, NS_KEY_RIGHT )) return;
        [self scrollHorizontal: [[self enclosingScrollView] horizontalLineScroll]];
}

- (void) moveUp: (id)sender {
        if (browser_window_key_press( browser, NS_KEY_UP )) return;
        [self scrollVertical: -[[self enclosingScrollView] lineScroll]];
}

- (void) moveDown: (id)sender {
        if (browser_window_key_press( browser, NS_KEY_DOWN )) return;
        [self scrollVertical: [[self enclosingScrollView] lineScroll]];
}

- (void) deleteBackward: (id)sender {
        if (!browser_window_key_press( browser, NS_KEY_DELETE_LEFT )) {
                [NSApp sendAction: @selector( goBack: ) to: nil from: self];
        }
}

- (void) deleteForward: (id)sender {
        browser_window_key_press( browser, NS_KEY_DELETE_RIGHT );
}

- (void) cancelOperation: (id)sender {
        browser_window_key_press( browser, NS_KEY_ESCAPE );
}

- (void) scrollPageUp: (id)sender {
        if (browser_window_key_press( browser, NS_KEY_PAGE_UP )) {
                return;
        }
        [self scrollVertical: -[self pageScroll]];
}

- (void) scrollPageDown: (id)sender {
        if (browser_window_key_press( browser, NS_KEY_PAGE_DOWN )) {
                return;
        }
        [self scrollVertical: [self pageScroll]];
}

- (void) insertTab: (id)sender {
        browser_window_key_press( browser, NS_KEY_TAB );
}

- (void) insertBacktab: (id)sender {
        browser_window_key_press( browser, NS_KEY_SHIFT_TAB );
}

- (void) moveToBeginningOfLine: (id)sender {
        browser_window_key_press( browser, NS_KEY_LINE_START );
}

- (void) moveToEndOfLine: (id)sender {
        browser_window_key_press( browser, NS_KEY_LINE_END );
}

- (void) moveToBeginningOfDocument: (id)sender {
        if (browser_window_key_press( browser, NS_KEY_TEXT_START )) return;
}

- (void) scrollToBeginningOfDocument: (id) sender {
        NSPoint origin = [self visibleRect].origin;
        origin.y = 0;
        [self scrollPoint: origin];
}

- (void) moveToEndOfDocument: (id)sender {
        browser_window_key_press( browser, NS_KEY_TEXT_END );
}

- (void) scrollToEndOfDocument: (id) sender {
        NSPoint origin = [self visibleRect].origin;
        origin.y = NSHeight( [self frame] );
        [self scrollPoint: origin];
}

- (void) insertNewline: (id)sender {
        browser_window_key_press( browser, NS_KEY_NL );
}

- (void) selectAll: (id)sender {
        browser_window_key_press( browser, NS_KEY_SELECT_ALL );
}

- (void) copy: (id)sender {
        browser_window_key_press( browser, NS_KEY_COPY_SELECTION );
}

- (void) cut: (id)sender {
        browser_window_key_press( browser, NS_KEY_CUT_SELECTION );
}

- (void) paste: (id)sender {
        browser_window_key_press( browser, NS_KEY_PASTE );
}

- (BOOL) acceptsFirstResponder {
        return YES;
}

- (void) adjustFrame {
        if (browser)
                browser_window_schedule_reformat(browser);
}


- (void) scrollHorizontal: (CGFloat) amount {
        NSPoint currentPoint = [self visibleRect].origin;
        currentPoint.x += amount;
        [self scrollPoint: currentPoint];
}

- (void) scrollVertical: (CGFloat) amount {
        NSPoint currentPoint = [self visibleRect].origin;
        currentPoint.y += amount;
        [self scrollPoint: currentPoint];
}

- (CGFloat) pageScroll {
        return NSHeight( [[self superview] frame] ) - [[self enclosingScrollView] pageScroll];
}

-(void)back: (id)sender {
	if (browser_window_history_back_available(browser)) {
		browser_window_history_back(browser, false);
	}
}
-(void)forward: (id)sender {
	if (browser_window_history_forward_available(browser)) {
		browser_window_history_forward(browser, false);
	}
}
-(void)stopReloading: (id)sender {
	if (browser_window_stop_available(browser)) {
		browser_window_stop(browser);
	}
}
-(void)reload: (id)sender {
	if (browser_window_reload_available(browser)) {
		browser_window_reload(browser, true);
	}
}


- (void) cmOpenURLInTab: (id)sender {
        struct nsurl *url;
        nserror error;

        error = nsurl_create([[sender representedObject] UTF8String], &url);
        if (error == NSERROR_OK) {
                error = browser_window_create(BW_CREATE_HISTORY | BW_CREATE_TAB |
			BW_CREATE_CLONE, url, NULL, browser, NULL);
                nsurl_unref(url);
        }
}

- (void) cmOpenURLInWindow: (id)sender {
        struct nsurl *url;
        nserror error;

        error = nsurl_create([[sender representedObject] UTF8String], &url);
        if (error == NSERROR_OK) {
                error = browser_window_create(BW_CREATE_HISTORY | BW_CREATE_CLONE,
			url, NULL, browser, NULL);
                nsurl_unref(url);
        }
}

- (void) cmDownloadURL: (id)sender {
        struct nsurl *url;

        if (nsurl_create([[sender representedObject] UTF8String], &url) == NSERROR_OK) {
                browser_window_navigate(browser, url, NULL, BW_NAVIGATE_DOWNLOAD, NULL,
			NULL, NULL);
                nsurl_unref(url);
        }
}

- (void) cmImageCopy: (id)sender {
        NSPasteboard *pb = [NSPasteboard generalPasteboard];
        [pb declareTypes: [NSArray arrayWithObject: NSTIFFPboardType] owner: nil];
        [pb setData: [[sender representedObject] TIFFRepresentation] 
		forType: NSTIFFPboardType];
}

- (void) cmLinkCopy: (id)sender {
        NSPasteboard *pb = [NSPasteboard generalPasteboard];
        [pb declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner: nil];
        [pb setString: [sender representedObject] forType: NSStringPboardType];
}


@end
