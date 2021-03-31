#import <Cocoa/Cocoa.h>
#import "NotifyingTextField.h"

@interface NotifyingTextField(Private)
-(void)notifySpecialKey: (NSDictionary*)userInfo;
@end


@implementation NotifyingTextField

-(void)keyUp: (NSEvent*)theEvent {
	[super keyUp: theEvent];
	NSDictionary *uinfo;
	NSInteger keyCode = [theEvent keyCode];
	switch (keyCode) {
	case KEY_UP:
	case KEY_DOWN:
		uinfo = [NSDictionary dictionaryWithObjectsAndKeys: 
			[NSNumber numberWithInteger: keyCode], @"keyCode", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName: 
			NotifyingTextFieldSpecialKeyPressedNotification
			object: self userInfo: uinfo];
		break;
	default:
		break;
	}
}

@end
