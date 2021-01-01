#import <Cocoa/Cocoa.h>

@interface HistoryWindowController: NSWindowController {
	id outlineView;
	id searchBar;
	NSString *searchValue;
	NSMutableArray *sections;
}

-(void)search: (id)sender;
-(void)clearSearch: (id)sender;
@end