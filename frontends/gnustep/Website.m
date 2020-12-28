#import <Cocoa/Cocoa.h>
#import "Website.h"

#define HISTORY_PATH @".cache/NetSurf"

static NSMutableArray *history;

@implementation Website

-(id)initWithName: (NSString*)aName url: (NSURL*)aUrl {
	if (self = [super init]) {
		[aName retain];
		[aUrl retain];
		name = aName;
		url = aUrl;
		lastVisited = nil;
	}
	return self;
}

-(void)dealloc {
	[name release];
	[url release];
	[lastVisited release];
	[super dealloc];
}

-(NSString*)name {
	return name;
}

-(NSURL*)url {
	return url;
}

// MARK: - History implementation

+(id)websiteWithDictionary: (NSDictionary*)dictionary {
	Website *ret = [[[Website alloc] init] autorelease];
	if (ret != nil) {
		ret->name = [dictionary objectForKey: @"name"];
		[ret->name retain];
		ret->url = [NSURL URLWithString: [dictionary objectForKey: @"url"]];
		[ret->url retain];
		ret->lastVisited = [NSDate dateWithTimeIntervalSince1970: [[dictionary 
			objectForKey: @"date"] doubleValue]];
		[ret->lastVisited retain];
	}
	return ret;
}

-(NSDictionary*)toDictionary {
	return [NSDictionary dictionaryWithObjectsAndKeys: name, @"name", 
		[url absoluteString], @"url", 
		[NSNumber numberWithDouble: [lastVisited timeIntervalSince1970]], @"date",
		nil];
}

+(void)saveHistoryToDisk {
	NSLog(@"Save history to disk");
	if (history == nil) {
		return;
	}
	NSError *error = nil;
	NSDictionary *attrs = [NSDictionary dictionary];
	BOOL ok = [[NSFileManager defaultManager] createDirectoryAtPath: [NSString
		pathWithComponents: [NSArray arrayWithObjects: NSHomeDirectory(),
		HISTORY_PATH, nil]] withIntermediateDirectories: YES attributes: attrs 
		error: &error];
	if (!ok) {
		NSLog(@"Error creating cache dir!");
	}
	NSMutableArray *toSave = [NSMutableArray array];
	for (NSUInteger i = 0; i < [history count]; i++) {
		[toSave addObject: [[history objectAtIndex: i] toDictionary]];
	}
	ok = [toSave writeToFile: [NSString pathWithComponents: [NSArray 
		arrayWithObjects: NSHomeDirectory(), HISTORY_PATH, @"history", nil]] 
		atomically: YES];
	if (!ok) {
		NSLog(@"Failed to save latest history to file");
	}
}

+(void)initHistoryIfNeeded {
	if (history == nil) {
		NSArray *historyDicts = [NSMutableArray arrayWithContentsOfFile: 
			[NSString pathWithComponents: [NSArray arrayWithObjects:
			NSHomeDirectory(), HISTORY_PATH, @"history", nil]]];
		history = [[NSMutableArray alloc] init];
		for (NSUInteger i = 0; i < [historyDicts count]; i++) {
			[history addObject: [Website websiteWithDictionary: [historyDicts
				objectAtIndex: i]]];
		}
		[[NSNotificationCenter defaultCenter] addObserver: [self class] 
			selector: @selector(saveHistoryToDisk)
			name: NSApplicationWillTerminateNotification
			object: nil];
	}
}

-(void)removeFromHistory {
	NSLog(@"remove self from history");
	[history removeObject: self];
	[[NSNotificationCenter defaultCenter] postNotificationName:
		HISTORY_UPDATED_NOTIFICATION object: nil];
}

-(void)addToHistory {
	[Website initHistoryIfNeeded];
	[lastVisited release];
	lastVisited = [[NSDate alloc] init];
	[history insertObject: self atIndex: 0];
	NSLog(@"Added %@ , %@ to history!", [self name], [self url]);
	[[NSNotificationCenter defaultCenter] postNotificationName:
		HISTORY_UPDATED_NOTIFICATION object: nil];
}

+(NSArray*)historicWebsites {
	[Website initHistoryIfNeeded];
	return history;
}

@end