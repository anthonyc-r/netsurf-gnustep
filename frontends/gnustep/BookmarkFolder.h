#import <Cocoa/Cocoa.h>

#define BOOKMARKS_PATH @"/.config/NetSurf"
#define UNSORTED_NAME @"Unsorted"

@interface BookmarkFolder: NSObject {
	NSString *name;
	NSString *path;
	NSArray *children;
	BookmarkFolder *parentFolder;
}

-(id)initWithName: (NSString*)aName parent: (BookmarkFolder*)aParent;
-(NSArray*)children;
-(NSString*)name;
-(BOOL)isRootFolder;
-(BOOL)isUnsortedFolder;
-(void)deleteFolder;
-(void)addChild: (id)child;
-(void)removeChild: (id)child;


+(BookmarkFolder*)rootBookmarkFolder;
+(BookmarkFolder*)unsortedBookmarkFolder;
@end