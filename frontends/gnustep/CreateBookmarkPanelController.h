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
#import "Website.h"
#import "BookmarkFolder.h"

@interface CreateBookmarkPanelController : NSWindowController {
	id nameField;
	id folderButton;
	Website *website;
	NSArray *bookmarkFolders;

}
-(id)initForWebsite: (Website*)aWebsite;
-(void)didTapOkay: (id)sender;
-(void)didTapCancel: (id)sender;
@end
