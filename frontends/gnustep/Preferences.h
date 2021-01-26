#import <Foundation/Foundation.h>
#import "SearchProvider.h"

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
@end