#import <Cocoa/Cocoa.h>
#import <stdio.h>
#import <string.h>
#import <errno.h>

#import "Website.h"
#import "AppDelegate.h"

@interface Website(Private)
+(void)truncateHistoryFileAtPath: (NSString*)path olderThanDate: (NSDate*)date;
@end

@implementation Website

-(id)initWithName: (NSString*)aName url: (NSString*)aUrl {
	if (self = [super init]) {
		int nlen = [aName length];
		int urlen = [aUrl length];
		data = malloc(sizeof (struct website_data) + nlen + urlen);
		data->len_name = nlen;
		data->len_url = urlen;
		data->timeIntervalSinceReferenceDate = [[NSDate date]
			timeIntervalSinceReferenceDate];
		memcpy(data->data, [aName cString], nlen);
		memcpy(data->data + nlen, [aUrl cString], urlen);
		fileOffset = -1;
		filename = nil;
	}
	return self;
}

-(id)initWithData: (struct website_data*)someData atFileOffset: (long)aFileOffset {
	if (self = [super init]) {
		data = someData;
		fileOffset = aFileOffset;
		filename = nil;
	}
	return self;
}

-(id)initWithDictionary: (NSDictionary*)aDictionary fromFileNamed: (NSString*)aFilename {
	NSString *aName = [aDictionary objectForKey: @"name"];
	NSString *aUrl = [aDictionary objectForKey: @"url"];
	if ([self initWithName: aName url: aUrl] != nil) {
		filename = [aFilename retain];
	}
	return self;
}

-(void)dealloc {
	free(data);
	[parentFolder release];
	[filename release];
	[super dealloc];
}

-(NSString*)name {
	return [NSString stringWithCString: data->data length: data->len_name];
}

-(NSString*)url {
	return [NSString stringWithCString: data->data + data->len_name length: 
		data->len_url];
}

-(NSDate*)dateViewed {
	return [NSDate dateWithTimeIntervalSinceReferenceDate:
		data->timeIntervalSinceReferenceDate];
}

-(void)setName: (NSString*)aName {
	NSString *url = [self url];
	int nlen = [aName length];
	int urlen = data->len_url;
	data = realloc(data, sizeof (struct website_data) + nlen + urlen);
	data->len_name = nlen;
	data->len_url = urlen;
	memcpy(data->data, [aName cString], nlen);
	memcpy(data->data + nlen, [url cString], urlen);
	fileOffset = -1;
}

-(NSString*)filename {
	return filename;
}
-(void)setFilename: (NSString*)aFilename {
	[filename autorelease];
	filename = [aFilename retain];
}

// Set when init from bookmarks or added to folder
-(BookmarkFolder*)parentFolder {
	return parentFolder;
}

-(void)setParentFolder: (BookmarkFolder*)aBookmarkFolder {
	[parentFolder release];
	parentFolder = [aBookmarkFolder retain];
}

-(NSDictionary*)asDictionary {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject: [self name] forKey: @"name"];
	[dict setObject: [self url] forKey: @"url"];
	return dict;
}

-(long)fileOffset {
	return fileOffset;
}

-(void)open {
	[[NSApp delegate] openWebsite: self];
}

-(Website*)copy {
	Website *website = [[Website alloc] initWithName: [self name] url: [self url]];
	[website autorelease];
	return website;
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
		NSError *err;
		[[NSFileManager defaultManager] createDirectoryAtPath: dir 
			withIntermediateDirectories: YES attributes: nil error: &err]; 
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

+(NSMutableArray*)getHistoryFromFile: (NSString*)file matching: (NSString*)queryString {
	size_t nread, wsize;
	long fileoff;
	int lens[2];
	NSString *historyRoot = [NSString stringWithFormat: @"%@/%@", NSHomeDirectory(), 
		HISTORY_PATH];
	NSString *path = [historyRoot stringByAppendingPathComponent: file];
	FILE *f = fopen([path cString], "r");
	struct website_data *wdata;
	Website *website;
	NSMutableArray *ret = [NSMutableArray array];

	if (f == NULL) {
		NSLog(@"Error opening file: %@", path);
		return ret;
	}
	fileoff = 0;
	while (1) {
		if ((nread = fread(lens, sizeof (int), 2, f)) < 2) {
			break;
		}
		wsize = lens[0] + lens[1] + sizeof (struct website_data);
		// 0 Value of url_len implies this has been cleared. Skip.
		if (lens[1] == 0) {
			fseek(f, wsize - (nread * sizeof (int)), SEEK_CUR);
			continue;
		}
		// Else it's valid, rewind and read the whole structure in.
		fseek(f, -nread * sizeof (int), SEEK_CUR);
		wdata = malloc(wsize);
		fread(wdata, wsize, 1, f);
		website = [[[Website alloc] initWithData: wdata atFileOffset: fileoff] 
			autorelease];
		// If there's a search value set, skip non-matching websites.
		if (queryString == nil || [[website name] rangeOfString: queryString options: 
			NSCaseInsensitiveSearch].location != NSNotFound) {
			[ret addObject: website];
		}
		fileoff = ftell(f);
	}
	fclose(f);
	return ret;
}

+(NSArray*)getAllHistoryFiles {
	NSString *path = [NSString stringWithFormat: @"%@/%@", NSHomeDirectory(), 
		HISTORY_PATH];
	NSError *error = nil;
	NSPredicate *historyPredicate = [NSPredicate predicateWithFormat: 
		@"count >= 8 AND self beginswith 'history_'"];
	NSMutableArray *files = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath: 
		path error: &error] mutableCopy];
	if (error != nil) {
		NSLog(@"Error fetching files in history dir: %@", path);
		return [NSArray array];
	}
	[files filterUsingPredicate: historyPredicate];
	[files sortUsingSelector: @selector(caseInsensitiveCompare:)];
	NSLog(@"%@", files);
	return files;
}

