/*
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "NetsurfCallback.h"
#import "Website.h"

#define TAG_MENU_REMOVE 206
#define TAG_MENU_CANCEL 204
#define TAG_MENU_OPEN 104
#define TAG_MENU_COPY 202
#define TAG_MENU_CUT 201
#define TAG_MENU_PASTE 203
#define TAG_SUBMENU_HISTORY 500
#define TAG_SUBMENU_BOOKMARKS 900

@interface AppDelegate: NSResponder<NSApplicationDelegate> {
@private
NSMutableArray *recentHistory;
id downloadsWindowController;
id findPanelController;
id historyWindowController;
id bookmarksWindowController;
id preferencesWindowController;
}

-(void)showFindPanel: (id)sender;
-(void)showDownloadsWindow: (id)sender;
-(void)showHistoryWindow: (id)sender;
-(void)showBookmarksWindow: (id)sender;
-(void)showPreferencesWindow: (id)sender;
-(NSURL*)requestDownloadDestination;
-(void)openWebsite: (Website*)aWebsite;

@end
