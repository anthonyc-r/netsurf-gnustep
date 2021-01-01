#import <Cocoa/Cocoa.h>
#import <stdio.h>
#import <string.h>
#import <errno.h>

#import "Website.h"
#import "AppDelegate.h"

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
		fileOffset = -1;
	}
	return self;
}

-(id)initWithData: (struct website_data*)someData atFileOffset: (long)aFileOffset {
	if (self = [super init]) {
		data = someData;
		fileOffset = aFileOffset;
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

-(long)fileOffset {
	return fileOffset;
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
		NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent: 
			HISTORY_PATH];
		[[NSFileManager defaultManager] createDirectoryAtPath: dir attributes: nil]; 
		path = [[NSString alloc] initWithFormat: @"%@/history_%d_%02d", dir, year,
			 month];		
	}
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