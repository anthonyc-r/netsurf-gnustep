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

#define WebsiteHistoryUpdatedNotificationName @"WebsiteHistoryUpdatedNotification"
#define HISTORY_PATH @"/.config/NetSurf/history"

struct website_data {
	int len_name;
	// A 0 value of len_url implies that the data has been 'cleared', and should be 
	// ignored. In this case, len_name will be the entire length of 'data'.
	// See HistoryWindowController for the impl of this.
	int len_url;
	NSTimeInterval timeIntervalSinceReferenceDate;
	char data[];
};

@class BookmarkFolder;
@interface Website: NSObject {
	BookmarkFolder *parentFolder;
	NSString *filename;
	long fileOffset;
	NSDate *dateViewed;
	struct website_data *data;
}

-(id)initWithName: (NSString*)aName url: (NSString*)aUrl;
-(id)initWithData: (struct website_data*)someData atFileOffset: (long)aFileOffset;
-(id)initWithDictionary: (NSDictionary*)aDictionary fromFileNamed: (NSString*)aFilename;
-(NSString*)name;
-(NSString*)url;
-(void)setName: (NSString*)aName;
-(long)fileOffset;
-(NSString*)filename;
-(Website*)copy;
-(void)setFilename: (NSString*)aFilename;
-(BookmarkFolder*)parentFolder;
-(void)setParentFolder: (BookmarkFolder*)aBookmarkFolder;
-(NSDictionary*)asDictionary;

-(void)open;
-(void)addToHistory;

+(NSArray*)getAllHistoryFiles;
+(NSMutableArray*)getHistoryFromFile: (NSString*)file matching: (NSString*)queryString;
+(void)deleteHistoryOlderThanDays: (NSUInteger)days;
+(void)deleteHistoryOlderThanDate: (NSDate*)date;
@end
