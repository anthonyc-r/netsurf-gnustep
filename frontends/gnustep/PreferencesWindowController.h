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
// CONTENT
	id defaultFontButton;
	id displayImagesButton;
	id enableAnimationButton;
	id enableJavascriptButton;
	id fontSizeStepper;
	id hideAdvertsButton;
	id fontSizeField;
	id preferredLanguageButton;
	id preventPopupsButton;
	id previewFontButton;
// PRIVACY
	id doNotTrackButton;
	id referralSubmissionButton;
	id localHistoryUrlTooltipButton;
	id rememberHistoryField;
	id memCacheSizeField;
	id diskCacheSizeField;
	id expireCacheField;
// NETWORK
	id proxyTypeButton;
	id proxyHostField;
	id proxyPortField;
	id proxyUsernameField;
	id proxyPasswordField;
	id proxyOmitField;
	id maxFetchersField;
	id fetchesPerHostField;
	id cachedConnectionsField;

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

// CONTENT
-(void)didChangeFontSizeStepper: (id)sender;
-(void)didEnterFontSize: (id)sender;
-(void)didPickDefaultFont: (id)sender;
-(void)didPickLoadImages: (id)sender;
-(void)didPressEnableAnimations: (id)sender;
-(void)didPressEnableJavascript: (id)sender;
-(void)didPressHideAdverts: (id)sender;
-(void)didPressPreventPopups: (id)sender;
-(void)didPressPreviewFont: (id)sender;
-(void)didPickPreferredLanguage: (id)sender;

// PRIVACY
-(void)didPressReferralSubmission: (id)sender;
-(void)didPressDoNotTrack: (id)sender;
-(void)didPressLocalHistoryTooltip: (id)sender;
-(void)didChangeBrowsingHistory: (id)sender;
-(void)didChangeMemCacheSize: (id)sender;
-(void)didChangeDiskCacheSize: (id)sender;
-(void)didChangeExpireCache: (id)sender;

// NETWORK
-(void)didPickProxyType: (id)sender;
-(void)didChangeProxyHost: (id)sender;
-(void)didChangeProxyPort: (id)sender;
-(void)didChangeProxyUsername: (id)sender;
-(void)didChangeProxyPassword: (id)sender;
-(void)didChangeProxyOmit: (id)sender;
-(void)didChangeMaxFetchers: (id)sender;
-(void)didChangeFetchesPerHost: (id)sender;
-(void)didChangeCachedConnections: (id)sender;

@end
