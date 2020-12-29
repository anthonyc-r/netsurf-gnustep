#import <Cocoa/Cocoa.h>
#import "HistoryWindowController.h"
#import "Website.h"
#import "AppDelegate.h"

@implementation HistoryWindowController

-(id)init {
	if (self = [super initWithWindowNibName: @"History"]) {
		historyItems = [[NSMutableDictionary alloc] init];
		[historyItems setObject: [Website historicWebsites] forKey: @"recent"];
		ignoreRefresh = NO;
	}
	return self;
}

-(void)dealloc {
	[historyItems release];
	[super dealloc];
}


-(void)updateItems: (NSNotification*)aNotification {
	if (!ignoreRefresh) {
		[historyItems setObject: [Website historicWebsites] forKey: @"recent"];
		[outlineView reloadData];
	}
}

// NOTE: - windowWillClose only gets called the first time the window is closed. gnustep bug?
-(BOOL)windowShouldClose: (id)sender {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	return YES;
}


-(void)registerForHistoryNotifications {
	[[NSNotificationCenter defaultCenter] addObserver: self 
		selector: @selector(updateItems:)
		name: WebsiteHistoryUpdatedNotificationName
		object: nil];
}
-(void)showWindow: (id)sender {
	[self registerForHistoryNotifications];
	[super showWindow: sender];
}
-(void)awakeFromNib {
	[[self window] makeKeyAndOrderFront: self];
	[self registerForHistoryNotifications];
	[outlineView expandItem: [[historyItems allValues] firstObject] expandChildren: NO];
}

-(BOOL)validateMenuItem: (NSMenuItem*)aMenuItem {
	NSInteger tag = [aMenuItem tag];
	if (tag == TAG_MENU_REMOVE || tag == TAG_MENU_OPEN) {
		return [outlineView numberOfSelectedRows] > 0;
	}
	return YES;
}

-(void)open: (id)sender {
	NSEnumerator *selected = [outlineView selectedRowEnumerator];
	id row, item;
	while ((row = [selected nextObject]) != NULL) {
		item = [outlineView itemAtRow: [row integerValue]];
		if ([item isKindOfClass: [Website class]]) {
			[[NSApp delegate] openWebsite: item];
			break;
		}
	}
}

-(void)copy: (id)sender {
	NSEnumerator *selected = [outlineView selectedRowEnumerator];
	id row, item;
	while ((row = [selected nextObject]) != NULL) {
		item = [outlineView itemAtRow: [row integerValue]];
		if ([item isKindOfClass: [Website class]]) {
			[[NSPasteboard generalPasteboard] setString: [[item url] absoluteString]
				forType: NSStringPboardType];
			break;
		}
	}
}

-(void)remove: (id)sender {
	NSEnumerator *selected = [outlineView selectedRowEnumerator];
	id row, item;
	ignoreRefresh = YES;
	while ((row = [selected nextObject]) != NULL) {
		item = [outlineView itemAtRow: [row integerValue]];
		if ([item isKindOfClass: [Website class]]) {
			[item removeFromHistory];
		}
	}
	ignoreRefresh = NO;
	[self updateItems: nil];
}

-(id)outlineView: (NSOutlineView*)outlineView child: (NSInteger)index ofItem: (id)item {	
	if (item == nil) {
		return [[historyItems allValues] firstObject];
	} else {
		return [item objectAtIndex: index];
	}
}

-(BOOL)outlineView: (NSOutlineView*)outlineView isItemExpandable: (id)item {
	if ([item isKindOfClass: [NSArray class]]) {
		return YES;
	} else {
		return NO;
	}
}

-(NSInteger)outlineView: (NSOutlineView*)outlineView numberOfChildrenOfItem: (id)item {
	if (item == nil) {
		return 1;
	}
	return [item count];
}

-(id)outlineView: (NSOutlineView*)outlineView objectValueForTableColumn: (NSTableColumn*)tableColumn byItem: (id)item {
	if ([item isKindOfClass: [NSArray class]]) {
		return @"Recent History";
	} else if ([item isKindOfClass: [Website class]]) {
		return [item name];
	} else {
		NSLog(@"clas: %@", [item class]);
		return @"Error";
	}
}

-(BOOL)outlineView: (NSOutlineView*)outlineView shouldSelectItem: (id)item {
	NSLog(@"clicked item %@", item);
	return YES;
}

@end