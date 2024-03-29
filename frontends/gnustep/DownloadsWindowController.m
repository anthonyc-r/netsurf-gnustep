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
#import "DownloadsWindowController.h"
#import "DownloadManager.h"
#import "ProgressBarCell.h"
#import "AppDelegate.h"

@implementation DownloadsWindowController

-(id)init {
	if ((self = [super initWithWindowNibName: @"Downloads"])) {
		//...
	}
	return self;
}

-(void)dealloc {
	if ([[DownloadManager defaultDownloadManager] delegate] == self) {
		[[DownloadManager defaultDownloadManager] setDelegate: nil];
	}
	[super dealloc];
}

-(void)awakeFromNib {
	NSLog(@"Awoke from nib...");
	[[self window] makeKeyAndOrderFront: self];
	[[DownloadManager defaultDownloadManager] setDelegate: self];
}

// MARK: - NSTableViewDataSource

-(NSInteger)numberOfRowsInTableView: (NSTableView*)aTableView {
	return [[[DownloadManager defaultDownloadManager] downloads] count];
}

-(id)tableView: (NSTableView *)aTableView objectValueForTableColumn: (NSTableColumn*)aTableColumn row: (NSInteger)rowIndex {
	DownloadItem *item = [[[DownloadManager defaultDownloadManager] downloads]
		objectAtIndex: rowIndex];
	NSString *identifier = [aTableColumn identifier];
	if ([identifier isEqual: @"progress"]) {
		if ([item isCancelled]) {
			return @"Cancelled";
		} else if ([item isComplete]) {
			return @"Complete";
		} else {
			return [NSNumber numberWithDouble: [item completionProgress]];
		}
	} else if ([identifier isEqual: @"details"]) {
		return [item detailsText];
	} else if ([identifier isEqual: @"remaining"]) {
		return [item remainingText];
	} else if ([identifier isEqual: @"speed"]) {
		return [item speedText];
	} else {
		return nil;
	}
}

-(BOOL)tableView: (NSTableView*)aTableView shouldEditTableColumn: (NSTableColumn*)aTableColumn row: (NSInteger)row {
	return NO;
}

-(void)tableView: (NSTableView*)aTableView willDisplayCell: (id)aCell forTableColumn: (NSTableColumn*)aTableColumn row: (NSUInteger)row {
	BOOL isSelected = [aTableView isRowSelected: row];
	if ([aCell isKindOfClass: [ProgressBarCell class]]) {
		[aCell setHighlighted: isSelected];
	} else {
		[aCell setTextColor: isSelected ? [NSColor whiteColor] : 
			[NSColor blackColor]];
	}
}

// MARK: - DownloadManagerDelegate

-(void)downloadManagerDidAddDownload: (DownloadManager*)aDownloadManager {
	[tableView reloadData];
}

-(void)downloadManager: (DownloadManager*)aDownloadManager didRemoveItems: (NSArray*)downloadItems {
	[tableView reloadData];
}

-(void)downloadManager: (DownloadManager*)aDownloadManager didUpdateItem: (DownloadItem*)aDownloadItem {
	NSIndexSet *rows = [NSIndexSet indexSetWithIndex: [aDownloadItem index]];
	NSIndexSet *columns = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, 4)];
	[tableView reloadDataForRowIndexes: rows columnIndexes: columns];
}

// MARK: - Menu Stuff

-(BOOL)validateMenuItem: (NSMenuItem*)aMenuItem {
	NSInteger tag = [aMenuItem tag];
	if (tag == TAG_MENU_REMOVE || tag == TAG_MENU_CANCEL || tag == TAG_MENU_OPEN) {
		return [tableView numberOfSelectedRows] > 0;
	}
	return YES;
}

-(void)remove: (id)sender {
	id row;
	NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
	NSEnumerator *selectedRows = [tableView selectedRowEnumerator];
	while ((row = [selectedRows nextObject]) != nil) {
		[indices addIndex: [row integerValue]];
	}
	[[DownloadManager defaultDownloadManager] removeDownloadsAtIndexes: indices];
}

-(void)cancel: (id)sender {
	id row;
	NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
	NSEnumerator *selectedRows = [tableView selectedRowEnumerator];
	while ((row = [selectedRows nextObject]) != nil) {
		[indices addIndex: [row integerValue]];
	}
	[[DownloadManager defaultDownloadManager] cancelDownloadsAtIndexes: indices];
}

-(void)open: (id)sender {

	NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
	NSEnumerator *selectedRows = [tableView selectedRowEnumerator];
	id row = [selectedRows nextObject];
	if (row != nil) {
		[[DownloadManager defaultDownloadManager] openDownloadAtIndex: [row integerValue]];
	}
}

@end

