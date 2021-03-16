#import <Foundation/Foundation.h>
#import "SearchProvider.h"

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

// Certain preferences will notify that they have been updated using this key.
#define PreferencesUpdatedNotificationName @"PreferencesUpdatedNotification"
typedef NS_ENUM(NSInteger, PreferenceType) {
	PreferenceTypeAlwaysShowTabs = 0,
	PreferenceTypeTabLocation
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
-(void)setSwitchTabImmediaty: (BOOL)value;

-(BOOL)blankNewTabs;
-(void)setBlankNewTabs: (BOOL)value;

-(TabLocation)tabLocation;
-(void)setTabLocation: (TabLocation)value;

-(ViewLocation)developerViewLocation;
-(void)setDeveloperViewLocation: (ViewLocation)value;

+(Preferences*)defaultPreferences;
@end
