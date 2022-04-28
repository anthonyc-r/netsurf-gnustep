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
#import <stdio.h>
#import <string.h>
#import <errno.h>

#import "Website.h"
#import "AppDelegate.h"

@interface Website(Private)
+(void)zeroHistoryFileAtPath: (NSString*)path olderThanDate: (NSDate*)date;
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
	NSLog(@"Parsing file: %@", path);
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
		if (wdata == NULL) {
			perror("NULL MALLOC?!");
			return ret;
		}
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
		char *cTmpPath = tempnam(NULL, NULL);
		NSString *tmpPath = [NSString stringWithCString: cTmpPath];
		NSLog(@"Copying file from '%@', to '%@'", fullPath, tmpPath);
		err = nil;
		[[NSFileManager defaultManager] copyItemAtPath: fullPath toPath: tmpPath
			error: &err];
		if (err != nil) {
			NSLog(@"Error copying history to temp file at path: %@ (%@)", tmpPath, err);
			return;
		}
		[Website zeroHistoryFileAtPath: tmpPath olderThanDate: date];
		err = nil;
		[[NSFileManager defaultManager] removeItemAtPath: fullPath error: &err];
		if (err != nil) {
			NSLog(@"Failed to remove existing history file at path: %@", fullPath);
			return;
		}
		[[NSFileManager defaultManager] moveItemAtPath: tmpPath toPath: fullPath
			error: &err];
		if (err != nil) {
			NSLog(@"Failed to copy back the tmp file at %@, to path %@", tmpPath,
				fullPath);
		} else {
			NSLog(@"Copied history file back in place");
		}
	}
}

+(void)zeroHistoryFileAtPath: (NSString*)path olderThanDate: (NSDate*)date {
	NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath: path];
	if (handle == nil) {
		NSLog(@"Failed to open history file for updating at path: %@", path);
		return;
	}
	NSTimeInterval ival = [date timeIntervalSinceReferenceDate];
	NSLog(@"clear history older than: %f", ival);
	NSData *data;
	NSError *err = nil;
	BOOL foundEnd = NO;
	int totalSize, largestSize;
	largestSize = 100;
	struct website_data *wdata = malloc(largestSize);
	do {
		data = [handle readDataOfLength: offsetof(struct website_data, data)];
		if (data == nil || [data length] == 0) {
			NSLog(@"readDataUpToLength 1 failed (EOF?)");
			break;
		}
		[data getBytes: wdata length: offsetof(struct website_data, data)];

		data = [handle readDataOfLength: wdata->len_name + wdata->len_url];
		if (data == nil || [data length] == 0) {
			NSLog(@"readDataUpToLength 2 failed (EOF?)");
			break;
		}
		totalSize = sizeof (struct website_data) + wdata->len_name + wdata->len_url;
		if (totalSize > largestSize) {
			wdata = realloc(wdata, totalSize);
			largestSize = totalSize;
		}
		[data getBytes: &(wdata->data) length: wdata->len_name + wdata->len_url];
		if (wdata->len_url == 0) {
			// Deleted entry, skip.
			continue;
		}
		if (wdata->timeIntervalSinceReferenceDate > ival) {
			NSLog(@"End found");
			foundEnd = YES;
			break;
		}
	} while (!foundEnd);
	free(wdata);

	if (!foundEnd) {
		NSLog(@"Reached the end of history file without finding newer entries. Clear entire file.");
		[handle truncateFileAtOffset: 0];
		return;
	}
	unsigned long long offset = [handle offsetInFile];
	if (err != nil) {
		NSLog(@"Failed to get file offset");
		return;
	}
	offset -= (unsigned long long)totalSize;
	if (offset == 0) {
		NSLog(@"No entries need clearing.");
		return;
	}
	wdata = calloc(1, offset);
	wdata->len_name = offset - sizeof (struct website_data);
	wdata->len_url = 0;
	[handle seekToFileOffset: 0];
	[handle writeData: [NSData dataWithBytesNoCopy: wdata length: offset]];
	[handle closeFile];
	NSLog(@"Zero'd %@ to %llu", path, offset);
}
@end
