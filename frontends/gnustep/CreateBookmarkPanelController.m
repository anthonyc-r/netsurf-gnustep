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
#import "CreateBookmarkPanelController.h"
#import "Website.h"
#import "BookmarkFolder.h"

@implementation CreateBookmarkPanelController

-(id)initForWebsite: (Website*)aWebsite {
	if ((self = [super initWithWindowNibName: @"CreateBookmark"])) {
		website = [aWebsite retain];
		bookmarkFolders = [[BookmarkFolder allFolders] retain];
	}
	return self;
}

-(void)dealloc {
	[website release];
	[bookmarkFolders release];
	[super dealloc];
}

-(void)awakeFromNib {
	NSLog(@"Awoke from nib");
	[nameField setStringValue: [website name]]; 
	for (NSUInteger i = 0; i < [bookmarkFolders count]; i++) {
		[folderButton addItemWithTitle: [[bookmarkFolders objectAtIndex: i]
			name]];
	}
}

-(void)didTapCancel: (id)sender {
	[self close];
}

-(void)didTapOkay: (id)sender {
	Website *toSave = [[Website alloc] initWithName: [nameField stringValue]
		url: [website url]];
	BookmarkFolder *destination = [bookmarkFolders objectAtIndex: [folderButton
		indexOfSelectedItem]];
	[destination addChild: toSave];
	[[NSNotificationCenter defaultCenter] postNotificationName: 
		BookmarksUpdatedNotificationName object: self];
	[toSave release];
	[self close];
}

@end
