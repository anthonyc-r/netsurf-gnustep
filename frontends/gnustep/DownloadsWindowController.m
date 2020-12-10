#import <Cocoa/Cocoa.h>
#import "DownloadsWindowController.h"
#import "DownloadManager.h"

@implementation DownloadsWindowController

-(id)init {
	if (self = [super initWithWindowNibName: @"Downloads"]) {
		//...
	}
	return self;
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
	if (item == nil) {
		return @"Error";
	}
	NSString *identifier = [aTableColumn identifier];
	if ([identifier isEqual: @"filename"]) {
		return [[item destination] path];
	} else {
		return [NSNumber numberWithDouble: [item completionProgress]];
	}
}

// MARK: - DownloadManagerDelegate

-(void)downloadManagerDidAddDownload: (DownloadManager*)aDownloadManager {
	[tableView reloadData];
}

@end

