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

+(NSMutableArray*)getHistoryFromPath: (NSString*)path matching: (NSString*)queryString {
	size_t nread, wsize;
	long fileoff;
	int lens[2];
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

+(NSArray*)getAllHistoryPaths {
	NSString *path = [NSString stringWithFormat: @"%@/%@", NSHomeDirectory(), 
		HISTORY_PATH];
	NSError *error = nil;
	NSPredicate *historyPredicate = [NSPredicate predicateWithFormat: 
		@"self beginswith 'history_'"];
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: path
		error: &error];
	if (error != nil) {
		NSLog(@"Error fetching files in history dir: %@", path);
		return [NSArray array];
	}
	files = [files filteredArrayUsingPredicate: historyPredicate];
	NSLog(@"%@", files);
	return [files sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
}

@end
