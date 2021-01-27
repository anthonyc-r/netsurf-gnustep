#import <Foundation/Foundation.h>
#import "Website.h"
#import "SearchProvider.h"

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
	NSString *url = [searchUrl stringByReplacingOccurrencesOfString: @"%s" withString:
		[queryString stringByAddingPercentEscapesUsingEncoding: 
		NSUTF8StringEncoding]];
	return [[[Website alloc] initWithName: name url: url] autorelease];
}

-(NSDictionary*)dictionaryRepresentation {
	return [NSDictionary dictionaryWithObjectsAndKeys: name, @"name", searchUrl,
		@"searchUrl", nil];
}

+(NSArray*)allProviders {
	return [NSArray arrayWithObject: [SearchProvider defaultSearchProvider]];
}

+(SearchProvider*)defaultSearchProvider {
	return [[[SearchProvider alloc] initWithName: @"StartPage" 
		searchUrl: @"https://www.startpage.com/do/dsearch?query=%s"] autorelease];
}

@end