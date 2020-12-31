#import <Cocoa/Cocoa.h>
#import <stdio.h>
#import <string.h>
#import <errno.h>

#import "Website.h"
#import "AppDelegate.h"

#define HISTORY_PATH @"/.cache/NetSurf"

static NSMutableArray *recentHistory;
static NSMutableArray *olderHistory;

@implementation Website

-(id)initWithName: (NSString*)aName url: (NSString*)aUrl {
	if (self = [super init]) {
		int nlen = [aName length];
		int urlen = [aUrl length];
		data = malloc(sizeof (struct website_data) + nlen + urlen);
		data->len_name = nlen;
		data->len_url = urlen;
		memcpy(data->data, [aName cString], nlen);
		memcpy(data->data + nlen, [aUrl cString], urlen);
	}
	return self;
}

-(id)initWithData: (struct website_data*)someData {
	if (self = [super init]) {
		data = someData;
	}
	return self;
}

-(void)dealloc {
	free(data);
	[super dealloc];
}

-(NSString*)name {
	return [NSString stringWithCString: data->data length: data->len_name];
}

-(NSString*)url {
	return [NSString stringWithCString: data->data + data->len_name length: 
		data->len_url];
}

-(void)open {
	[[NSApp delegate] openWebsite: self];
}

// MARK: - History implementation

-(void)addToHistory {
	static NSString *path = nil;
	if (path == nil) {
		NSCalendarDate *date = [NSCalendarDate calendarDate];
		int month = [date monthOfYear];
		int year = [date yearOfCommonEra];
		path = [[NSString alloc] initWithFormat: @"%@/%@/history_%d_%d", 
			NSHomeDirectory(), HISTORY_PATH, year, month];
	}
	NSLog(@"name: %@", [self name]);
	NSLog(@"url: %@", [self url]);
	FILE *f = fopen([path cString], "a");
	if (f != NULL) {
		int len = sizeof (struct website_data) + data->len_url + data->len_name;
		fwrite(data, len, 1, f);
		fclose(f);
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:
		WebsiteHistoryUpdatedNotificationName object: self];
}

@end