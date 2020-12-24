#import <Cocoa/Cocoa.h>

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
+(NSArray*)historicWebsites;

@end