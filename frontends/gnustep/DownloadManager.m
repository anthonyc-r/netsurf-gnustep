#import <Cocoa/Cocoa.h>
#import "DownloadManager.h"

@implementation DownloadItem

-(id)initWithManager: (DownloadManager*)aManager destination: (NSURL*)aDestination size: (NSInteger)aSize {
	if (self = [super init]) {
		error = nil;
		written = 0;
		completed = NO;
		size = aSize;
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
	if (error) {
		[error release];
	}
	[super dealloc];
}

-(BOOL)appendToDownload: (NSData*)data {
	NSInteger len = [data length];
	NSInteger writtenNow = [outputStream write: [data bytes] maxLength: len];
	written += writtenNow;
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
}

-(BOOL)isComplete {
	return completed;
}


-(NSURL*)destination {
	return destination;
}

-(double)percentCompletion {
	if (written == size) {
		return 1.0;
	} else {
		return (double)written / size;
	}
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
	}
	return self;
}

-(void)dealloc {
	[downloads release];
	[super dealloc];
}

-(DownloadItem*)createDownloadForDestination: (NSURL*)path withSizeInBytes: (NSInteger)size {
	DownloadItem *item = [[DownloadItem alloc] initWithManager: self destination: path
		size: size];
	[downloads addObject: item];	
	[item release];
	return item;
}

-(NSArray*)downloads {
	return downloads;
}

@end