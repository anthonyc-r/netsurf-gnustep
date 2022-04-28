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
#import "FindPanelController.h"
#import "BrowserWindowController.h"

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
