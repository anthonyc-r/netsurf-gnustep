#import <Cocoa/Cocoa.h>
#import "UrlSuggestionView.h"
#import "Preferences.h"

@interface UrlSuggestionView(Private)
-(void)notifyPreferenceChanges;
-(void)onPreferencesUpdated: (NSNotification*)aNotification;
-(void)updateActivationState;
@end

@implementation UrlSuggestionView

-(id)initForUrlBar: (NSTextField*)aUrlBar {
	if ((self = [super init])) {
		NSRect frame = [aUrlBar frame];
		frame.origin.y -= frame.size.height;
		[self setFrame: frame];
		[self notifyPreferenceChanges];
		[self updateActivationState];
		[[aUrlBar superview] addSubview: self];
	}
	return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[super dealloc];
}

-(void)updateQuery: (NSString*)aQuery {

}

-(void)dismiss {

}

-(void)notifyPreferenceChanges {
	[[NSNotificationCenter defaultCenter] addObserver: self
		selector: @selector(onPreferencesUpdated:)
		name: PreferencesUpdatedNotificationName
		object: nil];
}

-(void)onPreferencesUpdated: (NSNotification*)aNotification {
	NSDictionary *dict = [aNotification object];
	PreferenceType type = (PreferenceType)[[dict objectForKey: @"type"]
		integerValue];
	if (type == PreferenceTypeShowUrlSuggestions) {
		[self updateActivationState];
	}
}

-(void)updateActivationState {
	BOOL isActive = [[Preferences defaultPreferences] showUrlSuggestions];
	if (isActive) {
		[self setHidden: NO];
	} else {
		[self setHidden: YES];
	}
}

@end
