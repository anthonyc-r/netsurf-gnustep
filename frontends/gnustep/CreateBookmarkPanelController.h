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
