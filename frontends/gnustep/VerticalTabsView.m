#import <Cocoa/Cocoa.h>
#import "VerticalTabsView.h"

@implementation VerticalTabsView

-(id)initWithTabs: (NSArray*)sometTabs {
	if ((self = [super init])) {
		tableView = [[NSTableView alloc] init];
		[self setDocumentView: tableView];
		tabItems = [sometTabs retain];
		[tableView setDataSource: self];
		[tableView setDelegate: self];
		NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier: @"name"];
		[col setEditable: NO];
		[col setWidth: 100];
		[tableView addTableColumn: col];
		[col release];
		[tableView setHeaderView: nil];
	}
	return self;
}

-(void)dealloc {
	[tableView release];
	[tabItems release];
	[super dealloc];
}

-(void)reloadTabs {
	NSLog(@"Reload data");
	[tableView reloadData];
}

-(void)setSelectedTab: (id<VerticalTabsViewItem>)aTab {
	NSUInteger idx = [tabItems indexOfObject: aTab];
	if (idx != NSNotFound) {
		[tableView selectRowIndexes: [NSIndexSet indexSetWithIndex: idx]
			byExtendingSelection: NO];
	}
}

-(void)setDelegate: (id<VerticalTabsViewDelegate>)aDelegate {
	delegate = aDelegate;
}

-(NSInteger)numberOfRowsInTableView: (NSTableView*)aTableView {
	return [tabItems count];
}

-(id)tableView: (NSTableView*)aTableView objectValueForTableColumn: (NSTableColumn*)aColumn row: (NSInteger)aRow {
	return [[tabItems objectAtIndex: aRow] label];
}

-(void)tableView: (NSTableView*)aTableView setObjectValue: (id)object forTableColumn: (NSTableColumn*)aColumn row: (NSInteger)aRow {

}

-(void)tableViewSelectionDidChange: (NSTableView*)aTableView {
	NSLog(@"Selection changed");
	NSInteger idx = [tableView selectedRow];
	if (idx > -1) {
		[delegate verticalTabsView: self didSelectTab: [tabItems objectAtIndex: idx]];
	}
}

@end
