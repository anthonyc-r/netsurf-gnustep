#import <Cocoa/Cocoa.h>
#import "BookmarkFolder.h"
#import "Website.h"

/*
Since there will be considerably less bookmarks than history entries, performance is less of
an issue here. So bookmarks are simply saved from NSDictionary into folders. One file
per website. Bookmark folders just mirror the directory structure. Child items are
lazy-loaded when requested.
*/

static BookmarkFolder *cachedRootFolder;
@interface BookmarkFolder(Private)
-(NSString*)path;
-(void)setPath: (NSString*)aPath;
-(void)setChildren: (NSArray*)children;
@end

@implementation BookmarkFolder

-(id)initWithName: (NSString*)aFolderName parent: (BookmarkFolder*)aParent {
	if (self = [super init]) {
		[aFolderName retain];
		name = aFolderName;
		children = nil;
		path = [[[aParent path] stringByAppendingPathComponent: aFolderName] retain];
	}
	return self;
}

-(void)dealloc {
	if ([self isRootFolder]) {
		cachedRootFolder = nil;
	}
	[children release];
	[name release];
	[path release];
	[super dealloc];
}

-(NSArray*)children {
	if (children != nil) {
		return children;
	}
	
	NSMutableArray *newChildren = [[NSMutableArray alloc] init];
	NSError *err = nil;
	NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: 
		path error: &err];
	if (err != nil) {
		NSLog(@"Error reading bookmarks root directory");
		return nil;
	}
	NSString *fileName;
	NSString *chPath;
	NSDictionary *chDict;
	id child;
	BOOL isDir;
	for (NSUInteger i = 0; i < [fileNames count]; i++) {
		fileName = [fileNames objectAtIndex: i];
		chPath = [path stringByAppendingPathComponent: fileName];
		isDir = NO;
		[[NSFileManager defaultManager] fileExistsAtPath: chPath 
			isDirectory: &isDir];
		if (isDir) {
			child = [[BookmarkFolder alloc] initWithName: fileName parent: self];
			[newChildren addObject: [child autorelease]];
		} else {
			chDict = [NSDictionary contentsOfFileAtPath: chPath];
			child = [[Website alloc] initWithDictionary: chDict];
			[newChildren addObject: [child autorelease]];
		}
	}
	children = newChildren;
	return children;
}

-(NSString*)name {
	return name;
}

-(BOOL)isRootFolder {
	return parentFolder == nil;
}

-(BOOL)isUnsortedFolder {
	return [name isEqual: UNSORTED_NAME];
}

-(void)deleteFolder {

}

-(void)addChild: (id)child {
	if ([child isKindOfClass: [Website class]]) {

	} else if ([child isKindOfClass: [BookmarkFolder class]]) {

	}
}

-(void)removeChild: (id)child {
	if ([child isKindOfClass: [Website class]]) {

	} else if ([child isKindOfClass: [BookmarkFolder class]]) {

	}
}

+(BookmarkFolder*)rootBookmarkFolder {
	if (cachedRootFolder != nil) {
		return [cachedRootFolder autorelease];
	}

	NSString *rootPath = [NSHomeDirectory() stringByAppendingPathComponent: 
		BOOKMARKS_PATH];
	NSString *unsortedPath = [rootPath stringByAppendingPathComponent: UNSORTED_NAME];
	[[NSFileManager defaultManager] createDirectoryAtPath: rootPath attributes: nil];
	[[NSFileManager defaultManager] createDirectoryAtPath: unsortedPath attributes: nil];
	BookmarkFolder *rootFolder = [[BookmarkFolder alloc] initWithName: @"" parent: nil];
	[rootFolder setPath: rootPath];
	cachedRootFolder = rootFolder;
	return [rootFolder autorelease];
}

+(BookmarkFolder*)unsortedBookmarkFolder {
	id child;
	NSArray *rootChildren = [[BookmarkFolder rootBookmarkFolder] children];
	for (NSUInteger i = 0; i < [rootChildren count]; i++) {
		child = [rootChildren objectAtIndex: i];
		if ([child isKindOfClass: [BookmarkFolder class]] 
			&& [child isUnsortedFolder]) {
			
			return child;
		}
	}
}

-(NSString*)path {
	return path;
}
-(void)setPath: (NSString*)aPath {
	[path release];
	path = [aPath retain];
}
-(void)setChildren: (NSArray*)someChildren {
	[children release];
	children = [someChildren retain];
}

@end