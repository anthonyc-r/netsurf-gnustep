#import <Foundation/Foundation.h>
#import "SearchProvider.h"
#import "Preferences.h"

#define KEY_STARTUP_URL @"startup_url"
#define KEY_SEARCH_FROM_URL_BAR @"search_from_url_bar"
#define KEY_SEARCH_PROVIDER @"search_provider"
#define KEY_REMOVE_DOWNLOADS_COMPLETE @"remove_downloads_complete"
#define KEY_CONFIRM_OVERWRITE @"confirm_overwrite"
#define KEY_DOWNLOAD_LOCATION @"download_location"
#define KEY_SWITCH_TAB_IMMEDIATELY @"switch_tab_immediately"
#define KEY_BLANK_NEW_TABS @"blank_new_tabs"
#define KEY_ALWAYS_SHOW_TABS @"always_show_tabs"
#define KEY_TAB_LOCATION @"tab_location"
#define KEY_DEVELOPER_VIEW_LOCATION @"developer_view_location"

@interface Preferences (Private) 

-(void)notifyPreferenceUpdated: (PreferenceType)type;

@end

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

-(BOOL)alwaysShowTabs {
	if ([defaults objectForKey: KEY_ALWAYS_SHOW_TABS] != nil) {
		return [defaults boolForKey: KEY_ALWAYS_SHOW_TABS];
	} else {
		return NO;
	}
}

-(void)setAlwaysShowTabs: (BOOL)value {
	[defaults setBool: value forKey: KEY_ALWAYS_SHOW_TABS];
	[self notifyPreferenceUpdated: PreferenceTypeAlwaysShowTabs];
}

-(BOOL)switchTabImmediately {
	if ([defaults objectForKey: KEY_SWITCH_TAB_IMMEDIATELY] != nil) {
		return [defaults boolForKey: KEY_SWITCH_TAB_IMMEDIATELY];
	} else {
		return NO;
	}
}

-(void)setSwitchTabImmediately: (BOOL)value {
	[defaults setBool: value forKey: KEY_SWITCH_TAB_IMMEDIATELY];
}

-(BOOL)blankNewTabs {
	if ([defaults objectForKey: KEY_BLANK_NEW_TABS] != nil) {
		return [defaults boolForKey: KEY_BLANK_NEW_TABS];
	} else {
		return NO;
	}
}


-(void)setBlankNewTabs: (BOOL)value {
	[defaults setBool: value forKey: KEY_BLANK_NEW_TABS];
}

-(TabLocation)tabLocation {
	if ([defaults objectForKey: KEY_TAB_LOCATION] != nil) {
		return (TabLocation)[defaults integerForKey: KEY_TAB_LOCATION];
	} else {
		return TabLocationTop;
	}
}

-(void)setTabLocation: (TabLocation)value {
	[defaults setInteger: (NSInteger)value forKey: KEY_TAB_LOCATION];
	[self notifyPreferenceUpdated: PreferenceTypeTabLocation];
}

-(ViewLocation)developerViewLocation {
	if ([defaults objectForKey: KEY_DEVELOPER_VIEW_LOCATION] != nil) {
		return (ViewLocation)[defaults integerForKey:
			KEY_DEVELOPER_VIEW_LOCATION];
	} else {
		return ViewLocationWindow;
	}
}

-(void)setDeveloperViewLocation: (ViewLocation)value {
	[defaults setInteger: (NSInteger)value forKey:
		KEY_DEVELOPER_VIEW_LOCATION];
}

+(Preferences*)defaultPreferences {
	static Preferences *prefs;
	if (prefs == nil) {
		prefs = [[Preferences alloc] init];
	}
	return prefs;
}

-(void)notifyPreferenceUpdated: (PreferenceType)type {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInteger: type], @"type",
		nil
	];
	[[NSNotificationCenter defaultCenter] postNotificationName:
		PreferencesUpdatedNotificationName object: dict];
}
@end
