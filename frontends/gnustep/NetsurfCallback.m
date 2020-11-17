/*
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#import <Foundation/Foundation.h>
#import "NetsurfCallback.h"

static NSMapTable *callbackMap;

@implementation NetsurfCallback

+(void)initialize {
	callbackMap = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, 
			NSObjectMapValueCallBacks, 0);
}

+(id)newOrScheduledWithFunctionPointer: (void (*)(void *p))aCallback parameter: (void*)p {
	NetsurfCallback *ret;
	if ((ret = NSMapGet(callbackMap, aCallback)) != NULL) {
		return ret;
	}
	ret = [NetsurfCallback new];
	ret->callback = aCallback;
	ret->parameter = p;
	return ret;
}

-(void)perform {
	NSMapRemove(callbackMap, callback);
	callback(parameter);
}

-(void)scheduleAfterMillis: (int)ms {
	NSMapInsert(callbackMap, callback, self);
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
	[self performSelector: @selector(perform) withObject: nil afterDelay: ms / 1000.0];
}

-(void)cancel {
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
	NSMapRemove(callbackMap, callback);
}

@end
