#import <AppKit/AppKit.h>
#import "PreferencesWindowController.h"
#import "Preferences.h"
#import "SearchProvider.h"

#define DL_DOWNLOADS_PATH [@"~/Downloads" stringByExpandingTildeInPath]
#define DL_HOME_PATH [@"~/" stringByExpandingTildeInPath]
#define DL_DESKTOP_PATH [@"~/Desktop" stringByExpandingTildeInPath]

@interface PreferencesWindowController (Private) 
-(void)configureMainTab;
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
	if (self = [super initWithWindowNibName: @"Preferences"]) {
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
		removeDownloadsOnComplete] ? NSOnState : NSOffState];

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

	[downloadLocationButton removeAllItems];
	NSString *path = [[Preferences defaultPreferences] downloadLocationPath];
	selectedIndex = -1;
	for (NSUInteger i = 0; i < [downloadLocations count]; i++) {
		DownloadLocation *loc = [downloadLocations objectAtIndex: i];
		[downloadLocationButton addItemWithTitle: [loc name]];
		if ([path isEqual: [loc path]]) {
			selectedIndex = i;
		}
	}
	if (selectedIndex == -1) {
		[downloadLocations addObject: [DownloadLocation downloadLocationWithName:
			[path stringByAbbreviatingWithTildeInPath] path: path]];
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
		// Show file picker.
	} else {
		[[Preferences defaultPreferences] setDownloadLocationPath: [loc path]];
	}
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
