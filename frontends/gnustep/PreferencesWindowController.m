#include <AppKit/AppKit.h>
#include "PreferencesWindowController.h"

@implementation PreferencesWindowController

-(id)init {
	if (self = [super initWithWindowNibName: @"Preferences"]) {
		//...
	}
	return self;
}

-(void)didEnterStartupPage: (id)sender {

}


-(void)didPickDownloadLocation: (id)sender {

}


-(void)didPickSearchProvider: (id)sender {

}


-(void)didPressDownloadConfirmOverwrite: (id)sender {

}


-(void)didPressDownloadRemoveOnComplete: (id)sender {

}


-(void)didPressStartupUseCurrentPage: (id)sender {

}


-(void)didPressStartupUseDefaultPage: (id)sender {

}


-(void)didPressSearchFromUrlBar: (id)sender {

}

@end
