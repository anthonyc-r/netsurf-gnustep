/*
 * Copyright 2022 Anthony Cohn-Richardby <anthonyc@gmx.co.uk>
 *
 * This file is part of NetSurf, http://www.netsurf-browser.org/
 *
 * NetSurf is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 * NetSurf is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
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
-(void)configureContentTab;
-(void)configurePrivacyTab;
-(void)configureNetworkTab;
-(void)configureProxyFieldsEnabled: (ProxyType)proxyType;
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
	[self configureContentTab];
	[self configurePrivacyTab];
	[self configureNetworkTab];
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
	UrlBarButtonType buttonType = [[Preferences defaultPreferences] urlBarButtonType];
	[urlBarButtonsTypeButton selectItemAtIndex: (NSInteger)buttonType];
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
	UrlBarButtonType buttonType = (UrlBarButtonType)[sender indexOfItem: [sender
		selectedItem]];
	[[Preferences defaultPreferences] setUrlBarButtonType: buttonType];
}

// MARK: - CONTENT TAB
-(void)configureContentTab {
	LoadImages loadImages = [[Preferences defaultPreferences] loadImages];
	[displayImagesButton selectItemAtIndex: (NSInteger)loadImages];
	[preventPopupsButton setState: [[Preferences defaultPreferences] disablePopups] 
		? NSOnState : NSOffState];
	[hideAdvertsButton setState: [[Preferences defaultPreferences] hideAds]
		? NSOnState : NSOffState];
	[enableJavascriptButton setState: [[Preferences defaultPreferences] enableJavascript]
		? NSOnState : NSOffState];
	[enableAnimationButton setState: [[Preferences defaultPreferences] enableAnimation]
		? NSOnState : NSOffState];
	FontType fontType = [[Preferences defaultPreferences] defaultFont];
	[defaultFontButton selectItemAtIndex: (NSInteger)fontType];

	NSUInteger selectedIndex = 0;
	NSString *preferredLanguage = [[Preferences defaultPreferences] preferredLanguage];
	NSString *languagesPath = [[NSBundle mainBundle] pathForResource: @"Languages" ofType: @"plist"];
	NSArray *languages = [NSArray arrayWithContentsOfFile: languagesPath];
	for (NSUInteger i = 0; i < [languages count]; i++) {
		[preferredLanguageButton addItemWithTitle: [languages objectAtIndex: i]];
		if ([[languages objectAtIndex: i] isEqualTo: preferredLanguage]) {
			selectedIndex = i;
		}
	}
	[preferredLanguageButton selectItemAtIndex: selectedIndex];
	NSUInteger fontSize = [[Preferences defaultPreferences] fontSize];
	[fontSizeField setStringValue: [NSString stringWithFormat: @"%u", fontSize]];
	[fontSizeStepper setIntegerValue: fontSize];
}

-(void)didChangeFontSizeStepper: (id)sender {
	NSLog(@"didChangeFontSizeStepper");
	NSInteger value = [sender integerValue];
	if (value < 1) {
		value = 1;
		[sender setIntegerValue: value];
	}
	[fontSizeField setStringValue: [NSString stringWithFormat: @"%u", value]];
	[[Preferences defaultPreferences] setFontSize: value];
}

-(void)didEnterFontSize: (id)sender {
	NSLog(@"didEnterFontSize");
	NSInteger value = [[sender stringValue] integerValue];
	if (value < 1)
		value = 1;
	[fontSizeStepper setIntegerValue: value];
	[[Preferences defaultPreferences] setFontSize: (NSUInteger)value];
}

-(void)didPickDefaultFont: (id)sender {
	NSLog(@"didPickDefualtFont");
	FontType fontType = (FontType)[sender indexOfItem: [sender selectedItem]];
	[[Preferences defaultPreferences] setDefaultFont: fontType];
}

-(void)didPickLoadImages: (id)sender {
	NSLog(@"didPickLoadImages");
	LoadImages loadImages = (LoadImages)[sender indexOfItem: [sender
		selectedItem]];
	[[Preferences defaultPreferences] setLoadImages: loadImages];
}

-(void)didPressEnableAnimations: (id)sender {
	NSLog(@"didPressEnableAnimations");
	BOOL checked = [sender state] == NSOnState;
	[[Preferences defaultPreferences] setEnableAnimation: checked];
}

-(void)didPressEnableJavascript: (id)sender {
	NSLog(@"didPressEnableJavascript");
	BOOL checked = [sender state] == NSOnState;
	[[Preferences defaultPreferences] setEnableJavascript: checked];
}

-(void)didPressHideAdverts: (id)sender {
	NSLog(@"didPressHideAdverts");
	BOOL checked = [sender state] == NSOnState;
	[[Preferences defaultPreferences] setHideAds: checked];
}

-(void)didPressPreventPopups: (id)sender {
	NSLog(@"didPressPreventPopups");
	BOOL checked = [sender state] == NSOnState;
	[[Preferences defaultPreferences] setDisablePopups: checked];
}

-(void)didPressPreviewFont: (id)sender {
	NSLog(@"didPressPreviewFont");
}

-(void)didPickPreferredLanguage: (id)sender {
	NSLog(@"didPickPreferredLanguage");
	[[Preferences defaultPreferences] setPreferredLanguage: [sender title]];
}

// MARK: - PRIVACY TAB
-(void)configurePrivacyTab {
	NSLog(@"Configure content tab");
	[doNotTrackButton setState: [[Preferences defaultPreferences]
		sendDoNotTrackRequest] ? NSOnState : NSOffState];
	[referralSubmissionButton setState: [[Preferences defaultPreferences]
		enableReferralSubmission] ? NSOnState : NSOffState];
	[localHistoryUrlTooltipButton setState: [[Preferences defaultPreferences]
		showHistoryTooltip] ? NSOnState : NSOffState];

	[rememberHistoryField setStringValue: [NSString stringWithFormat: @"%u",
		[[Preferences defaultPreferences] browsingHistoryDays]]];
	[memCacheSizeField setStringValue: [NSString stringWithFormat: @"%u",
		[[Preferences defaultPreferences] memCacheSize]]];
	[diskCacheSizeField setStringValue: [NSString stringWithFormat: @"%u",
		[[Preferences defaultPreferences] diskCacheSize]]];
	[expireCacheField setStringValue: [NSString stringWithFormat: @"%u",
		[[Preferences defaultPreferences] cacheExpiryDays]]];
}

-(void)didPressReferralSubmission: (id)sender {
	NSLog(@"didPressReferralSubmission", sender);
	[[Preferences defaultPreferences] setEnableReferralSubmission: [sender state]
		== NSOnState ? YES : NO];
}

-(void)didPressDoNotTrack: (id)sender {
	NSLog(@"didPressDoNotTrack", sender);
	[[Preferences defaultPreferences] setSendDoNotTrackRequest: [sender state]
		== NSOnState ? YES : NO];
}

-(void)didPressLocalHistoryTooltip: (id)sender {
	NSLog(@"didPressLocalHistoryTooltip", sender);
	[[Preferences defaultPreferences] setShowHistoryTooltip: [sender state]
		== NSOnState ? YES : NO];
}

-(void)didChangeBrowsingHistory: (id)sender {
	NSLog(@"didChangeBrowsingHistory", sender);
	[[Preferences defaultPreferences] setBrowsingHistoryDays:
		(NSUInteger)[[sender stringValue] integerValue]];
	[[NSApp delegate] clearBrowsingHistory];
}

-(void)didChangeMemCacheSize: (id)sender {
	NSLog(@"didChangeMemCacheSize", sender);
	[[Preferences defaultPreferences] setMemCacheSize:
		(NSUInteger)[[sender stringValue] integerValue]];
}

-(void)didChangeDiskCacheSize: (id)sender {
	NSLog(@"didChangeDiskCacheSize", sender);
	[[Preferences defaultPreferences] setDiskCacheSize:
		(NSUInteger)[[sender stringValue] integerValue]];
}

-(void)didChangeExpireCache: (id)sender {
	NSLog(@"didChangeExpireCache", sender);
	[[Preferences defaultPreferences] setCacheExpiryDays:
		(NSUInteger)[[sender stringValue] integerValue]];
}

// MARK: - NETWORK TAB
-(void)configureNetworkTab {
	Preferences *prefs = [Preferences defaultPreferences];
	[proxyTypeButton selectItemAtIndex: (NSUInteger)[prefs proxyType]];
	[proxyHostField setStringValue: [prefs proxyHost]];
	[proxyUsernameField setStringValue: [prefs proxyUsername]];
	[proxyPortField setIntegerValue: [prefs proxyPort]];
	[proxyPasswordField setStringValue: [prefs proxyPassword]];
	[proxyOmitField setStringValue: [prefs proxyOmit]];
	[maxFetchersField setIntegerValue: [prefs maximumFetchers]];
	[fetchesPerHostField setIntegerValue: [prefs fetchesPerHost]];
	[cachedConnectionsField setIntegerValue: [prefs cachedConnections]];
	[self configureProxyFieldsEnabled: [prefs proxyType]];
}

static void disable(NSControl *field) {
	[field setStringValue: nil];
	[field setEnabled: NO];
}
static void enable(NSControl *field) {
	[field setEnabled: YES];
}
-(void)configureProxyFieldsEnabled: (ProxyType)proxyType {
	enable(proxyHostField);
	enable(proxyPortField);
	enable(proxyUsernameField);
	enable(proxyPasswordField);
	enable(proxyOmitField);

	switch (proxyType) {
	case ProxyTypeDirect:
		disable(proxyHostField);
		disable(proxyPortField);
		disable(proxyUsernameField);
		disable(proxyPasswordField);
		disable(proxyOmitField);
		break;
	case ProxyTypeBasicAuth:
		break;
	case ProxyTypeNoAuth:
		disable(proxyUsernameField);
		disable(proxyPasswordField);
		break;
	case ProxyTypeAuth:
		break;
	case ProxyTypeSystem:
		disable(proxyHostField);
		disable(proxyPortField);
		disable(proxyUsernameField);
		disable(proxyPasswordField);
		[proxyHostField setStringValue: @"localhost"];
		break;
	default:
		break;
	}
}

-(void)didPickProxyType: (id)sender {
	NSLog(@"didPickProxyType");
	NSUInteger selected = [sender indexOfItem: [sender selectedItem]];
	[[Preferences defaultPreferences] setProxyType: (ProxyType)selected];
	[self configureProxyFieldsEnabled: (ProxyType)selected];
}

-(void)didChangeProxyHost: (id)sender {
	NSLog(@"didChangeProxyHost");
	[[Preferences defaultPreferences] setProxyHost: [sender stringValue]];
}

-(void)didChangeProxyPort: (id)sender {
	NSLog(@"didChangeProxyPort");
	[[Preferences defaultPreferences] setProxyPort: [[sender stringValue] integerValue]];
}

-(void)didChangeProxyUsername: (id)sender {
	NSLog(@"didChangeProxyUsername");
	[[Preferences defaultPreferences] setProxyUsername: [sender stringValue]];
}

-(void)didChangeProxyPassword: (id)sender {
	NSLog(@"didChangeProxyPassword");
	[[Preferences defaultPreferences] setProxyPassword: [sender stringValue]];
}

-(void)didChangeProxyOmit: (id)sender {
	NSLog(@"didChangeProxyOmit");
	[[Preferences defaultPreferences] setProxyOmit: [sender stringValue]];
}

-(void)didChangeMaxFetchers: (id)sender {
	NSLog(@"didChangeMaxFetchers");
	[[Preferences defaultPreferences] setMaximumFetchers: [[sender stringValue] integerValue]];
}

-(void)didChangeFetchesPerHost: (id)sender {
	NSLog(@"didChangeFetchesPerHost");
	[[Preferences defaultPreferences] setFetchesPerHost: [[sender stringValue] integerValue]];
}

-(void)didChangeCachedConnections: (id)sender {
	NSLog(@"didChangeCachedConnections");
	[[Preferences defaultPreferences] setCachedConnections: [[sender stringValue] integerValue]];
}


@end
