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
#import "SearchProvider.h"

#define NS_PREFS_DIR ([@"~/.config/NetSurf/" stringByExpandingTildeInPath])
#define NS_PREFS_FILE ([@"~/.config/NetSurf/prefs" stringByExpandingTildeInPath])

typedef NS_ENUM(NSInteger, ViewLocation) {
	ViewLocationWindow = 0,
	ViewLocationTab,
	ViewLocationEditor
};

typedef NS_ENUM(NSInteger, TabLocation) {
	TabLocationTop = 0,
	TabLocationRight,
	TabLocationBottom,
	TabLocationLeft,
	TabLocationNone
};

typedef NS_ENUM(NSInteger, UrlBarButtonType) {
	UrlBarButtonTypeText = 0,
	UrlBarButtonTypeImage
};

typedef NS_ENUM(NSInteger, LoadImages) {
	LoadImagesAll = 0,
	LoadImagesForeground,
	LoadImagesBackground,
	LoadImagesNone
};

typedef NS_ENUM(NSInteger, FontType) {
	FontTypeSansSerif = 0,
	FontTypeSerif,
	FontTypeMonospace,
	FontTypeCursive,
	FontTypeFantasy
};

typedef NS_ENUM(NSInteger, ProxyType) {
	ProxyTypeDirect = 0,
	ProxyTypeBasicAuth,
	ProxyTypeNoAuth,
	ProxyTypeAuth,
	ProxyTypeSystem
};

// Certain preferences will notify that they have been updated using this key.
#define PreferencesUpdatedNotificationName @"PreferencesUpdatedNotification"
typedef NS_ENUM(NSInteger, PreferenceType) {
	PreferenceTypeAlwaysShowTabs = 0,
	PreferenceTypeTabLocation,
	PreferenceTypeShowUrlSuggestions,
	PreferenceTypeUrlBarButtonType
};

@interface Preferences: NSObject {
	NSUserDefaults *defaults;
}

-(NSString*)startupUrl;
-(void)setStartupUrl: (NSString*)aUrl;

-(BOOL)searchFromUrlBar;
-(void)setSearchFromUrlBar: (BOOL)value;

-(SearchProvider*)searchProvider;
-(void)setSearchProvider: (SearchProvider*)aProvider;

-(BOOL)removeDownloadsOnComplete;
-(void)setRemoveDownloadsOnComplete: (BOOL)value;

-(BOOL)confirmBeforeOverwriting;
-(void)setConfirmBeforeOverwriting: (BOOL)value;

-(NSString*)downloadLocationPath;
-(void)setDownloadLocationPath: (NSString*)aPath;

-(BOOL)alwaysShowTabs;
-(void)setAlwaysShowTabs: (BOOL)value;

-(BOOL)switchTabImmediately;
-(void)setSwitchTabImmediately: (BOOL)value;

-(BOOL)blankNewTabs;
-(void)setBlankNewTabs: (BOOL)value;

-(TabLocation)tabLocation;
-(void)setTabLocation: (TabLocation)value;

-(ViewLocation)developerViewLocation;
-(void)setDeveloperViewLocation: (ViewLocation)value;

-(BOOL)showUrlSuggestions;
-(void)setShowUrlSuggestions: (BOOL)value;

-(UrlBarButtonType)urlBarButtonType;
-(void)setUrlBarButtonType: (UrlBarButtonType)buttonType;

-(LoadImages)loadImages;
-(void)setLoadImages: (LoadImages)loadImages;

-(BOOL)disablePopups;
-(void)setDisablePopups: (BOOL)value;

-(BOOL)hideAds;
-(void)setHideAds: (BOOL)value;

-(BOOL)enableJavascript;
-(void)setEnableJavascript: (BOOL)value;

-(BOOL)enableAnimation;
-(void)setEnableAnimation: (BOOL)value;

-(FontType)defaultFont;
-(void)setDefaultFont: (FontType)value;

-(NSString*)preferredLanguage;
-(void)setPreferredLanguage: (NSString*)value;

-(NSUInteger)fontSize;
-(void)setFontSize: (NSUInteger)value;

-(BOOL)enableReferralSubmission;
-(void)setEnableReferralSubmission: (BOOL)value;

-(BOOL)sendDoNotTrackRequest;
-(void)setSendDoNotTrackRequest: (BOOL)value;

-(BOOL)showHistoryTooltip;
-(void)setShowHistoryTooltip: (BOOL)value;

-(NSUInteger)browsingHistoryDays;
-(void)setBrowsingHistoryDays: (NSUInteger)value;

-(NSUInteger)diskCacheSize;
-(void)setDiskCacheSize: (NSUInteger)value;

-(NSUInteger)memCacheSize;
-(void)setMemCacheSize: (NSUInteger)value;

-(NSUInteger)cacheExpiryDays;
-(void)setCacheExpiryDays: (NSUInteger)value;

-(ProxyType)proxyType;
-(void)setProxyType: (ProxyType)value;

-(NSString*)proxyHost;
-(void)setProxyHost: (NSString*)value;

-(NSUInteger)proxyPort;
-(void)setProxyPort: (NSUInteger)value;

-(NSString*)proxyUsername;
-(void)setProxyUsername: (NSString*)value;

-(NSString*)proxyPassword;
-(void)setProxyPassword: (NSString*)value;

-(NSString*)proxyOmit;
-(void)setProxyOmit: (NSString*)value;

-(NSUInteger)maximumFetchers;
-(void)setMaximumFetchers: (NSUInteger)value;

-(NSUInteger)fetchesPerHost;
-(void)setFetchesPerHost: (NSUInteger)value;

-(NSUInteger)cachedConnections;
-(void)setCachedConnections: (NSUInteger)value;


+(Preferences*)defaultPreferences;
@end
