#import <Cocoa/Cocoa.h>

@interface BookmarkFolder: NSObject {
	NSString *name;
	NSArray *children;
	BookmarkFolder *parentFolder;
}

-(id)initWithName: (NSString*)aName parent: (BookmarkFolder*)aParent;
-(NSArray*)children;
-(NSString*)name;
-(BOOL)isRootFolder;
-(void)deleteFolder;
-(void)addChild: (id)child;
-(void)removeChild: (id)child;


+(BookmarkFolder*)rootBookmarkFolder;
+(BookmarkFolder*)unsortedBookmarkFolder;
@end