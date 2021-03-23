#import <Cocoa/Cocoa.h>
#import "UrlSuggestionView.h"
#import "Preferences.h"

@interface UrlSuggestionView(Private)
-(void)updateActivationState;
-(void)onPreferencesUpdated: (NSNotification*)aNotification;
-(void)onUrlContentsChanged: (NSNotification*)aNotification;
@end

@implementation UrlSuggestionView

-(id)initForUrlBar: (NSTextField*)aUrlBar {
	if ((self = [super init])) {
		urlBar = aUrlBar;
		NSRect frame = [aUrlBar frame];
		frame.origin.y -= frame.size.height;
		[self setFrame: frame];
 	 	[[NSNotificationCenter defaultCenter] addObserver: self
 			 selector: @selector(onPreferencesUpdated:)
 			 name: PreferencesUpdatedNotificationName
 			 object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self
			selector: @selector(onUrlContentsChanged:)
			name: NSControlTextDidChangeNotification
			object: urlBar];
		[self updateActivationState];
		[self setAutoresizingMask: [aUrlBar autoresizingMask]];
		[[aUrlBar superview] addSubview: self];
	}
	return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[super dealloc];
}

-(void)dismiss {

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
	isActive = [[Preferences defaultPreferences] showUrlSuggestions];
	if (isActive) {
		[self setHidden: NO];

	} else {
		[self setHidden: YES];

	}
}

-(void)onUrlContentsChanged: (NSNotification*)aNotification {
	NSLog(@"contents changed?!");
	if (!isActive) {
		return;
	}
	id editor = [[aNotification userInfo] objectForKey: @"NSFieldEditor"];
	
	NSLog(@"%@", editor);
}

@end
