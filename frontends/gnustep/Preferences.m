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
	[defaults setBool: value forKey: KEY_SEARCH_FROM_URL_BAR];
}

-(SearchProvider*)searchProvider {
	NSDictionary *dict = [defaults dictionaryForKey: KEY_SEARCH_PROVIDER];
	SearchProvider *ret;
	if (dict != nil) {
		ret = [[SearchProvider alloc] initWithDictionary: dict];
		[ret autorelease];
	} else {
		ret = [SearchProvider defaultSearchProvider];
	}
	return ret;
}
-(void)setSearchProvider: (SearchProvider*)aProvider {
	[defaults setObject: [aProvider dictionaryRepresentation] forKey: 
		KEY_SEARCH_PROVIDER];
}

-(BOOL)removeDownloadsOnComplete {
	if ([defaults objectForKey: KEY_REMOVE_DOWNLOADS_COMPLETE] != nil) {
		return [defaults boolForKey: KEY_REMOVE_DOWNLOADS_COMPLETE];
	} else {
		return NO;
	}
}
-(void)setRemoveDownloadsOnComplete: (BOOL)value {
	[defaults setBool: value forKey: KEY_REMOVE_DOWNLOADS_COMPLETE];
}

-(BOOL)confirmBeforeOverwriting {
	if ([defaults objectForKey: KEY_CONFIRM_OVERWRITE] != nil) {
		return [defaults boolForKey: KEY_CONFIRM_OVERWRITE];
	} else {
		return YES;
	}
}
-(void)setConfirmBeforeOverwriting: (BOOL)value {
	[defaults setBool: value forKey: KEY_CONFIRM_OVERWRITE];
}

-(NSString*)downloadLocationPath {
	NSString *downloadPath = [defaults stringForKey: KEY_DOWNLOAD_LOCATION];
	if (downloadPath != nil) {
		return downloadPath;
	} else {
		return [@"~/Downloads" stringByExpandingTildeInPath];
	}
}
-(void)setDownloadLocationPath: (NSString*)aPath {
	[defaults setObject: aPath forKey: KEY_DOWNLOAD_LOCATION];
}

+(Preferences*)defaultPreferences {
	static Preferences *prefs;
	if (prefs == nil) {
		prefs = [[Preferences alloc] init];
	}
	return prefs;
}
@end