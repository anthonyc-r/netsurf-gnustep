#import <Cocoa/Cocoa.h>
#import "ProgressBarCell.h"

@implementation ProgressBarCell 

-(void)drawInteriorWithFrame: (NSRect)cellFrame inView: (NSView*)controlView {
	double progress = [[self objectValue] doubleValue];
	cellFrame.size.width *= progress;
	[NSGraphicsContext saveGraphicsState];
	if ([self isHighlighted]) {
		[[NSColor whiteColor] set];
	} else {
		[[NSColor colorWithDeviceRed: 0.2 green: 0.5 blue: 0.9 alpha: 1.0] set];
	}
	[NSBezierPath fillRect: cellFrame];
	[NSGraphicsContext restoreGraphicsState];
}

-(void)highlight: (BOOL)lit withFrame: (NSRect)cellFrame inView: (NSView*)controlView {
	NSLog(@"highlight");
	[NSGraphicsContext saveGraphicsState];	
	
	[NSBezierPath fillRect: cellFrame];
	[NSGraphicsContext restoreGraphicsState];
}

@end
