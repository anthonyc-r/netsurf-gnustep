#import <AppKit/AppKit.h>
#import "BookmarksWindowController.h"
#import "BookmarkFolder.h"
#import "Website.h"

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

-(void)newFolder: (id)sender {
	NSLog(@"create new folder");
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

-(BOOL)outlineView: (NSOutlineView*)outlineView shouldEditTableColumn: (NSTableColumn*)tableColumn item: (id)item {
	return YES;
}

-(void)outlineView: (NSOutlineView*)outlineView willDisplayCell: (id)cell forTableColumn: (NSTableColumn*)tableColumn item: (id)item {
	[cell setEditable: YES];
}

-(void)outlineView: (NSOutlineView*)outlineView setObjectValue: (id)object forTableColumn: (NSTableColumn*)tableColumn byItem: (id)item {
	if ([item isKindOfClass: [Website class]]) {
		[(Website*)item setName: object];
		BookmarkFolder *folder = [outlineView parentForItem: item];
		[folder updateChild: item];
	} else if ([item isKindOfClass: [BookmarkFolder class]]) {
		[(BookmarkFolder*)item setName: object];
	}
}

@end
