#import <Cocoa/Cocoa.h>
#import "Website.h"
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

-(void)setVisited {
	[lastVisited release];
	lastVisited = [[NSDate alloc] init];
}

+(NSArray*)historicWebsites {
	return [NSArray array];
}

@end