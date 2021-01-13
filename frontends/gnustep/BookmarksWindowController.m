#import <AppKit/AppKit.h>
#import "BookmarksWindowController.h"
#import "BookmarkFolder.h"
#import "Website.h"
#import "AppDelegate.h"

@interface BookmarksWindowController (Private)
-(void)copySelectedItems;
@end

@implementation BookmarksWindowController

-(id)init {
	if ((self = [super initWithWindowNibName: @"Bookmarks"])) {
		// ...
	}
	return self;
}

-(void)dealloc {
	[copiedItems release];
	[topLevelFolders release];
	[super dealloc];
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

-(void)cut: (id)sender {
	isCutting = YES;
	[self copySelectedItems];
}

-(void)copy: (id)sender {
	isCutting = NO;
	[self copySelectedItems];
}

-(void)paste: (id)sender {
	NSEnumerator *selected = [outlineView selectedRowEnumerator];
	NSNumber *row = [selected nextObject];
	if (row == nil) {
		return;
	}
	id item = [outlineView itemAtRow: [row integerValue]];
	if (row == nil) {
		return;
	}
	BookmarkFolder *destinationFolder = nil;
	if ([item isKindOfClass: [Website class]]) {
		destinationFolder = [item parentFolder];
	} else if ([item isKindOfClass: [BookmarkFolder class]]) {
		destinationFolder = item;
	}
	if (destinationFolder == nil) {
		NSLog(@"Couldn't find destination for paste");
		return;
	}
	for (NSUInteger i = 0; i < [copiedItems count]; i++) {
		item = [copiedItems objectAtIndex: i];
		if (isCutting) {
			[[item parentFolder] removeChild: item];
		}
		[destinationFolder addChild: item];
	}
	
	if (isCutting) {
		isCutting = NO;
		[copiedItems release];
		copiedItems = nil;
	}
}

-(void)remove: (id)sender {

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

-(BOOL)validateMenuItem: (NSMenuItem*)aMenuItem {
	NSInteger tag = [aMenuItem tag];
	if (tag == TAG_MENU_REMOVE || tag == TAG_MENU_OPEN || tag == TAG_MENU_COPY || 
		tag == TAG_MENU_CUT) {
		return [outlineView numberOfSelectedRows] > 0;
	} else if (tag == TAG_MENU_PASTE) {
		return copiedItems != nil;
	}
	return YES;
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

-(void)copySelectedItems {
	NSEnumerator *selected = [outlineView selectedRowEnumerator];
	NSMutableArray *copiedFolders = [NSMutableArray array];
	NSMutableArray *toCopy = [NSMutableArray array];
	BOOL addedToPB = NO; 
	id row, item;
	while ((row = [selected nextObject]) != NULL) {
		item = [outlineView itemAtRow: [row integerValue]];
		if (!addedToPB && [item isKindOfClass: [Website class]]) {
			[[NSPasteboard generalPasteboard] setString: [item url]
				forType: NSStringPboardType];
			addedToPB = YES;
		}
		if ([item isKindOfClass: [BookmarkFolder class]]) {
			[copiedFolders addObject: item];
		}
		if ([copiedFolders containsObject: [item parentFolder]]) {
			break;
		}
		[toCopy addObject: item];
	}
	[copiedItems release];
	copiedItems = [toCopy retain];
}

@end
