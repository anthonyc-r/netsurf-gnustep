#import <Cocoa/Cocoa.h>

#define WebsiteHistoryUpdatedNotificationName @"WebsiteHistoryUpdatedNotification"
#define HISTORY_PATH @"/.config/NetSurf"

struct website_data {
	int len_name;
	// A 0 value of len_url implies that the data has been 'cleared', and should be 
	// ignored. In this case, len_name will be the entire length of the structure.
	// See HistoryWindowController for the impl of this.
	int len_url;
	char data[];
};

@class BookmarkFolder;
@interface Website: NSObject {
	BookmarkFolder *parentFolder;
	NSString *filename;
	long fileOffset;
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
@end
