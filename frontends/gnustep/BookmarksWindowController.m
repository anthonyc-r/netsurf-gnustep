#import <AppKit/AppKit.h>
#import "BookmarksWindowController.h"
#import "BookmarkFolder.h"

@implementation BookmarksWindowController

-(id)init {
	if ((self = [super initWithWindowNibName: @"Bookmarks"])) {
		// ...
	}
	return self;
}

-(BOOL)windowShouldClose: (id)sender {
	[topLevelFolders release];
	topLevelFolders = nil;
	return YES;
}

-(void)onWindowAppeared {
	topLevelFolders = [[[BookmarkFolder rootBookmarkFolder] children] retain];
	[outlineView reloadData];
	for (NSUInteger i = 0; i < [topLevelFolders count]; i++) {
		[outlineView expandItem: [topLevelFolders objectAtIndex: i] 
			expandChildren: NO];
	}
}

-(void)awakeFromNib {
	[[self window] makeKeyAndOrderFront: self];
	[self onWindowAppeared];
}

-(void)showWindow: (id)sender {
	[self onWindowAppeared];
	[super showWindow: sender];
}

-(void)search: (id)sender {
  NSLog(@"search bookmarks");
}


-(void)clearSearch: (id)sender {
  NSLog(@"Clear bookmarks search");
}


-(id)outlineView: (NSOutlineView*)outlineView child: (NSInteger)index ofItem: (id)item {
	if (item == nil) {
		return [topLevelFolders objectAtIndex: index];
	} else if ([item isKindOfClass: [BookmarkFolder class]]) {
		return [[item children] objectAtIndex: index];
	} else {
		return nil;
	}
}

-(BOOL)outlineView: (NSOutlineView*)outlineView isItemExpandable: (id)item {
	return [item isKindOfClass: [BookmarkFolder class]];
}

-(NSInteger)outlineView: (NSOutlineView*)outlineView numberOfChildrenOfItem: (id)item {
	if (item == nil) {
		return [topLevelFolders count];
	} else if ([item isKindOfClass: [BookmarkFolder class]]) {
		return [[item children] count];
	} else {
		return 0;
	}
}

-(id)outlineView: (NSOutlineView*)outlineView objectValueForTableColumn: (NSTableColumn*)tableColumn byItem: (id)item {
	if ([item respondsToSelector: @selector(name)]) {
		return [item name];
	} else {
		return @"Error";
	}
}

@end
