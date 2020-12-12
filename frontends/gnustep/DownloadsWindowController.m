#import <Cocoa/Cocoa.h>
#import "DownloadsWindowController.h"
#import "DownloadManager.h"
#import "ProgressBarCell.h"

@implementation DownloadsWindowController

-(id)init {
	if (self = [super initWithWindowNibName: @"Downloads"]) {
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
		return [NSNumber numberWithDouble: [item completionProgress]];
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

-(void)downloadManager: (DownloadManager*)aDownloadManager didUpdateItem: (DownloadItem*)aDownloadItem {
	NSIndexSet *rows = [NSIndexSet indexSetWithIndex: [aDownloadItem index]];
	NSIndexSet *columns = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, 4)];
	[tableView reloadDataForRowIndexes: rows columnIndexes: columns];
}

@end

