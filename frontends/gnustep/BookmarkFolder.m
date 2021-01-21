#import <Cocoa/Cocoa.h>
#import "BookmarkFolder.h"
#import "Website.h"

/*
Since there will be considerably less bookmarks than history entries, performance is less of
an issue here. So bookmarks are simply saved from NSDictionary into folders. One file
per website. Bookmark folders just mirror the directory structure. Child items are
lazy-loaded when requested.
*/

@interface BookmarkFolder(Private)
-(NSString*)path;
-(void)setPath: (NSString*)aPath;
-(void)initChildrenIfNeeded;
-(void)setChildren: (NSArray*)children;
-(NSString*)pathNameForWebsite: (Website*)website;
@end

@implementation BookmarkFolder

-(id)initWithName: (NSString*)aFolderName parent: (BookmarkFolder*)aParent {
	if (self = [super init]) {
		[aFolderName retain];
		parentFolder = [aParent retain];
		name = [aFolderName retain];
		children = nil;
		path = [[[aParent path] stringByAppendingPathComponent: aFolderName] retain];
	}
	return self;
}

-(void)dealloc {
	[parentFolder release];
	[children release];
	[name release];
	[path release];
	[super dealloc];
}

-(BookmarkFolder*)parentFolder {
	return parentFolder;
}

-(NSArray*)children {
	[self initChildrenIfNeeded];
	return children;
}

-(NSArray*)childrenApplyingFilter: (NSString*)filter {
	if (filter == nil || [filter length] < 1) {
		return [self children];
	}
	NSMutableArray *filteredChildren = [NSMutableArray array];
	NSEnumerator *enu = [[self children] objectEnumerator];
	id child;
	while ((child = [enu nextObject]) != nil) {
		if ([child isKindOfClass: [BookmarkFolder class]]) {
			[filteredChildren addObject: child];
		} else {
			NSRange range = [[child name] rangeOfString: filter options: 
				NSCaseInsensitiveSearch];
			if (range.location != NSNotFound) {
				[filteredChildren addObject: child];
			}
		}
	}
	return filteredChildren;
}

