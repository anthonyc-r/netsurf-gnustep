#import <Cocoa/Cocoa.h>
#import "DownloadManager.h"

@interface DownloadsWindowController: NSWindowController<NSTableViewDataSource, DownloadManagerDelegate> {
	id tableView;
}

@end

