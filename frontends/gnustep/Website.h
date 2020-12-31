#import <Cocoa/Cocoa.h>

#define WebsiteHistoryUpdatedNotificationName @"WebsiteHistoryUpdatedNotification"

struct website_data {
	int len_name;
	int len_url;
	char data[];
};

@class BookmarkFolder;
@interface Website: NSObject {
	struct website_data *data;
}

-(id)initWithName: (NSString*)aName url: (NSString*)aUrl;
-(NSString*)name;
-(NSString*)url;

-(void)open;
-(void)addToHistory;
@end