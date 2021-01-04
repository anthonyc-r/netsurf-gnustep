#include <AppKit/AppKit.h>
#include "BookmarksWindowController.h"
#include "BookmarkFolder.h"

@implementation BookmarksWindowController

-(id)init {
	if ((self = [super initWithWindowNibName: @"Bookmarks"])) {
		// ...
	}
	return self;
}

-(void)onWindowAppeared {
	topLevelFolders = [[BookmarkFolder rootBookmarkFolder] children];
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
	return nil;
}

-(BOOL)outlineView: (NSOutlineView*)outlineView isItemExpandable: (id)item {
	return NO;
}

-(NSInteger)outlineView: (NSOutlineView*)outlineView numberOfChildrenOfItem: (id)item {
	if (item == nil) {
		return [topLevelFolders count];
	} else {
		return [item count];
	}
}

-(id)outlineView: (NSOutlineView*)outlineView objectValueForTableColumn: (NSTableColumn*)tableColumn byItem: (id)item {
	return nil;
}

@end
