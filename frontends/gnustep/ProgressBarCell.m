#import <Cocoa/Cocoa.h>
#import "ProgressBarCell.h"

@implementation ProgressBarCell 

-(void)drawInteriorWithFrame: (NSRect)cellFrame inView: (NSView*)controlView {
	double progress = 0.0;
	NSString *text = nil;
	NSColor *color = nil;
	if ([[self objectValue] isKindOfClass: [NSNumber class]]) {
		progress = [[self objectValue] doubleValue];
	} else if ([[self objectValue] isKindOfClass: [NSString class]]) {
		text = [self objectValue];
	}
	if ([self isHighlighted]) {
		color = [NSColor whiteColor];
	} else {
		color = [NSColor colorWithDeviceRed: 0.2 green: 0.5 blue: 0.9 alpha: 1.0];
	}
	cellFrame.size.width *= progress;
	[NSGraphicsContext saveGraphicsState];
	[color set];
	[NSBezierPath fillRect: cellFrame];
	if (text != nil) {
		NSAttributedString *str = [[NSAttributedString alloc] initWithString: text
			attributes: [NSDictionary dictionaryWithObjectsAndKeys:
				color, NSForegroundColorAttributeName, nil]];
		[str drawAtPoint: cellFrame.origin];
		[str release];
	}
	[NSGraphicsContext restoreGraphicsState];;
}

-(void)highlight: (BOOL)lit withFrame: (NSRect)cellFrame inView: (NSView*)controlView {
	NSLog(@"highlight");
	[NSGraphicsContext saveGraphicsState];	
	
	[NSBezierPath fillRect: cellFrame];
	[NSGraphicsContext restoreGraphicsState];
}

@end
