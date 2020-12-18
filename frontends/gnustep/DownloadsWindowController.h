#import <Cocoa/Cocoa.h>
#import "DownloadManager.h"


@interface DownloadsWindowController: NSWindowController<NSTableViewDataSource, DownloadManagerDelegate> {
	id tableView;
}

-(void)remove: (id)sender;
-(void)cancel: (id)sender;

@end

