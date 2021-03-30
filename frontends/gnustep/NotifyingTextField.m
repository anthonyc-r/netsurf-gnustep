#import <Cocoa/Cocoa.h>
#import "NotifyingTextField.h"



@implementation NotifyingTextField

-(void)keyUp: (NSEvent*)theEvent {
	[super keyUp: theEvent];
	NSLog(@"code: %d", [theEvent keyCode]);
	switch ([theEvent keyCode]) {
	case KEY_UP:
		
	case KEY_DOWN:
		
	defualt:
		break;
	}
}

@end
