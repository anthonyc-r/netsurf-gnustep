#include <AppKit/AppKit.h>

@interface FindPanelController : NSWindowController {
	id previousButton;
	id nextButton;
	id matchCaseButton;
	id searchField;
	id showAllButton;
	id browserController;
	id noResultsLabel;
}
-(void)setBrowserController: (id)aBrowserController;
-(void)findPrevious: (id)sender;
-(void)findNext: (id)sender;
-(void)showAll: (id)sender;
-(void)updateSearch: (id)sender;
-(void)toggleMatchCase: (id)sender;

// Interface for use by search.h table
-(void)setFound: (BOOL)found;
-(void)setCanFindNext: (BOOL)canFindNext;
-(void)setCanFindPrevious: (BOOL)canFindPrevious;
@end
