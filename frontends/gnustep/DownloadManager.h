#import <Cocoa/Cocoa.h>

@class DownloadManager;
@class DownloadItem;
struct download_context;

@protocol DownloadManagerDelegate
-(void)downloadManagerDidAddDownload: (DownloadManager*)aDownloadManager;
-(void)downloadManager: (DownloadManager*)aDownloadManager didRemoveItems: (NSArray*)downloadItems;
-(void)downloadManager: (DownloadManager*)aDownloadManager didUpdateItem: (DownloadItem*)aDownloadItem;
@end

@interface DownloadItem: NSObject {
	BOOL completed;
	BOOL cancelled;
	NSUInteger size;
	NSUInteger confirmedSize, sizeUntilNow;
	NSLock *confirmedSizeLock;
	NSUInteger written;
	NSInteger index;
	NSDate *startDate;
	NSURL *destination;
	NSOutputStream *outputStream;
	NSString *error;
	BOOL runThread;
	NSThread *downloadThread;
	DownloadManager *manager;
	NSTimeInterval lastWrite;
	struct download_context *ctx;
}
-(BOOL)appendToDownload: (NSData*)data;
-(void)cancel;
-(void)complete;
-(BOOL)isComplete;
-(BOOL)isCancelled;
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
-(DownloadItem*)createDownloadForDestination: (NSURL*)path withContext: (struct download_context*)ctx;
-(NSArray*)downloads;
-(void)removeDownloadsAtIndexes: (NSIndexSet*)anIndexSet;
-(void)cancelDownloadsAtIndexes: (NSIndexSet*)anIndexSet;
-(void)openDownloadAtIndex: (NSInteger)index;
-(id)delegate;
-(void)setDelegate: (id<DownloadManagerDelegate>)aDelegate;
@end