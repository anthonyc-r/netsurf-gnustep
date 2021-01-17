#import <Cocoa/Cocoa.h>

#define BOOKMARKS_PATH @"/.config/NetSurf/Bookmarks"
#define UNSORTED_NAME @"Unsorted"

@interface BookmarkFolder: NSObject {
	NSString *name;
	NSString *path;
	NSMutableArray *children;
	BookmarkFolder *parentFolder;
}

-(id)initWithName: (NSString*)aName parent: (BookmarkFolder*)aParent;
-(BookmarkFolder*)parentFolder;
-(NSArray*)children;
-(NSArray*)childFolders;
-(NSString*)name;
-(BOOL)isRootFolder;
-(BOOL)isUnsortedFolder;
-(void)addChild: (id)child;
-(void)removeChild: (id)child;
-(void)updateChild: (id)child;
-(void)moveChild: (id)child toOtherFolder: (BookmarkFolder*)otherFolder;
-(void)setName: (NSString*)aName;

+(BookmarkFolder*)rootBookmarkFolder;
+(BookmarkFolder*)unsortedBookmarkFolder;
@end