#import <Foundation/Foundation.h>
#import "Website.h"

@interface SearchProvider: NSObject {
	NSString *name;
	NSString *searchUrl;
}

-(id)initWithName: (NSString*)aName searchUrl: (NSString*)aSearchUrl;
-(id)initWithDictionary: (NSDictionary*)aDictionary;

-(Website*)websiteForQuery: (NSString*)queryString;
-(NSDictionary*)dictionaryRepresentation;

+(NSArray*)allProviders;
+(SearchProvider*)defaultSearchProvider;

@end