-(NSArray*)childFolders {
	NSMutableArray *folders = [NSMutableArray array];
	NSArray *allChildren = [self children];
	id child;
	for (NSUInteger i = 0; i < [allChildren count]; i++) {
		child = [allChildren objectAtIndex: i];
		if ([child isKindOfClass: [BookmarkFolder class]]) {
			[folders addObject: child];
		}
	}
	return folders;
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

-(void)addCopy: (id)item {
	if ([item isKindOfClass: [BookmarkFolder class]]) {
		NSString *source = [item path];
		NSString *dest = [[self path] stringByAppendingPathComponent: [item
			name]];
		NSError *err = nil;
		BOOL ok = [[NSFileManager defaultManager] copyItemAtPath: source toPath: dest
			error: &err];
		if (ok) {
			BookmarkFolder *copy = [[BookmarkFolder alloc] initWithName: [item
				name] parent: self];
			[self initChildrenIfNeeded];
			[children addObject: copy];
			[copy release];
		} else {
			NSLog(@"Failed to add copy.");
		}
	} else {
		[self addChild: [item copy]];
	}
}

-(void)moveChild: (id)child toOtherFolder: (BookmarkFolder*)otherFolder {
	NSString *source = nil;
	NSString *destination = nil;
	NSError *err = nil;
	BOOL ok = NO;
	BOOL isWebsite = NO;
	
	if ([child isKindOfClass: [BookmarkFolder class]]) {
		source = [child path];
		destination = [[otherFolder path] stringByAppendingPathComponent: [child
			name]];
	} else if ([child filename] != nil) {
		isWebsite = YES;
		source = [[self path] stringByAppendingPathComponent: [child filename]];
		destination = [[otherFolder path] stringByAppendingPathComponent: [child
			filename]];
	}
	if (source != nil) {
		ok = [[NSFileManager defaultManager] moveItemAtPath: source toPath: 
			destination error: &err];
	} else {
		NSLog(@"source is nil!");
	}
	if (ok) {
		[children removeObject: child];
		[otherFolder->children addObject: child];
		if ([child isKindOfClass: [BookmarkFolder class]]) {
			[(BookmarkFolder*)child setPath: destination];
		} else {
			[child setParentFolder: otherFolder];
		}
	} else {
		NSLog(@"Failed to move child");
	}
}

-(void)updateChild: (id)child {
	if ([child isKindOfClass: [Website class]]) {
		BOOL ok = NO;
		NSString *filename = [child filename];
		if (filename != nil) {
			NSString * destPath = [path stringByAppendingPathComponent: 
				filename];
			ok = [[child asDictionary] writeToFile: destPath atomically: YES];
		}
		if (!ok) {
			NSLog(@"Failed to resave the child");
		}
	}
}

-(void)addChild: (id)child {
	[self initChildrenIfNeeded];
	BOOL ok = NO;
	if ([child isKindOfClass: [Website class]]) {
		NSString *filename = [self pathNameForWebsite: child];
		NSString *destPath = [path stringByAppendingPathComponent: filename];
		ok = [[child asDictionary] writeToFile: destPath atomically: YES];
		[child setFilename: filename];
		[child setParentFolder: self];
	} else if ([child isKindOfClass: [BookmarkFolder class]]) {
		NSString *dest = [path stringByAppendingPathComponent: [child name]];
		ok = [[NSFileManager defaultManager] createDirectoryAtPath: dest
			attributes: nil];
	}
	if (ok) {
		[children addObject: child];
	} else {
		NSLog(@"Failed to add child to folder");
	}
}

-(void)removeChild: (id)child {
	[self initChildrenIfNeeded];
	BOOL ok = NO;
	NSError *err = nil;
	NSString *destPath = nil;
	if ([child isKindOfClass: [Website class]] && [child filename] != nil) {
		destPath = [path stringByAppendingPathComponent: [child filename]];
	} else if ([child isKindOfClass: [BookmarkFolder class]]) {
		destPath = [child path];
	}
	if ([destPath rangeOfString: BOOKMARKS_PATH].location == NSNotFound) {
		NSLog(@"Refusing to delete path not within NetSurf directory");
		return;
	}
	ok = [[NSFileManager defaultManager] removeItemAtPath: destPath error: &err];
	if (ok && err == nil) {
		[children removeObject: child];
	} else {
		NSLog(@"Failed to remove child");
	}
}

-(void)setName: (NSString*)aName {
	if ([aName length] < 1) {
		return;
	}
	[name release];
	name = [aName retain];
	
	NSString *toPath = [[path stringByDeletingLastPathComponent] 
		stringByAppendingPathComponent: aName];
	NSError *err = nil;
	[[NSFileManager defaultManager] moveItemAtPath: [self path] toPath: toPath error:
		&err];
	if (err == nil) {
		[path release];
		path = [toPath retain];
	} else {
		NSLog(@"Error renaming directory");
	}
}

+(BookmarkFolder*)rootBookmarkFolder {
	static BookmarkFolder *cachedRootFolder;
	if (cachedRootFolder != nil) {
		return cachedRootFolder;
	}

	NSString *rootPath = [NSHomeDirectory() stringByAppendingPathComponent: 
		BOOKMARKS_PATH];
	NSString *unsortedPath = [rootPath stringByAppendingPathComponent: UNSORTED_NAME];
	[[NSFileManager defaultManager] createDirectoryAtPath: rootPath attributes: nil];
	[[NSFileManager defaultManager] createDirectoryAtPath: unsortedPath attributes: nil];
	BookmarkFolder *rootFolder = [[BookmarkFolder alloc] initWithName: @"Bookmarks"
		parent: nil];
	[rootFolder setPath: rootPath];
	cachedRootFolder = [rootFolder retain];
	return rootFolder;
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
	return nil;
}

static NSArray *foldersOfFolder(BookmarkFolder *folder) {
	NSMutableArray *array = [NSMutableArray array];
	NSArray *childFolders = [folder childFolders];
	BookmarkFolder *childFolder;
	for (NSUInteger i = 0; i < [childFolders count]; i++) {
		childFolder = [childFolders objectAtIndex: i];
		[array addObject: childFolder];
		[array addObjectsFromArray: foldersOfFolder(childFolder)];
	}
	return array;
}
+(NSArray*)allFolders {
	return foldersOfFolder([BookmarkFolder rootBookmarkFolder]);
}

-(NSString*)path {
	return path;
}
-(void)setPath: (NSString*)aPath {
	[path release];
	path = [aPath retain];
}
-(void)setChildren: (NSMutableArray*)someChildren {
	[children release];
	children = [someChildren retain];
}
-(NSString*)pathNameForWebsite: (Website*)aWebsite {
	NSTimeInterval time = [[NSDate date] timeIntervalSinceReferenceDate];
	NSNumber *num = [NSNumber numberWithDouble: time];
	return [num stringValue];

}
-(void)initChildrenIfNeeded {
	if (children != nil) {
		return;
	}
	NSMutableArray *newChildren = [[NSMutableArray alloc] init];
	NSError *err = nil;
	NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: 
		path error: &err];
	if (err != nil) {
		NSLog(@"Error reading bookmarks root directory");
		children = nil;
		return;
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
			chDict = [NSDictionary dictionaryWithContentsOfFile: chPath];
			child = [[Website alloc] initWithDictionary: chDict fromFileNamed:
				fileName];
			[child setParentFolder: self];
			[newChildren addObject: [child autorelease]];
		}
	}
	children = newChildren;
}
@end