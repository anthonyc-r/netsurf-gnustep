#import <Foundation/Foundation.h>
#import "SearchProvider.h"
#import "Preferences.h"

#define KEY_STARTUP_URL @"startup_url"
#define KEY_SEARCH_FROM_URL_BAR @"search_from_url_bar"
#define KEY_SEARCH_PROVIDER @"search_provider"
#define KEY_REMOVE_DOWNLOADS_COMPLETE @"remove_downloads_complete"
#define KEY_CONFIRM_OVERWRITE @"confirm_overwrite"
#define KEY_DOWNLOAD_LOCATION @"download_location"

@implementation Preferences

-(id)init {
	if ((self = [super init])) {
		defaults = [[NSUserDefaults standardUserDefaults] retain];
	}
	return self;
}

-(void)dealloc {
	[defaults release];
	[super dealloc];
}

-(NSString*)startupUrl {
	NSString *saved = [defaults stringForKey: KEY_STARTUP_URL];
	if (saved != nil) {
		return saved;
	} else {
		return @"https://www.startpage.com";
	}
}
-(void)setStartupUrl: (NSString*)aUrl {
	[defaults setObject: aUrl forKey: KEY_STARTUP_URL];
}

-(BOOL)searchFromUrlBar {
	if ([defaults objectForKey: KEY_SEARCH_FROM_URL_BAR] != nil) {
		return [defaults boolForKey: KEY_SEARCH_FROM_URL_BAR];
	} else {
		return NO;
	}
}
-(void)setSearchFromUrlBar: (BOOL)value {

}

-(SearchProvider*)searchProvider {
	return nil;
}
-(void)setSearchProvider: (SearchProvider*)aProvider {

}

-(BOOL)removeDownloadsOnComplete {
	return NO;
}
-(void)setRemoveDownloadsOnComplete: (BOOL)value {
	
}

-(BOOL)confirmBeforeOverwriting {
	return NO;
}
-(void)setConfirmBeforeOverwriting: (BOOL)value {

}

-(NSString*)downloadLocationPath {
	return nil;
}
-(void)setDownloadLocationPath: (NSString*)aPath {

}
@end