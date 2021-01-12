#include <AppKit/AppKit.h>
#include "BookmarkFolder.h"

@interface BookmarksWindowController: NSWindowController {
	id outlineView;
	id searchBar;
	NSArray *topLevelFolders;
}
-(void)search: (id)sender;
-(void)clearSearch: (id)sender;
-(void)newFolder: (id)sender;
@end
