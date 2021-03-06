/*
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Cocoa/Cocoa.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSLayoutManager.h>

#import "utils/nsoption.h"
#import "netsurf/layout.h"
#import "netsurf/plotters.h"

#import "font.h"


#define colour_red_component( c )		(((c) >>  0) & 0xFF)
#define colour_green_component( c )		(((c) >>  8) & 0xFF)
#define colour_blue_component( c )		(((c) >> 16) & 0xFF)
#define colour_alpha_component( c )		(((c) >> 24) & 0xFF)
#define colour_from_rgba( r, g, b, a)	((((colour)(r)) <<  0) | \
	(((colour)(g)) <<  8) | \
	(((colour)(b)) << 16) | \
	(((colour)(a)) << 24))
#define colour_from_rgb( r, g, b ) colour_from_rgba( (r), (g), (b), 0xFF )

NSColor *cocoa_convert_colour( colour clr )
{
	return [NSColor colorWithDeviceRed: (float)colour_red_component( clr ) / 0xFF 
		green: (float)colour_green_component( clr ) / 0xFF 
		blue: (float)colour_blue_component( clr ) / 0xFF 
		alpha: 1.0];
}

NSLayoutManager *cocoa_prepare_layout_manager( const char *string, size_t length, 
													 const plot_font_style_t *style );
static CGFloat cocoa_layout_width( NSLayoutManager *layout );
static CGFloat cocoa_layout_width_chars( NSLayoutManager *layout, size_t characters );
static NSUInteger cocoa_glyph_for_location( NSLayoutManager *layout, CGFloat x );
static size_t cocoa_bytes_for_characters( const char *string, size_t characters );
static NSDictionary *cocoa_font_attributes( const plot_font_style_t *style );

NSTextStorage *cocoa_text_storage = nil;
NSTextContainer *cocoa_text_container = nil;

static nserror cocoa_font_width(const plot_font_style_t *style,
                            const char *string, size_t length,
                            int *width)
{
	NSLayoutManager *layout;
        layout = cocoa_prepare_layout_manager( string, length, style );
	*width = cocoa_layout_width( layout );
	return NSERROR_OK;
}

static nserror cocoa_font_position(const plot_font_style_t *style,
                                   const char *string, size_t length,
                                   int x, size_t *char_offset, int *actual_x)
{
	NSLayoutManager *layout = cocoa_prepare_layout_manager( string, length, style );
	if (layout == nil) {
                return NSERROR_BAD_PARAMETER;
        }
	
	NSUInteger glyphIndex = cocoa_glyph_for_location(layout, x);
	if (glyphIndex >= [layout numberOfGlyphs]) {
		*char_offset = length;
	} else {
		NSUInteger chars = [layout characterIndexForGlyphAtIndex: glyphIndex];
		if (chars >= [cocoa_text_storage length]) {
			*char_offset = length;
		} else {
			*char_offset = cocoa_bytes_for_characters( string, chars );
		}
	}
	if (glyphIndex > 1) glyphIndex--;
	*actual_x = NSMaxX([layout boundingRectForGlyphRange: NSMakeRange(glyphIndex, 1)
		inTextContainer: cocoa_text_container]);
	return NSERROR_OK;
}

static nserror cocoa_font_split(const plot_font_style_t *style,
                                const char *string, size_t length,
                                int x, size_t *char_offset, int *actual_x)
{
	NSLayoutManager *layout = cocoa_prepare_layout_manager( string, length, style );
	if (layout == nil) return NSERROR_BAD_PARAMETER;

	NSUInteger glyphIndex = cocoa_glyph_for_location( layout, x );

	if (glyphIndex >= [layout numberOfGlyphs]) {
		*char_offset = length;
		*actual_x = cocoa_layout_width( layout );
		return NSERROR_OK;
	}
	NSUInteger chars = [layout characterIndexForGlyphAtIndex: glyphIndex];

	if (chars >= [cocoa_text_storage length]) {
		*char_offset = length;
		*actual_x = cocoa_layout_width( layout );
		return NSERROR_OK;
	}
	

	chars = [[cocoa_text_storage string] rangeOfString: @" " options: NSBackwardsSearch range: NSMakeRange( 0, chars + 1 )].location;
	if (chars == NSNotFound) {
		*char_offset = 0;
		*actual_x = 0;
		return NSERROR_OK;
	}
	
	*char_offset = cocoa_bytes_for_characters( string, chars );
	*actual_x = cocoa_layout_width_chars( layout, chars );
	
	return NSERROR_OK;
}


struct gui_layout_table gnustep_layout_table = {
	.width = cocoa_font_width,
	.position = cocoa_font_position,
	.split = cocoa_font_split,
};


static inline CGFloat cocoa_layout_width( NSLayoutManager *layout )
{
	if (layout == nil) return 0.0;
	
	return NSWidth([layout usedRectForTextContainer: cocoa_text_container]);
}

static inline CGFloat cocoa_layout_width_chars( NSLayoutManager *layout, size_t characters )
{
	NSRange range = [layout glyphRangeForCharacterRange: 
		NSMakeRange((unsigned int)characters, 1) actualCharacterRange: NULL];
	return [layout locationForGlyphAtIndex: range.location].x;
}

static inline NSUInteger cocoa_glyph_for_location( NSLayoutManager *layout, CGFloat x )
{
	CGFloat fraction = 0.0;
	NSUInteger glyphIndex = [layout glyphIndexForPoint: NSMakePoint(x, 0 )
		inTextContainer: cocoa_text_container 
		fractionOfDistanceThroughGlyph: &fraction];
	if (fraction >= 1.0) ++glyphIndex;
	return glyphIndex;
}

static inline size_t cocoa_bytes_for_characters( const char *string, size_t chars )
{
	size_t offset = 0;
	while (chars-- > 0) {
		uint8_t ch = ((uint8_t *)string)[offset];
		
		if (0xC2 <= ch && ch <= 0xDF) offset += 2;
		else if (0xE0 <= ch && ch <= 0xEF) offset += 3;
		else if (0xF0 <= ch && ch <= 0xF4) offset += 4;
		else offset++;
	}
	return offset;
}

NSLayoutManager *cocoa_prepare_layout_manager( const char *bytes, size_t length, 
													 const plot_font_style_t *style )
{
	if (NULL == bytes || 0 == length) return nil;

	NSString *string = [[[NSString alloc] initWithBytes: bytes length:length encoding:NSUTF8StringEncoding] autorelease];
	if (string == nil) return nil;

	static NSLayoutManager *layout = nil;
	if (nil == layout) {
		cocoa_text_container = [[NSTextContainer alloc] initWithContainerSize: NSMakeSize( CGFLOAT_MAX, CGFLOAT_MAX )];
		[cocoa_text_container setLineFragmentPadding: 0];
		
		layout = [[NSLayoutManager alloc] init];
		[layout addTextContainer: cocoa_text_container];
	}
	
	static NSString *oldString = 0;
	static plot_font_style_t oldStyle = { 0, 0, 0, 0, 0, 0 };

	const bool styleChanged = memcmp( style, &oldStyle, sizeof oldStyle ) != 0;
	
	if ([oldString isEqualToString: string] && !styleChanged) {
		return layout;
	}
	
	[oldString release]; 
	oldString = [string copy];
	oldStyle = *style;
	
	static NSDictionary *attributes = nil;
	if (styleChanged || attributes == nil) {
		[attributes release];
		attributes = [cocoa_font_attributes( style ) retain];
	}

	[cocoa_text_storage release];
	cocoa_text_storage = [[NSTextStorage alloc] initWithString: string attributes: attributes];
	[cocoa_text_storage addLayoutManager: layout];

	[layout ensureLayoutForTextContainer: cocoa_text_container];
	
	return layout;
}

static inline NSFont *cocoa_font_get_nsfont( const plot_font_style_t *style )
{
	NSFont *font = [NSFont systemFontOfSize: 
		((CGFloat)style->size * 1.25f) / PLOT_STYLE_SCALE];
	
	NSFontTraitMask traits = 0;
	if (style->flags & FONTF_ITALIC || style->flags & FONTF_OBLIQUE) traits |= NSItalicFontMask;
	if (style->flags & FONTF_SMALLCAPS) traits |= NSSmallCapsFontMask;
	if (style->weight > 400) traits |= NSBoldFontMask;
	
	if (0 != traits) {
		NSFontManager *fm = [NSFontManager sharedFontManager];
		font = [fm convertFont: font toHaveTrait: traits];
	}
	
	return font;
}

static inline NSDictionary *cocoa_font_attributes( const plot_font_style_t *style )
{
	return [NSDictionary dictionaryWithObjectsAndKeys: 
			cocoa_font_get_nsfont( style ), NSFontAttributeName, 
			cocoa_convert_colour( style->foreground ), NSForegroundColorAttributeName,
			nil];
}
