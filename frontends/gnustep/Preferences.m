/*
 * Copyright 2022 Anthony Cohn-Richardby <anthonyc@gmx.co.uk>
 *
 * This file is part of NetSurf, http://www.netsurf-browser.org/
 *
 * NetSurf is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 * NetSurf is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
#import <Foundation/Foundation.h>
#import <stdbool.h>
#import "utils/nsoption.h"
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
#define KEY_SHOW_URL_SUGGESTIONS @"show_url_suggestions"
#define KEY_URL_BAR_BUTTON_TYPE @"url_bar_button_type"
#define KEY_SHOW_HISTORY_TOOLTIP @"show_history_tooltip"
#define KEY_BROWSING_HISTORY_DAYS @"browsing_history_days"


@interface Preferences (Private) 

-(void)notifyPreferenceUpdated: (PreferenceType)type;
-(void)saveNetsurfPrefsFile;
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

-(BOOL)showUrlSuggestions {
	if ([defaults objectForKey: KEY_SHOW_URL_SUGGESTIONS] != nil) {
		return [defaults boolForKey: KEY_SHOW_URL_SUGGESTIONS];
	} else {
		return false;
	}
}

-(void)setShowUrlSuggestions: (BOOL)value {
	[defaults setBool: value forKey: KEY_SHOW_URL_SUGGESTIONS];
	[self notifyPreferenceUpdated: PreferenceTypeShowUrlSuggestions];
}

-(UrlBarButtonType)urlBarButtonType {
	if ([defaults objectForKey: KEY_URL_BAR_BUTTON_TYPE] != nil) {
		return (UrlBarButtonType)[defaults integerForKey:
			KEY_URL_BAR_BUTTON_TYPE];
	} else {
		return UrlBarButtonTypeText;
	}
}

-(void)setUrlBarButtonType: (UrlBarButtonType)buttonType {
	[defaults setInteger: (NSInteger)buttonType forKey: 
		KEY_URL_BAR_BUTTON_TYPE];
	[self notifyPreferenceUpdated: PreferenceTypeUrlBarButtonType];
}

-(LoadImages)loadImages {
	bool loadForeground = nsoption_bool(foreground_images);
	bool loadBackground = nsoption_bool(background_images);
	if (loadForeground && loadBackground) {
		return LoadImagesAll;
	} else if (loadForeground) {
		return LoadImagesForeground;
	} else if (loadBackground) {
		return LoadImagesBackground;
	} else {
		NSLog(@"none");
		return LoadImagesNone;
	}
}

-(void)setLoadImages: (LoadImages)loadImages {
	switch (loadImages) {
	case LoadImagesAll:
		nsoption_set_bool(foreground_images, true);
		nsoption_set_bool(background_images, true);
		break;
	case LoadImagesForeground:
		nsoption_set_bool(foreground_images, true);
		nsoption_set_bool(background_images, false);
		break;
	case LoadImagesBackground:
		nsoption_set_bool(foreground_images, false);
		nsoption_set_bool(background_images, true);
		break;
	default:
		nsoption_set_bool(foreground_images, false);
		nsoption_set_bool(background_images, false);
		break;
	}
	[self saveNetsurfPrefsFile];
}

-(BOOL)disablePopups {
	// return (BOOL)nsoption_bool(disable_popups);
	return NO;
}

-(void)setDisablePopups: (BOOL)value {
	// nsoption_set_bool(disable_popups, (bool)value);
	[self saveNetsurfPrefsFile];
}

-(BOOL)hideAds {
	return (BOOL)nsoption_bool(block_advertisements);
}

-(void)setHideAds: (BOOL)value {
	nsoption_set_bool(block_advertisements, (bool)value);
	[self saveNetsurfPrefsFile];
}

-(BOOL)enableJavascript {
	return (BOOL)nsoption_bool(enable_javascript);
}

-(void)setEnableJavascript: (BOOL)value {
	nsoption_set_bool(enable_javascript, (bool)value);
	[self saveNetsurfPrefsFile];
}


-(BOOL)enableAnimation {
	return (BOOL)nsoption_bool(animate_images);
}

-(void)setEnableAnimation: (BOOL)value {
	nsoption_set_bool(animate_images, (bool)value);
	[self saveNetsurfPrefsFile];
}

-(FontType)defaultFont {
	return (FontType)nsoption_int(font_default);
}

-(void)setDefaultFont: (FontType)value {
	nsoption_set_int(font_default, (NSInteger)value);
	[self saveNetsurfPrefsFile];
}

-(NSString*)preferredLanguage {
	char *lang = nsoption_charp(accept_language);
	if (lang == NULL) {
		return @"en";
	} else {
		return [NSString stringWithCString: lang];	
	}
}

-(void)setPreferredLanguage: (NSString*)value {
	NSLog(@"Set to %@", value);
	nsoption_set_charp(accept_language, strdup([value cString]));
	[self saveNetsurfPrefsFile];
}

-(NSUInteger)fontSize {
	return (NSUInteger)nsoption_int(font_size);
}

-(void)setFontSize: (NSUInteger)value {
	nsoption_set_int(font_size, (int)value);
	[self saveNetsurfPrefsFile];
}


-(BOOL)enableReferralSubmission {
	return (BOOL)nsoption_bool(send_referer);
}
-(void)setEnableReferralSubmission: (BOOL)value {
	nsoption_set_bool(send_referer, (bool)value);
	[self saveNetsurfPrefsFile];
}

-(BOOL)sendDoNotTrackRequest {
	return (BOOL)nsoption_bool(do_not_track);
}
-(void)setSendDoNotTrackRequest: (BOOL)value {
	nsoption_set_bool(do_not_track, (bool)value);
	[self saveNetsurfPrefsFile];
}

-(BOOL)showHistoryTooltip {
	if ([defaults objectForKey: KEY_SHOW_HISTORY_TOOLTIP] != nil) {
		return [defaults boolForKey: KEY_SHOW_HISTORY_TOOLTIP];
	} else {
		return NO;
	}
}
-(void)setShowHistoryTooltip: (BOOL)value {
	[defaults setBool: value forKey: KEY_SHOW_HISTORY_TOOLTIP];
}

-(NSUInteger)browsingHistoryDays {
	return [defaults integerForKey: KEY_BROWSING_HISTORY_DAYS];
}
-(void)setBrowsingHistoryDays: (NSUInteger)value {
	[defaults setInteger: value forKey: KEY_BROWSING_HISTORY_DAYS];
}

-(NSUInteger)diskCacheSize {
	NSUInteger bytes = (NSUInteger)nsoption_int(disc_cache_size);
	return bytes / 0x100000;
}
-(void)setDiskCacheSize: (NSUInteger)value {
	nsoption_set_int(disc_cache_size, (int)(value * 0x100000));
	[self saveNetsurfPrefsFile];
}

-(NSUInteger)memCacheSize {
	NSUInteger bytes = (NSUInteger)nsoption_int(memory_cache_size);
	return bytes / 0x100000;
}
-(void)setMemCacheSize: (NSUInteger)value {
	nsoption_set_int(memory_cache_size, (int)(value * 0x100000));
	[self saveNetsurfPrefsFile];
}

-(NSUInteger)cacheExpiryDays {
	return (NSUInteger)nsoption_int(disc_cache_age);
}
-(void)setCacheExpiryDays: (NSUInteger)value {
	nsoption_set_int(disc_cache_age, (int)value);
	[self saveNetsurfPrefsFile];
}

-(ProxyType)proxyType {
	if (!nsoption_bool(http_proxy))
		return ProxyTypeDirect;

	int proxyType = nsoption_int(http_proxy_auth);
	BOOL authenticated = (nsoption_charp(http_proxy_auth_user) != NULL)
		&& (nsoption_charp(http_proxy_auth_pass) != NULL);
	BOOL hostProvided = nsoption_charp(http_proxy_host) != NULL;

	if (!hostProvided)
		return ProxyTypeSystem;

	// If the required fields of a selected proxy type arne't set; Default to none.
	switch (proxyType) {
	case OPTION_HTTP_PROXY_AUTH_NONE:
			return ProxyTypeNoAuth;
	case OPTION_HTTP_PROXY_AUTH_BASIC:
		if (authenticated)
			return ProxyTypeBasicAuth;
		else
			return ProxyTypeDirect;
	case OPTION_HTTP_PROXY_AUTH_NTLM:
		if (authenticated)
			return ProxyTypeAuth;
		else
			return ProxyTypeDirect;
	default:
		return ProxyTypeDirect;
	}
}
-(void)setProxyType: (ProxyType)value {
	switch (value) {
	case ProxyTypeDirect:
		nsoption_set_bool(http_proxy, false);
		break;
	case ProxyTypeNoAuth:
		nsoption_set_bool(http_proxy, true);
		nsoption_set_int(http_proxy_auth, OPTION_HTTP_PROXY_AUTH_NONE);
		break;
	case ProxyTypeBasicAuth:
		nsoption_set_bool(http_proxy, true);
		nsoption_set_int(http_proxy_auth, OPTION_HTTP_PROXY_AUTH_BASIC);
		break;
	case ProxyTypeAuth:
		nsoption_set_bool(http_proxy, true);
		nsoption_set_int(http_proxy_auth, OPTION_HTTP_PROXY_AUTH_NTLM);
		break;
	case ProxyTypeSystem:
		nsoption_set_bool(http_proxy, true);
		nsoption_set_charp(http_proxy_host, NULL);
		nsoption_set_int(http_proxy_auth, OPTION_HTTP_PROXY_AUTH_NONE);
		break;
	}
	[self saveNetsurfPrefsFile];
}

-(NSString*)proxyHost {
	char *value =  nsoption_charp(http_proxy_host);
	if (value == NULL)
		return nil;
	return [NSString stringWithCString: value];
}
-(void)setProxyHost: (NSString*)value {
	nsoption_set_charp(http_proxy_host, strdup([value cString]));
	[self saveNetsurfPrefsFile];
}

-(NSUInteger)proxyPort {
	return (NSUInteger)nsoption_int(http_proxy_port);
}
-(void)setProxyPort: (NSUInteger)value {
	nsoption_set_int(http_proxy_port, (int)value);
	[self saveNetsurfPrefsFile];
}

-(NSString*)proxyUsername {
	char *value =  nsoption_charp(http_proxy_auth_user);
	if (value == NULL)
		return nil;
	return [NSString stringWithCString: value];
}
-(void)setProxyUsername: (NSString*)value {
	nsoption_set_charp(http_proxy_auth_user, strdup([value cString]));
	[self saveNetsurfPrefsFile];
}

-(NSString*)proxyPassword {
	char *value =  nsoption_charp(http_proxy_auth_pass);
	if (value == NULL)
		return nil;
	return [NSString stringWithCString: value];
}
-(void)setProxyPassword: (NSString*)value {
	nsoption_set_charp(http_proxy_auth_pass, strdup([value cString]));
	[self saveNetsurfPrefsFile];
}

-(NSString*)proxyOmit {
	char *value =  nsoption_charp(http_proxy_noproxy);
	if (value == NULL)
		return nil;
	return [NSString stringWithCString: value];
}
-(void)setProxyOmit: (NSString*)value {
	nsoption_set_charp(http_proxy_noproxy, strdup([value cString]));
	[self saveNetsurfPrefsFile];
}

-(NSUInteger)maximumFetchers {
	return (NSUInteger)nsoption_int(max_fetchers);
}
-(void)setMaximumFetchers: (NSUInteger)value {
	nsoption_set_int(max_fetchers, (int)value);
	[self saveNetsurfPrefsFile];
}

-(NSUInteger)fetchesPerHost {
	return (NSUInteger)nsoption_int(max_fetchers_per_host);
}
-(void)setFetchesPerHost: (NSUInteger)value {
	nsoption_set_int(max_fetchers_per_host, (int)value);
	[self saveNetsurfPrefsFile];
}

-(NSUInteger)cachedConnections {
	return (NSUInteger)nsoption_int(max_cached_fetch_handles);
}
-(void)setCachedConnections: (NSUInteger)value {
	nsoption_set_int(max_cached_fetch_handles, (int)value);
	[self saveNetsurfPrefsFile];
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

-(void)saveNetsurfPrefsFile {
	[[NSFileManager defaultManager] createDirectoryAtPath: NS_PREFS_DIR
		attributes: nil];
	if (nsoption_write([NS_PREFS_FILE cString], NULL, NULL) != NSERROR_OK) {
		NSLog(@"Failed to write prefs to file %@", NS_PREFS_FILE);
	}
}
@end
