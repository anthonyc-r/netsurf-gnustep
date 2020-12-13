#include <AppKit/AppKit.h>
#include "FindPanelController.h"
#include "BrowserWindowController.h"

@implementation FindPanelController

-(id)init {
	if (self = [super initWithWindowNibName: @"Find"]) {
		browserController = nil;
	}
	return self;
}

-(void)awakeFromNib {
	[[self window] makeKeyAndOrderFront: self];
	[self windowBecameMain: [NSNotification notificationWithName: @""
		object: [NSApp mainWindow]]];
	[[NSNotificationCenter defaultCenter] addObserver: self 
		selector: @selector(windowBecameMain:)
		name: NSWindowDidBecomeMainNotification
		object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self 
		selector: @selector(windowResignedMain:)
		name: NSWindowDidResignMainNotification 
		object: nil];
}

-(void)windowResignedMain: (NSNotification*)aNotification {
	id controller = [[aNotification object] windowController];
	if (controller == browserController) {
		[self setBrowserController: nil];
	}
}

-(void)windowBecameMain: (NSNotification*)aNotification {
	id controller = [[aNotification object] windowController];
	if (![controller isKindOfClass: [BrowserWindowController class]]) {
		controller = nil;
	}
	[self setBrowserController: controller];
}

-(void)setBrowserController: (id)aBrowserController {
	browserController = aBrowserController;
	BOOL enabled = browserController != nil;
	[previousButton setEnabled: enabled];
	[nextButton setEnabled: enabled];
	[matchCaseButton setEnabled: enabled];
	[showAllButton setEnabled: enabled];
}

-(void)findPrevious: (id)sender {
	[browserController findPrevious: [searchField stringValue] 
		matchCase: [matchCaseButton state] == NSOnState];
}


-(void)findNext: (id)sender {
	[browserController findNext: [searchField stringValue] 
		matchCase: [matchCaseButton state] == NSOnState];
}


-(void)showAll: (id)sender {
	[browserController showAll: [searchField stringValue] 
		matchCase: [matchCaseButton state] == NSOnState];
}


-(void)updateSearch: (id)sender {

}


-(void)toggleMatchCase: (id)sender {

}

@end
