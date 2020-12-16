#import <Cocoa/Cocoa.h>
#import "DownloadManager.h"

@implementation DownloadItem

-(id)initWithManager: (DownloadManager*)aManager destination: (NSURL*)aDestination size: (NSInteger)aSize index: (NSUInteger)anIndex {
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
	[super dealloc];
}

-(BOOL)appendToDownload: (NSData*)data {
	NSUInteger len = [data length];
	NSUInteger writtenNow = [outputStream write: [data bytes] maxLength: len];
	written += writtenNow;
	// Unless im misunderstanding download_context_get_total_length appears to return
	// a too-small non-zero value for download size when called in 
	// gnustep_download_create...
	size = MAX(written, size);
	[[manager delegate] downloadManager: manager didUpdateItem: self];
	return writtenNow == len;
}

-(void)cancel {
	if (!completed) {
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
	return [NSString stringWithFormat: @"%.2f KiB", kibLeft];
}

-(NSString*)speedText {
	if (completed) {
		return @"-";
	}
	NSTimeInterval secondsPassed = -[startDate timeIntervalSinceNow];
	double kibPerSecond = (double)written / (secondsPassed * 1024.0);
	return [NSString stringWithFormat: @"%.2f KiB/s", kibPerSecond];
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

-(DownloadItem*)createDownloadForDestination: (NSURL*)path withSizeInBytes: (NSUInteger)size {
	DownloadItem *item = [[DownloadItem alloc] initWithManager: self destination: path
		size: size index: [downloads count]];
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

@end