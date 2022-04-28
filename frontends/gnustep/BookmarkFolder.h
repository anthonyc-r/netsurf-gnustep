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
 
#import <Cocoa/Cocoa.h>

/*
* This notification is actually posted in the CreateBookmarkPanel, and
* BookmarksWindowController, Rather than calling it in the individual mutating methods
* to avoid spamming it for bulk operations, which only the above classes know about.
*/
#define BookmarksUpdatedNotificationName @"BookmarksUpdatedNotification"

#define BOOKMARKS_PATH @"/.config/NetSurf/Bookmarks"
#define UNSORTED_NAME @"Unsorted"

@interface BookmarkFolder: NSObject {
	NSString *name;
	NSString *path;
	NSMutableArray *children;
	BookmarkFolder *parentFolder;
}

-(id)initWithName: (NSString*)aName parent: (BookmarkFolder*)aParent;
-(BookmarkFolder*)parentFolder;
-(NSArray*)children;
-(NSArray*)childrenApplyingFilter: (NSString*)filter;
-(NSArray*)childFolders;
-(NSString*)name;
-(BOOL)isRootFolder;
-(BOOL)isUnsortedFolder;
-(void)addCopy: (id)item;
-(void)addChild: (id)child;
-(void)removeChild: (id)child;
-(void)updateChild: (id)child;
-(void)moveChild: (id)child toOtherFolder: (BookmarkFolder*)otherFolder;
-(void)setName: (NSString*)aName;

+(BookmarkFolder*)rootBookmarkFolder;
+(BookmarkFolder*)unsortedBookmarkFolder;
+(NSArray*)allFolders;
@end