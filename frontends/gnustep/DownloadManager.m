#import <Cocoa/Cocoa.h>
#import "DownloadManager.h"
#import "desktop/download.h"

// TODO: - Verify behavior of performOnBackgroundThread on a multiprocessor system!!

@implementation DownloadItem

-(id)initWithManager: (DownloadManager*)aManager destination: (NSURL*)aDestination size: (NSInteger)aSize index: (NSUInteger)anIndex ctx: (struct download_context*)aCtx {
	if (self = [super init]) {
		error = nil;
		index = anIndex;
		written = 0;
		completed = NO;
		size = aSize;
		startDate = [[NSDate date] retain];
		[aDestination retain];
		destination = aDestination;
		manager = aManager;
		outputStream = [NSOutputStream outputStreamToFileAtPath: [destination path]
			append: NO];
		[outputStream retain];
		[outputStream open];
		ctx = aCtx;
	}
	return self;
}

-(void)dealloc {
	[destination release];
	[outputStream close];
	[outputStream release];
	[startDate release];
	if (error) {
		[error release];
	}
	download_context_destroy(ctx);
	[super dealloc];
}

-(BOOL)appendToDownload: (NSData*)data {
	// NOTE: - Not sure if this really works on mp systems...
	// Does this get queued sequentially? If not need to upkeep our own thread...
	[self performSelectorInBackground: @selector(reallyWriteData:) withObject: data];
	return YES;
}

-(void)reallyWriteData: (NSData*)data {
	NSUInteger len = [data length];
	NSUInteger writtenNow = [outputStream write: [data bytes] maxLength: len];
	written += writtenNow;
	// Unless im misunderstanding download_context_get_total_length appears to return
	// a too-small non-zero value for download size when called so...
	size = MAX(written, size);
	NSTimeInterval time = [startDate timeIntervalSinceNow];
	// Only notify the manager at most once in each second.
	if ((int)time != (int)lastWrite) {
		[self performSelectorOnMainThread: @selector(notifyManager) withObject: nil
			waitUntilDone: NO];
	}
	lastWrite = time;
}
-(void)notifyManager {
	[[manager delegate] downloadManager: manager didUpdateItem: self];
}

-(void)cancel {
	NSLog(@"cancel!!");
	if (!completed) {
		cancelled = YES;
		download_context_abort(ctx);
		[self complete];
	}
}

-(void)failWithMessage: (NSString*)message {
	if (!completed) {
		[message retain];
		error = message;
		[self complete];
	}
}

-(void)complete {
	[outputStream close];
	completed = YES;
	[[manager delegate] downloadManager: manager didUpdateItem: self];
}

-(BOOL)isComplete {
	return completed;
}

-(BOOL)isCancelled {
	return cancelled;
}

-(NSURL*)destination {
	return destination;
}

-(NSString*)detailsText {
	return [[destination pathComponents] lastObject];
}

-(NSString*)remainingText {
	if (completed) {
		return @"-";
	}
	NSUInteger bytesLeft = size - written;
	double kibLeft = (double)bytesLeft / 1024.0;
	if (kibLeft < 1024.0) {
		return [NSString stringWithFormat: @"%.2f KiB", kibLeft];
	} else {
		double mibLeft = (double)kibLeft / 1024.0;
		return [NSString stringWithFormat: @"%.2f MiB", mibLeft];
	}
}

-(NSString*)speedText {
	if (completed) {
		return @"-";
	}
	NSTimeInterval secondsPassed = -[startDate timeIntervalSinceNow];
	double kibPerSecond = (double)written / (secondsPassed * 1024.0);
	if (kibPerSecond < 1024.0) {
		return [NSString stringWithFormat: @"%.2f KiB/s", kibPerSecond];
	} else {
		double mibPerSecond = kibPerSecond / 1024.0;
		return [NSString stringWithFormat: @"%.2f MiB/s", mibPerSecond];
	}
}

-(double)completionProgress {
	if (written == size) {
		return 1.0;
	} else {
		NSLog(@"prog: %f", (double)written / size);
		return (double)written / size;
	}
}

-(NSInteger)index {
	return index;
}

-(id)copyWithZone: (NSZone*)zone {
	DownloadItem *item = [[DownloadItem alloc] init];
	item->completed = completed;
	item->cancelled = cancelled;
	item->size = size;
	item->written = written;
	item->index = index;
	item->startDate = [startDate retain];
	item->destination = [destination retain];
	item->outputStream = [outputStream retain];
	item->error = [error retain];
	item->manager = manager;
	return item;
}

@end

@implementation DownloadManager

+(DownloadManager*)defaultDownloadManager {
	static DownloadManager *manager;
	if (!manager) {
		manager = [[DownloadManager alloc] init];
	}
	return manager;
}

-(id)init {
	if (self = [super init]) {
		downloads = [[NSMutableArray alloc] init];
		delegate = nil;
	}
	return self;
}

-(void)dealloc {
	[downloads release];
	[super dealloc];
}

-(DownloadItem*)createDownloadForDestination: (NSURL*)path withContext: (struct download_context*)ctx {
	// TODO: - dataSize is smaller than the actual size in some cases. Why?
	NSUInteger dataSize = download_context_get_total_length(ctx);
	DownloadItem *item = [[DownloadItem alloc] initWithManager: self destination: path
		size: dataSize index: [downloads count] ctx: ctx];
	[downloads addObject: item];	
	[item release];
	[delegate downloadManagerDidAddDownload: self];
	return item;
}

-(NSArray*)downloads {
	return downloads;
}

-(void)setDelegate: (id<DownloadManagerDelegate>)aDelegate {
	delegate = aDelegate;
}

-(id)delegate {
	return delegate;
}

-(void)removeDownloadsAtIndexes: (NSIndexSet*)anIndexSet {
	NSUInteger dlCount = [downloads count];
	if ([anIndexSet indexGreaterThanOrEqualToIndex: dlCount] == NSNotFound) {
		NSArray *items = [downloads objectsAtIndexes: anIndexSet];
		[downloads removeObjectsAtIndexes: anIndexSet];
		[delegate downloadManager: self didRemoveItems: items];
	}
}


-(void)cancelDownloadsAtIndexes: (NSIndexSet*)anIndexSet {
	NSArray *items = [downloads objectsAtIndexes: anIndexSet];
	[items makeObjectsPerformSelector: @selector(cancel)];
}

@end