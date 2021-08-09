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

+(Preferences*)defaultPreferences;
@end
