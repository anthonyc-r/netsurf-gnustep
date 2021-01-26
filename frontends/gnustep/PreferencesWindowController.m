#import <AppKit/AppKit.h>
#import "PreferencesWindowController.h"

@interface PreferencesWindowController (Private) 
-(void)configureMainTab;
@end

@implementation PreferencesWindowController

-(id)init {
	if (self = [super initWithWindowNibName: @"Preferences"]) {
		//...
	}
	return self;
}

-(void)awakeFromNib {
	[self configureMainTab];
}

// MARK: - MAIN TAB

-(void)configureMainTab {
	NSLog(@"configure main tab");
}

-(void)didEnterStartupPage: (id)sender {
	NSLog(@"Did enter startup page");
}


-(void)didPickDownloadLocation: (id)sender {
	NSLog(@"Did pick download location");
}


-(void)didPickSearchProvider: (id)sender {
	NSLog(@"Did pick search provider");
}


-(void)didPressDownloadConfirmOverwrite: (id)sender {
	NSLog(@"Did press download confirm overwrite");
}


-(void)didPressDownloadRemoveOnComplete: (id)sender {
	NSLog(@"Did press download remove on complete");
}


-(void)didPressStartupUseCurrentPage: (id)sender {
	NSLog(@"Did press startup use current page");
}


-(void)didPressStartupUseDefaultPage: (id)sender {
	NSLog(@"Did press startup use default page");
}


-(void)didPressSearchFromUrlBar: (id)sender {
	NSLog(@"Did press search from url bar");
}

@end
