#import <Foundation/Foundation.h>
#import "Website.h"
#import "SearchProvider.h"
#import "stdio.h"
#import "string.h"

@interface SearchProvider (Private)
-(BOOL)isUrl: (NSString*)possibleUrlString;
@end

@implementation SearchProvider

-(id)initWithName: (NSString*)aName searchUrl: (NSString*)aSearchUrl {
	if ((self = [super init])) {
		name = [aName retain];
		searchUrl = [aSearchUrl retain];
	}
	return self;
}

-(id)initWithDictionary: (NSDictionary*)aDictionary {
	if ((self = [super init])) {
		name = [[aDictionary objectForKey: @"name"] retain];
		searchUrl = [[aDictionary objectForKey: @"searchUrl"] retain];
	}
	return self;
}

-(void)dealloc {
	[name release];
	[searchUrl release];
	[super dealloc];
}

-(NSString*)name {
	return name;
}

-(Website*)websiteForQuery: (NSString*)queryString {
	if ([self isUrl: queryString]) {
		return [[[Website alloc] initWithName: @"" url: queryString] autorelease];
	} else {
		NSString *url = [searchUrl stringByReplacingOccurrencesOfString: @"%s" withString:
			[queryString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
		return [[[Website alloc] initWithName: name url: url] autorelease];
	}
}

-(NSDictionary*)dictionaryRepresentation {
	return [NSDictionary dictionaryWithObjectsAndKeys: name, @"name", searchUrl,
		@"searchUrl", nil];
}

+(NSArray*)allProviders {
	NSMutableArray *result = [NSMutableArray arrayWithObject: [SearchProvider 
		defaultSearchProvider]];
	// Attempt to parse SearchEngines file found in netsurf/resources
	NSString *path = [[NSBundle mainBundle] pathForResource: @"SearchEngines" ofType: @""];
	if (path == nil) {
		NSLog(@"SearchEngines file not found in main bundle.");
		return result;
	}
	FILE *f = fopen([path cString], "r");
	if (f == NULL) {
		NSLog(@"Failed to fopen SearchEngines");
		return result;
	}
	char buf[300];
	char *name, *format;
	SearchProvider *provider;
	while (fgets(buf, 300, f) != NULL) {
		name =  strtok(buf, "|");
		(void)strtok(NULL, "|");
		format = strtok(NULL, "|");
		if (name != NULL && format != NULL) {
			provider = [[SearchProvider alloc] initWithName: [NSString stringWithCString: 
					name] searchUrl: [NSString stringWithCString: format]];
			[result addObject: provider];
			[provider release];
		}
	}
	return result;
}

+(SearchProvider*)defaultSearchProvider {
	return [[[SearchProvider alloc] initWithName: @"StartPage" 
		searchUrl: @"https://www.startpage.com/do/dsearch?query=%s"] autorelease];
}

-(BOOL)isUrl: (NSString*)possibleUrlString {
	BOOL startsWithProtocol = [possibleUrlString hasPrefix: @"http://"] ||
		[possibleUrlString hasPrefix: @"https://"] ||
		[possibleUrlString hasPrefix: @"///"];
	if (startsWithProtocol)
		return YES;

	NSError *err = nil;
	NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:
		@"([a-zA-Z0-9]+\\.)*[a-zA-Z0-9]+\\.[a-zA-Z]+(/.+)?" options: 0 error: &err];
	if (err != nil) {
		NSLog(@"Error creating regexp");
		return YES;
	}
	NSUInteger matches = [regexp numberOfMatchesInString: possibleUrlString options: 0 range:
		NSMakeRange(0, [possibleUrlString length])];
	return matches > 0;
}

@end