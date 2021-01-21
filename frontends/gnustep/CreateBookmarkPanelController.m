#import <AppKit/AppKit.h>
#import "CreateBookmarkPanelController.h"
#import "Website.h"
#import "BookmarkFolder.h"

@implementation CreateBookmarkPanelController

-(id)initForWebsite: (Website*)aWebsite {
	if (self = [super initWithWindowNibName: @"CreateBookmark"]) {
		website = [aWebsite retain];
		bookmarkFolders = [[BookmarkFolder allFolders] retain];
	}
	return self;
}

-(void)dealloc {
	[website release];
	[bookmarkFolders release];
	[super dealloc];
}

-(void)awakeFromNib {
	NSLog(@"Awoke from nib");
	[nameField setStringValue: [website name]]; 
	for (NSUInteger i = 0; i < [bookmarkFolders count]; i++) {
		[folderButton addItemWithTitle: [[bookmarkFolders objectAtIndex: i]
			name]];
	}
}

-(void)didTapCancel: (id)sender {
	[self close];
}

-(void)didTapOkay: (id)sender {
	Website *toSave = [[Website alloc] initWithName: [nameField stringValue]
		url: [website url]];
	BookmarkFolder *destination = [bookmarkFolders objectAtIndex: [folderButton
		indexOfSelectedItem]];
	[destination addChild: toSave];
	[[NSNotificationCenter defaultCenter] postNotificationName: 
		BookmarksUpdatedNotificationName object: self];
	[toSave release];
	[self close];
}

@end
