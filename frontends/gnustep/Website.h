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
	long fileOffset;
	struct website_data *data;
}

-(id)initWithName: (NSString*)aName url: (NSString*)aUrl;
-(id)initWithData: (struct website_data*)someData atFileOffset: (long)aFileOffset;
-(id)initWithDictionary: (NSDictionary*)aDictionary;
-(NSString*)name;
-(NSString*)url;
-(long)fileOffset;

-(NSDictionary*)asDictionary;

-(void)open;
-(void)addToHistory;
@end