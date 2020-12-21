#import <Cocoa/Cocoa.h>
#import "BookmarkFolder.h"

@implementation BookmarkFolder

-(id)initWithName: (NSString*)aFolderName parent: (BookmarkFolder*)aParent {
	if (self = [super init]) {
		[aFolderName retain];
		name = aFolderName;
		children = [[NSArray alloc] init];
	}
	return self;
}

-(void)dealloc {
	[children release];
	[name release];
	[super dealloc];
}

-(NSArray*)children {
	return children;
}

-(NSString*)name {
	return name;
}

-(BOOL)isRootFolder {
	return NO;
}

-(void)save {
	
}

+(BookmarkFolder*)rootBookmarkFolder {
	return nil;
}

@end