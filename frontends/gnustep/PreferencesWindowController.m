#import <AppKit/AppKit.h>
#import "PreferencesWindowController.h"
#import "Preferences.h"
#import "SearchProvider.h"
#import "AppDelegate.h"

#define DL_DOWNLOADS_PATH [@"~/Downloads" stringByExpandingTildeInPath]
#define DL_HOME_PATH [@"~/" stringByExpandingTildeInPath]
#define DL_DESKTOP_PATH [@"~/Desktop" stringByExpandingTildeInPath]

@interface PreferencesWindowController (Private) 
-(void)configureMainTab;
-(void)reconfigureDownloadLocationButton;
-(void)configureAppearanceTab;
@end
@interface DownloadLocation: NSObject {
	NSString *name;
	NSString *path;
}
@end
@implementation DownloadLocation
-(id)initWithName: (NSString*)aName path: (NSString*)aPath {
	if ((self = [super init])) {
		name = [aName retain];	
		path = [aPath retain];
	}
	return self;
}
+(DownloadLocation*)downloadLocationWithName: (NSString*)aName path: (NSString*)aPath {
	return [[[DownloadLocation alloc] initWithName: aName path: aPath] autorelease];
}
-(void)dealloc {
	[name release];
	[path release];
	[super dealloc];
}
-(NSString*)name {
	return name;
}
-(NSString*)path {
	return path;
}
@end

@implementation PreferencesWindowController

-(id)init {
	if ((self = [super initWithWindowNibName: @"Preferences"])) {
		//...
	}
	return self;
}

-(void)dealloc {
	[downloadLocations release];
	[super dealloc];
}

-(void)awakeFromNib {
	[self configureMainTab];
	[self configureAppearanceTab];
}

// MARK: - MAIN TAB

-(void)configureMainTab {
	NSLog(@"configure main tab");
	[startupPageField setStringValue: [[Preferences defaultPreferences] startupUrl]];
	[searchFromUrlButton setState: [[Preferences defaultPreferences] searchFromUrlBar] ?
		NSOnState : NSOffState];

	[searchProviderButton removeAllItems];
	NSArray *searchProviders = [SearchProvider allProviders];
	SearchProvider *currentProvider = [[Preferences defaultPreferences] searchProvider];
	NSInteger selectedIndex = 0;
	for (NSUInteger i = 0; i < [searchProviders count]; i++) {
		SearchProvider *provider = [searchProviders objectAtIndex: i];
		[searchProviderButton addItemWithTitle: [provider name]];
		if ([[provider name] isEqual: [currentProvider name]]) {
			selectedIndex = i;
		}
	}
	[searchProviderButton selectItemAtIndex: selectedIndex];

	[downloadRemoveOnCompleteButton setState: [[Preferences defaultPreferences] 
		removeDownloadsOnComplete] ? NSOnState : NSOffState];
	[downloadConfirmOverwriteButton setState: [[Preferences defaultPreferences]
		confirmBeforeOverwriting] ? NSOnState : NSOffState];

	downloadLocations = [NSMutableArray arrayWithObjects: 
		[DownloadLocation downloadLocationWithName: @"Downloads" path: 
			DL_DOWNLOADS_PATH],
		[DownloadLocation downloadLocationWithName: @"Desktop" path: 
			DL_DESKTOP_PATH],
		[DownloadLocation downloadLocationWithName: @"Home" path: DL_HOME_PATH],
		[DownloadLocation downloadLocationWithName: @"Other..." path: nil],
		nil
	];
	[downloadLocations retain];
	[self reconfigureDownloadLocationButton];
}

-(void)reconfigureDownloadLocationButton {
	[downloadLocationButton removeAllItems];
	NSString *path = [[Preferences defaultPreferences] downloadLocationPath];
	NSInteger selectedIndex = -1;
	for (NSUInteger i = 0; i < [downloadLocations count]; i++) {
		DownloadLocation *loc = [downloadLocations objectAtIndex: i];
		[downloadLocationButton addItemWithTitle: [loc name]];
		if ([path isEqual: [loc path]]) {
			selectedIndex = i;
		}
	}
	if (selectedIndex == -1) {
		DownloadLocation *loc = [DownloadLocation downloadLocationWithName:
			[path lastPathComponent] path: path];
		[downloadLocations addObject: loc];
		[downloadLocationButton addItemWithTitle: [loc name]];
		selectedIndex = [downloadLocations count] - 1;
	}
	[downloadLocationButton selectItemAtIndex: selectedIndex];
}

-(void)didEnterStartupPage: (id)sender {
	NSLog(@"Did enter startup page");
	[[Preferences defaultPreferences] setStartupUrl: [sender stringValue]];
}


