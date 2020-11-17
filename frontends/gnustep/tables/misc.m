#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "netsurf/netsurf.h"
#import "netsurf/misc.h"
#import "NetsurfCallback.h"

/*******************/
/****** Misc *******/
/*******************/

// Schedule a callback to be run after t ms, or removed if ngtv, func and param.
static nserror gnustep_misc_schedule(int t, void (*callback)(void *p), void *p) {
	NSLog(@"gnustep_misc_schedule in %dms", t);
	NetsurfCallback *nsCallback = [NetsurfCallback newOrScheduledWithFunctionPointer: 
		callback parameter: p];
	if (t < 1) {
		[nsCallback cancel];
		return NSERROR_OK;
	} else {
		[nsCallback scheduleAfterMillis: t];
		return NSERROR_OK;
	}
}

struct gui_misc_table gnustep_misc_table = {
	.schedule = gnustep_misc_schedule
};