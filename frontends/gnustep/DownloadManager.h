#import <Cocoa/Cocoa.h>

@class DownloadManager;

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
-(double)percentCompletion;
@end

@interface DownloadManager: NSObject {
	NSMutableArray *downloads;
}
+(DownloadManager*)defaultDownloadManager;
-(DownloadItem*)createDownloadForDestination: (NSURL*)path withSizeInBytes: (NSInteger)size;
-(NSArray*)downloads;
@end