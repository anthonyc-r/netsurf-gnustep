/*
 * Copyright 2022 Anthony Cohn-Richardby <anthonyc@gmx.co.uk>
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