-(void)didPickDownloadLocation: (id)sender {
	NSLog(@"Did pick download location");
	NSInteger idx = [sender indexOfItem: [sender selectedItem]];
	DownloadLocation *loc = [downloadLocations objectAtIndex: idx];
	if ([loc path] == nil) {
		// "Other"... Show file picker.
		NSOpenPanel *panel = [NSOpenPanel openPanel];
		[panel setCanChooseFiles: NO];
		[panel setCanChooseDirectories: YES];
		if ([panel runModal] == NSOKButton) {
			NSString *path = [[panel filenames] firstObject];
		
			loc = [DownloadLocation downloadLocationWithName: [path
				lastPathComponent] path: path];
			[downloadLocations addObject: loc];
		} else {
			loc = [downloadLocations objectAtIndex: 0];
		}
		[[Preferences defaultPreferences] setDownloadLocationPath: [loc path]];
		[self reconfigureDownloadLocationButton];
	} else {
		[[Preferences defaultPreferences] setDownloadLocationPath: [loc path]];
	}
}


-(void)didPickSearchProvider: (id)sender {
	NSLog(@"Did pick search provider");
	NSInteger idx = [sender indexOfItem: [sender selectedItem]];
	SearchProvider *prov = [[SearchProvider allProviders] objectAtIndex: idx];
	[[Preferences defaultPreferences] setSearchProvider: prov];
}


-(void)didPressDownloadConfirmOverwrite: (id)sender {
	NSLog(@"Did press download confirm overwrite");
	BOOL checked = [sender state] == NSOnState;
	[[Preferences defaultPreferences] setConfirmBeforeOverwriting: checked];
}


-(void)didPressDownloadRemoveOnComplete: (id)sender {
	NSLog(@"Did press download remove on complete");
	BOOL checked = [sender state] == NSOnState;
	[[Preferences defaultPreferences] setRemoveDownloadsOnComplete: checked];
}


-(void)didPressStartupUseCurrentPage: (id)sender {
	NSLog(@"Did press startup use current page");
	AppDelegate *delegate = [NSApp delegate];
	NSString *url = [delegate currentUrl];
	[[Preferences defaultPreferences] setStartupUrl: url];
	[startupPageField setStringValue: [[Preferences defaultPreferences] startupUrl]];
}


-(void)didPressStartupUseDefaultPage: (id)sender {
	NSLog(@"Did press startup use default page");
	[[Preferences defaultPreferences] setStartupUrl: nil];
	[startupPageField setStringValue: [[Preferences defaultPreferences] startupUrl]];
}


-(void)didPressSearchFromUrlBar: (id)sender {
	NSLog(@"Did press search from url bar");
	BOOL checked = [sender state] == NSOnState;
	[[Preferences defaultPreferences] setSearchFromUrlBar: checked];
}

// MARK: - APPEARANCE TAB
-(void)configureAppearanceTab {
	[alwaysShowTabBarButton setState: [[Preferences defaultPreferences] alwaysShowTabs] 
		? NSOnState : NSOffState];
	[switchToTabsButton setState: [[Preferences defaultPreferences] switchTabImmediately]
		? NSOnState : NSOffState];
	[bankNewTabsButton setState: [[Preferences defaultPreferences] blankNewTabs] 
		? NSOnState : NSOffState];
	TabLocation location = [[Preferences defaultPreferences] tabLocation];
	[tabPositionButton selectItemAtIndex: (NSInteger)location];
	ViewLocation viewLocation = [[Preferences defaultPreferences] developerViewLocation];
	[developerViewsButton selectItemAtIndex: (NSInteger)viewLocation];
	[urlSuggestionsButton setState: [[Preferences defaultPreferences] showUrlSuggestions]
		? NSOnState : NSOffState];
}

-(void)didPickDeveloperViews: (id)sender {
	NSLog(@"didPickDeveloperViews");
	ViewLocation location = (ViewLocation)[sender indexOfItem: [sender selectedItem]];
	[[Preferences defaultPreferences] setDeveloperViewLocation: location];
}

-(void)didPickTabPosition: (id)sender {
	NSLog(@"didPickTabPosition");
	TabLocation location = (TabLocation)[sender indexOfItem: [sender selectedItem]];
	[[Preferences defaultPreferences] setTabLocation: location];
}

-(void)didPressAlwaysShowTabBar: (id)sender {
	NSLog(@"didPressAlwaysShowTabBar");
	BOOL checked = [sender state] == NSOnState;
	[[Preferences defaultPreferences] setAlwaysShowTabs: checked];
}

-(void)didPressBlankNewTabs: (id)sender {
	NSLog(@"didPressBlankNewTabs");
	BOOL checked = [sender state] == NSOnState;
	[[Preferences defaultPreferences] setBlankNewTabs: checked];
}

-(void)didPressSwitchToTabs: (id)sender {
	NSLog(@"didPressSwitchToTabs");
	BOOL checked = [sender state] == NSOnState;
	[[Preferences defaultPreferences] setSwitchTabImmediately: checked];
}

-(void)didPressUrlSuggestions: (id)sender {
	NSLog(@"didPressUrlSuggestions");
	BOOL checked = [sender state] == NSOnState;
	[[Preferences defaultPreferences] setShowUrlSuggestions: checked];
}

-(void)didPickUrlButtonsType: (id)sender {
	NSLog(@"didPickUrlButtonsType");
}

@end
