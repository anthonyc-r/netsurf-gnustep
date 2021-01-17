#include <AppKit/AppKit.h>
#include "BookmarkFolder.h"

@interface BookmarksWindowController: NSWindowController {
	id outlineView;
	id searchBar;
	NSArray *topLevelFolders;
	BOOL isCutting;
	NSArray *copiedItems;
}
-(void)search: (id)sender;
-(void)clearSearch: (id)sender;
-(void)newFolder: (id)sender;
-(void)open: (id)sender;
-(void)cut: (id)sender;
-(void)copy: (id)sender;
-(void)paste: (id)sender;
-(void)remove: (id)sender;
@end
