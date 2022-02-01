#import <Cocoa/Cocoa.h>
#import "DownloadManager.h"
#import "desktop/download.h"
#import "Preferences.h"

@interface DownloadItem(Private)
-(void) completeAndNotifyManager;
-(void) notifyManager;
@end

@implementation DownloadItem

-(id)initWithManager: (DownloadManager*)aManager destination: (NSURL*)aDestination size: (NSInteger)aSize index: (NSUInteger)anIndex ctx: (struct download_context*)aCtx {
	if ((self = [super init])) {
		error = nil;
		index = anIndex;
		written = 0;
		confirmedSize = 0;
		confirmedSizeLock = [[NSLock alloc] init];
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
		downloadThread = nil;
		runThread = YES;
		[NSThread detachNewThreadSelector: @selector(runDownloadThread) toTarget:
			self withObject: nil];
	}
	return self;
}

// TODO: - Why isn't this releasing?
-(void)dealloc {
	NSLog(@"DownloadItem dealloc!!");
	runThread = NO;
	[destination release];
	[outputStream close];
	[outputStream release];
	[startDate release];
	[confirmedSizeLock release];
	if (error) {
		[error release];
	}
	download_context_destroy(ctx);
	[super dealloc];
}

-(void)runDownloadThread {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	downloadThread = [NSThread currentThread];
	NSRunLoop *runloop = [NSRunLoop currentRunLoop];
	[runloop addPort: [NSPort port] forMode: NSDefaultRunLoopMode]; 
	while (runThread) {
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		[runloop runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]];
		[pool release];
	}
	[pool release];
}

-(BOOL)appendToDownload: (NSData*)data {
	sizeUntilNow += [data length];
	if (downloadThread == nil) {
		NSLog(@"Error: expected download thread to be initialized");
		return NO;
	}
	[self performSelector: @selector(reallyWriteData:) onThread: downloadThread
		withObject: data waitUntilDone: NO modes: [NSArray arrayWithObject:
		NSDefaultRunLoopMode]];
	return YES;
}

-(void)reallyWriteData: (NSData*)data {
	NSUInteger toWrite = [data length];
	NSInteger thisWrite;
	const uint8_t *start = [data bytes];
	while (toWrite > 0) {
		thisWrite = [outputStream write: start maxLength: toWrite];
		start += thisWrite;
		toWrite -= thisWrite;
	}
	written += [data length];
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

	// Check if we're complete.
	BOOL done;
	[confirmedSizeLock lock];
	done = confirmedSize > 0 && written >= confirmedSize;
	[confirmedSizeLock unlock];
	if (done) {
		[self performSelectorOnMainThread: @selector(completeAndNotifyManager) 
			withObject: nil waitUntilDone: NO];
	}
}
-(void)completeAndNotifyManager {
		completed = YES;
		runThread = NO;
		[outputStream close];
		[[manager delegate] downloadManager: manager didUpdateItem: self];
		if ([[Preferences defaultPreferences] removeDownloadsOnComplete]) {
			[manager removeDownloadsAtIndexes: [NSIndexSet indexSetWithIndex: index]];
		}
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
	NSLog(@"Complete called...");
	// Having set this non-0, our download thread will know to complete.
	[confirmedSizeLock lock];
	confirmedSize = sizeUntilNow;
	[confirmedSizeLock unlock];
	// Trigger a write just to trigger the completion check if there's no data
	// pending write.
	[self appendToDownload: [NSData data]];
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
	if ((self = [super init])) {
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

-(void)openDownloadAtIndex: (NSInteger)anIndex {
	DownloadItem *item = [downloads objectAtIndex: anIndex];
	NSString *path = [[item destination] absoluteString];
	[[NSWorkspace sharedWorkspace] openFile: path];
}

@end