#import <Cocoa/Cocoa.h>

#define HISTORY_UPDATED_NOTIFICATION @"history_updated"

@class BookmarkFolder;
@interface Website: NSObject {
	NSString *name;
	NSURL *url;
	NSDate *lastVisited;
}

-(id)initWithName: (NSString*)aName url: (NSURL*)aUrl;
-(NSString*)name;
-(NSURL*)url;

-(void)addToHistory;
-(void)removeFromHistory;
+(NSArray*)historicWebsites;

@end