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
	[noResultsLabel setHidden: YES];
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
	[previousButton setEnabled: NO];
	[nextButton setEnabled: NO];
	[showAllButton setEnabled: NO];
}

-(void)findPrevious: (id)sender {
	[browserController findPrevious: [searchField stringValue] 
		matchCase: [matchCaseButton state] == NSOnState sender: self];
}


-(void)findNext: (id)sender {
	[browserController findNext: [searchField stringValue] 
		matchCase: [matchCaseButton state] == NSOnState sender: self];
}


-(void)showAll: (id)sender {
	[browserController showAll: [searchField stringValue] 
		matchCase: [matchCaseButton state] == NSOnState sender: self];
}


-(void)updateSearch: (id)sender {
	if (browserController != nil) {
		[self findNext: sender];
	}
}


-(void)toggleMatchCase: (id)sender {

}

-(void)setFound: (BOOL)found {
	[noResultsLabel setHidden: found];
	[showAllButton setEnabled: found];
}

-(void)setCanFindNext: (BOOL)canFindNext {
	[nextButton setEnabled: canFindNext];
}

-(void)setCanFindPrevious: (BOOL)canFindPrevious {
	[previousButton setEnabled: canFindPrevious];
}

@end
