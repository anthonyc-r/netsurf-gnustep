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
	TabLocationLeft
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



+(Preferences*)defaultPreferences;
@end