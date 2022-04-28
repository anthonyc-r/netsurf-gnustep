/*
 * Copyright 2022 Anthony Cohn-Richardby <anthonyc@gmx.co.uk>
 *
 * This file is part of NetSurf, http://www.netsurf-browser.org/
 *
 * NetSurf is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 * NetSurf is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
