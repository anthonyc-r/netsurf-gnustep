#import <Cocoa/Cocoa.h>

#import "HistoryWindowController.h"
#import "Website.h"
#import "AppDelegate.h"
#import "desktop/global_history.h"

@interface Section: NSObject {
	NSString *name;
	NSArray *items;
}
@end
@implementation Section
+(id)sectionWithName: (NSString*)aName items: (NSArray*)someItems {
	Section *section = [[[Section alloc] init] autorelease];
	section->name = [aName retain];
	section->items = [someItems retain];
	return section;
}
-(NSString*)name {
	return name;
}
-(NSArray*)items {
	return items;
}
-(void)setItems: (NSArray*)someItems {
	[items release];
	items = [someItems retain];
}
-(void)dealloc {
	[name release];
	[items release];
	[super dealloc];
}
@end

@implementation HistoryWindowController

-(id)init {
	if (self = [super initWithWindowNibName: @"History"]) {
		ignoreRefresh = NO;
		sections = [[NSArray arrayWithObjects: [Section sectionWithName: @"Recent" 
				items: [NSArray array]], [Section sectionWithName: 
				@"More than 2 months ago..." items: [NSArray array]], nil]
				retain];
		[self updateItems: nil];
	}
	return self;
}

-(void)dealloc {
	[sections release];
	[super dealloc];
}


-(void)updateItems: (NSNotification*)aNotification {
	if (!ignoreRefresh) {
		[[sections objectAtIndex: 0] setItems: [NSArray array]];
		[[sections objectAtIndex: 1] setItems: [NSArray array]];
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
	[outlineView expandItem: [sections firstObject] expandChildren: NO];
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
		return [sections objectAtIndex: index];
	} else {
		return [[item items] objectAtIndex: index];
	}
}

-(BOOL)outlineView: (NSOutlineView*)outlineView isItemExpandable: (id)item {
	if ([item isKindOfClass: [Section class]]) {
		return YES;
	} else {
		return NO;
	}
}

-(NSInteger)outlineView: (NSOutlineView*)outlineView numberOfChildrenOfItem: (id)item {
	if (item == nil) {
		return [sections count];
	} else if ([item isKindOfClass: [Section class]]) {
		return [[item items] count];
	} else {
		return 0;
	}
}

-(id)outlineView: (NSOutlineView*)outlineView objectValueForTableColumn: (NSTableColumn*)tableColumn byItem: (id)item {
	return [item name];
}

-(BOOL)outlineView: (NSOutlineView*)outlineView shouldSelectItem: (id)item {
	NSLog(@"clicked item %@", item);
	return YES;
}

@end