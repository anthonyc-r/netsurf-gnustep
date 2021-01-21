#import <AppKit/AppKit.h>
#import "BookmarksWindowController.h"
#import "BookmarkFolder.h"
#import "Website.h"
#import "AppDelegate.h"
#import "CreateBookmarkPanelController.h"

static NSString * const NEW_FOLDER_NAME = @"New Folder";

@interface BookmarksWindowController (Private)
-(NSArray*)selectedItems;
-(NSString*)getNewFolderNameForParent: (BookmarkFolder*)aFolder;
-(void)bookmarksUpdated: (NSNotification*)notification;
@end

@implementation BookmarksWindowController

-(id)init {
	if ((self = [super initWithWindowNibName: @"Bookmarks"])) {
		filterValue = nil;
		copiedItems = nil;
		topLevelFolders = nil;
		isCutting = NO;
	}
	return self;
}

-(void)dealloc {
	[copiedItems release];
	[topLevelFolders release];
	[filterValue release];
	[super dealloc];
}

-(BOOL)windowShouldClose: (id)sender {
	[topLevelFolders release];
	topLevelFolders = nil;
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	return YES;
}

-(void)onWindowAppeared {
	topLevelFolders = [[NSArray alloc] initWithObjects: [BookmarkFolder
		rootBookmarkFolder], nil];
	[outlineView reloadData];
	for (NSUInteger i = 0; i < [topLevelFolders count]; i++) {
		[outlineView expandItem: [topLevelFolders objectAtIndex: i] 
			expandChildren: YES];
	}
	[[NSNotificationCenter defaultCenter] addObserver: self
		selector: @selector(bookmarksUpdated:)
		name: BookmarksUpdatedNotificationName
		object: nil];
}

-(void)awakeFromNib {
	[[self window] makeKeyAndOrderFront: self];
	[self onWindowAppeared];
}

-(void)cut: (id)sender {
	isCutting = YES;
	[copiedItems release];
	copiedItems = [[self selectedItems] retain];
}

-(void)copy: (id)sender {
	isCutting = NO;
	[copiedItems release];
	copiedItems = [[self selectedItems] retain];
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
			[[item parentFolder] moveChild: item toOtherFolder: 
				destinationFolder];
		} else {
			[destinationFolder addCopy: item];
		}
	}
	
	if (isCutting) {
		isCutting = NO;
		[copiedItems release];
		copiedItems = nil;
	}
	[outlineView reloadData];
	[[NSNotificationCenter defaultCenter] postNotificationName:
		BookmarksUpdatedNotificationName object: self];
}

-(void)remove: (id)sender {
	NSArray *selectedItems = [self selectedItems];
	id item;
	for (NSUInteger i = 0; i < [selectedItems count]; i++) {
		item = [selectedItems objectAtIndex: i];
		[[item parentFolder] removeChild: item];
	}
	[outlineView reloadData];
	[[NSNotificationCenter defaultCenter] postNotificationName:
		BookmarksUpdatedNotificationName object: self];
}

-(void)open: (id)sender {
	NSEnumerator *selected = [outlineView selectedRowEnumerator];
	id row, item;
	while ((row = [selected nextObject]) != nil) {
		item = [outlineView itemAtRow: [row integerValue]];
		if ([item isKindOfClass: [Website class]]) {
			[[NSApp delegate] openWebsite: item];
			break;
		}
	}
}

-(void)newFolder: (id)sender {
	NSEnumerator *selected = [outlineView selectedRowEnumerator];
	id row = [selected nextObject];
	id item = nil;
	if (row != nil) {
		item = [outlineView itemAtRow: [row integerValue]];
		if ([item isKindOfClass: [Website class]]) {
			item = [item parentFolder];
		}
	} 
	if (item == nil) {
		item = [BookmarkFolder rootBookmarkFolder];
	}
	NSString *folderName = [self getNewFolderNameForParent: item];
	BookmarkFolder *folder = [[BookmarkFolder alloc] initWithName: folderName parent:
		item];
	[item addChild: folder];
	[folder release];
	[outlineView reloadData];
	[[NSNotificationCenter defaultCenter] postNotificationName:
		BookmarksUpdatedNotificationName object: self];
}

-(void)showWindow: (id)sender {
	[self onWindowAppeared];
	[super showWindow: sender];
}

-(void)search: (id)sender {
	[filterValue release];
	filterValue = [[sender stringValue] retain];
	[outlineView reloadData];
}


-(void)clearSearch: (id)sender {
	[filterValue release];
	filterValue = nil;
	[outlineView reloadData];
	[searchBar setStringValue: nil];
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
		return [[item childrenApplyingFilter: filterValue] objectAtIndex: index];
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
		return [[item childrenApplyingFilter: filterValue] count];
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
	if ([item isKindOfClass: [BookmarkFolder class]]) {
		return !([item isUnsortedFolder] || [item isRootFolder]);
	} else {
		return YES;
	}
}

-(void)outlineView: (NSOutlineView*)outlineView willDisplayCell: (id)cell forTableColumn: (NSTableColumn*)tableColumn item: (id)item {
	[cell setEditable: YES];
}

-(void)outlineView: (NSOutlineView*)outlineView setObjectValue: (id)object forTableColumn: (NSTableColumn*)tableColumn byItem: (id)item {
	if ([[item name] isEqual: object]) {
		return;
	}
	if ([item isKindOfClass: [Website class]]) {
		[(Website*)item setName: object];
		BookmarkFolder *folder = [outlineView parentForItem: item];
		[folder updateChild: item];
	} else if ([item isKindOfClass: [BookmarkFolder class]]) {
		[(BookmarkFolder*)item setName: object];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:
		BookmarksUpdatedNotificationName object: self];
}
-(NSArray*)selectedItems {
	NSEnumerator *selected = [outlineView selectedRowEnumerator];
	NSMutableArray *selectedFolders = [NSMutableArray array];
	NSMutableArray *selectedItems = [NSMutableArray array];
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
			if ([item isRootFolder]) {
				continue;
			}
			[selectedFolders addObject: item];
		}
		if ([selectedFolders containsObject: [item parentFolder]]) {
			continue;
		}
		[selectedItems addObject: item];
	}
	return selectedItems;
}

-(NSString*)getNewFolderNameForParent: (BookmarkFolder*)aFolder {
	NSEnumerator *existingFolders = [[aFolder childFolders] objectEnumerator];
	BookmarkFolder *folder;
	NSInteger highestNumber = 0;
	NSInteger currentValue;
	NSString *suffix;
	BOOL hasExactName = NO;
	while ((folder = [existingFolders nextObject]) != nil) {
		if ([[folder name] hasPrefix: NEW_FOLDER_NAME]) {
			suffix = [[folder name] substringFromIndex: [NEW_FOLDER_NAME
				length]];
			if ([suffix length] < 1) {
				hasExactName = YES;
				continue;
			}
			currentValue = [suffix integerValue];
			highestNumber = MAX(currentValue, highestNumber);
		}
	}
	if (!hasExactName) {
		return NEW_FOLDER_NAME;
	} else {
		return [NSString stringWithFormat: @"%@%ld", NEW_FOLDER_NAME, 
			highestNumber + 1]; 	
	}
}

-(void)bookmarksUpdated: (NSNotification*)notification {
	if ([[notification object] isKindOfClass: [CreateBookmarkPanelController class]]) {
		[outlineView reloadData];
	}
}

@end