+(void)deleteHistoryOlderThanDays: (NSUInteger)days {
	NSCalendarDate *now = [NSCalendarDate date];
	NSCalendarDate *deletionThreshold = [now dateByAddingYears: 0 months: 0
		days: -days hours: 0 minutes: 0 seconds: 0];
	[Website deleteHistoryOlderThanDate: deletionThreshold];
}

+(void)deleteHistoryOlderThanDate: (NSDate*)date {
	// Get month&year for month
	NSCalendarDate *calendarDate = [NSCalendarDate
		dateWithTimeIntervalSinceReferenceDate:
		[date timeIntervalSinceReferenceDate]];
	NSInteger targetMonth = [calendarDate monthOfYear];
	NSInteger targetYear = [calendarDate yearOfCommonEra];
	// Iterate through all history files & delete older
	NSArray *historyFiles = [Website getAllHistoryFiles];
	NSArray *yearAndDate;
	NSEnumerator *fileEnumerator = [historyFiles objectEnumerator];
	NSString *filename, *fullPath;
	NSInteger fileYear, fileMonth;
	BOOL isFileOld;
	NSError *err = nil;
	NSString *historyPath = [NSString stringWithFormat: @"%@/%@",
		NSHomeDirectory(), HISTORY_PATH];
	while ((filename = [fileEnumerator nextObject]) != nil) {
		yearAndDate = [[filename substringFromIndex: 8]
			componentsSeparatedByString: @"_"];
		fileYear = [[yearAndDate firstObject] integerValue];
		fileMonth = [[yearAndDate objectAtIndex: 1] integerValue];
		isFileOld = fileYear < targetYear || (fileYear == targetYear &&
			fileMonth < targetMonth);
		if (isFileOld) {
			fullPath = [NSString stringWithFormat: @"%@/%@", historyPath,
				filename];
			err = nil;
			[[NSFileManager defaultManager] removeItemAtPath: fullPath
				error: &err];
			if (err != nil)
				NSLog(@"Error removing file at: %@", fullPath);
		}
	}
	// Open history file for current month or done if not exist
	NSString *currentMonth = [historyFiles lastObject];
	yearAndDate = [[currentMonth substringFromIndex: 8]
		componentsSeparatedByString: @"_"];
	fileYear = [[yearAndDate firstObject] integerValue];
	fileMonth = [[yearAndDate objectAtIndex: 1] integerValue];
	if (fileYear == targetYear || fileMonth == targetMonth) {
		fullPath = [NSString stringWithFormat: @"%@/%@", historyPath,
			currentMonth];
		[Website truncateHistoryFileAtPath: fullPath olderThanDate: date];
	}
}

+(void)truncateHistoryFileAtPath: (NSString*)path olderThanDate: (NSDate*)date {
	NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath: path];
	if (handle == nil) {
		NSLog(@"Failed to open history file for updating at path: %@", path);
		return;
	}
	NSTimeInterval ival = [date timeIntervalSinceReferenceDate];
	struct website_data buf[10];
	NSUInteger nread, i;
	NSData *data;
	do {
		data = [handle readDataUpToLength: sizeof(buf)];
		if (data == nil) {
			NSLog(@"readDataUpToLength failed");
			return;
		}
		nread = [data length] / sizeof (struct website_data);
		[data getBytes: buf length: nread * sizeof (struct website_data)];
		for (i = 0; i < nread; i++) {
			if (buf[i].timeIntervalSinceReferenceDate < ival)
				break;
		}
	} while (nread  == 10);
	// If we didn't iterate to the end, must thave found a point with older time.
	if (i == nread) {
		NSLog(@"Reached the end of history file without finding older entries");
		return;
	}
	// Rewind the file back to the start of that point.
	unsigned long long offset;
	long long rwnd = (long long)((i - nread) * sizeof (struct website_data));
	NSError *err = nil;
	[handle getOffset: &offset error: &err];
	if (err != nil) {
		NSLog(@"Failed to get file offset");
		return;
	}
	offset += rwnd;
	[handle truncateAtOffset: offset error: &err];
	if (err != nil) {
		NSLog(@"Failed to truncate history file");
		return;
	}
}
@end
