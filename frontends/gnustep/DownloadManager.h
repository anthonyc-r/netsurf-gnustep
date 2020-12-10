#import <Cocoa/Cocoa.h>

@class DownloadManager;
@class DownloadItem;

@protocol DownloadManagerDelegate
-(void)downloadManagerDidAddDownload: (DownloadManager*)aDownloadManager;
@end

@interface DownloadItem: NSObject {
	BOOL completed;
	BOOL cancelled;
	NSInteger size;
	NSInteger written;
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
-(double)completionProgress;
@end

@interface DownloadManager: NSObject {
	NSMutableArray *downloads;
	id<DownloadManagerDelegate> delegate;
}
+(DownloadManager*)defaultDownloadManager;
-(DownloadItem*)createDownloadForDestination: (NSURL*)path withSizeInBytes: (NSInteger)size;
-(NSArray*)downloads;
-(void)setDelegate: (id<DownloadManagerDelegate>)aDelegate;
@end