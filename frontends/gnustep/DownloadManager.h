#import <Cocoa/Cocoa.h>

@class DownloadManager;
@class DownloadItem;

@protocol DownloadManagerDelegate
-(void)downloadManagerDidAddDownload: (DownloadManager*)aDownloadManager;
-(void)downloadManager: (DownloadManager*)aDownloadManager didUpdateItem: (DownloadItem*)aDownloadItem;
@end

@interface DownloadItem: NSObject {
	BOOL completed;
	BOOL cancelled;
	NSUInteger size;
	NSUInteger written;
	NSInteger index;
	NSDate *startDate;
	NSURL *destination;
	NSOutputStream *outputStream;
	NSString *error;
	DownloadManager *manager;
}
-(BOOL)appendToDownload: (NSData*)data;
-(void)cancel;
-(void)complete;
-(BOOL)isComplete;
-(void)failWithMessage: (NSString*)message;
-(NSURL*)destination;
-(NSString*)detailsText;
-(NSString*)remainingText;
-(NSString*)speedText;
-(double)completionProgress;
-(NSInteger)index;
@end

@interface DownloadManager: NSObject {
	NSMutableArray *downloads;
	id<DownloadManagerDelegate> delegate;
}
+(DownloadManager*)defaultDownloadManager;
-(DownloadItem*)createDownloadForDestination: (NSURL*)path withSizeInBytes: (NSUInteger)size;
-(NSArray*)downloads;
-(id)delegate;
-(void)setDelegate: (id<DownloadManagerDelegate>)aDelegate;
@end