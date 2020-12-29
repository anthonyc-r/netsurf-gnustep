#import <Cocoa/Cocoa.h>

#define WebsiteHistoryUpdatedNotificationName @"WebsiteHistoryUpdatedNotification"

@class BookmarkFolder;
@interface Website: NSObject {
	NSString *name;
	NSURL *url;
	NSDate *lastVisited;
}

-(id)initWithName: (NSString*)aName url: (NSURL*)aUrl;
-(NSString*)name;
-(NSURL*)url;

-(void)open;

-(void)addToHistory;
-(void)removeFromHistory;
+(NSArray*)historicWebsites;

@end