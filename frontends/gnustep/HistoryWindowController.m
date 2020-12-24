#import <Cocoa/Cocoa.h>
#import "HistoryWindowController.h"
#import "Website.h"

@implementation HistoryWindowController

-(id)init {
	if (self = [super initWithWindowNibName: @"History"]) {
		NSArray *allHistory = [Website historicWebsites];
		
		historyItems = [[NSMutableDictionary alloc] init];
		[historyItems setObject: allHistory forKey: @"recent"];
	}
	return self;
}

-(void)dealloc {
	[historyItems release];
	[super dealloc];
}


-(void)awakeFromNib {
	NSLog(@"Awoke from nib...");
	[[self window] makeKeyAndOrderFront: self];
	[outlineView expandItem: [[historyItems allValues] firstObject] expandChildren: NO];
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