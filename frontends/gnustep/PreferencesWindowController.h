#include <AppKit/AppKit.h>

@interface PreferencesWindowController: NSWindowController {
	id downloadConfirmOverwriteButton;
	id downloadLocationButton;
	id downloadRemoveOnCompleteButton;
	id searchFromUrlButton;
	id searchProviderButton;
	id startupPageField;
}
-(void)didEnterStartupPage: (id)sender;
-(void)didPickDownloadLocation: (id)sender;
-(void)didPickSearchProvider: (id)sender;
-(void)didPressDownloadConfirmOverwrite: (id)sender;
-(void)didPressDownloadRemoveOnComplete: (id)sender;
-(void)didPressStartupUseCurrentPage: (id)sender;
-(void)didPressStartupUseDefaultPage: (id)sender;
-(void)didPressSearchFromUrlBar: (id)sender;
@end
