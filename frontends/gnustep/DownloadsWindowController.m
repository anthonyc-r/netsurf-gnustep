#import <Cocoa/Cocoa.h>
#import "DownloadsWindowController.h"

@implementation DownloadsWindowController

-(id)init {
	if (self = [super initWithWindowNibName: @"Downloads"]) {
		//...
	}
	return self;
}

-(void)awakeFromNib {
	NSLog(@"Awoke from nib...");
}

@end

