#import <AppKit/AppKit.h>

@interface PreferencesWindowController: NSWindowController {
// MAIN
	id downloadConfirmOverwriteButton;
	id downloadLocationButton;
	id downloadRemoveOnCompleteButton;
	id searchFromUrlButton;
	id searchProviderButton;
	id startupPageField;
// APPEARANCE
	id alwaysShowTabBarButton;
	id bankNewTabsButton;
	id developerViewsButton;
	id urlBarButtonsTypeButton;
	id switchToTabsButton;
	id tabPositionButton;
	id urlSuggestionsButton;

	NSMutableArray *downloadLocations;
}
// MAIN
-(void)didEnterStartupPage: (id)sender;
-(void)didPickDownloadLocation: (id)sender;
-(void)didPickSearchProvider: (id)sender;
-(void)didPressDownloadConfirmOverwrite: (id)sender;
-(void)didPressDownloadRemoveOnComplete: (id)sender;
-(void)didPressStartupUseCurrentPage: (id)sender;
-(void)didPressStartupUseDefaultPage: (id)sender;
-(void)didPressSearchFromUrlBar: (id)sender;

// APPEARANCE
-(void)didPickDeveloperViews: (id)sender;
-(void)didPickTabPosition: (id)sender;
-(void)didPressAlwaysShowTabBar: (id)sender;
-(void)didPressBlankNewTabs: (id)sender;
-(void)didPressSwitchToTabs: (id)sender;
-(void)didPressUrlSuggestions: (id)sender;
-(void)didPickUrlButtonsType: (id)sender;
@end
