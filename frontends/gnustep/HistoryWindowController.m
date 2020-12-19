#import <Cocoa/Cocoa.h>
#import "HistoryWindowController.h"

@implementation HistoryWindowController

-(id)init {
	if (self = [super initWithWindowNibName: @"History"]) {
		// .....
	}
	return self;
}

-(void)awakeFromNib {
	NSLog(@"Awoke from nib...");
	[[self window] makeKeyAndOrderFront: self];
}

@end