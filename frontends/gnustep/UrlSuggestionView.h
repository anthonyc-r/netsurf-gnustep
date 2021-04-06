#import <Cocoa/Cocoa.h>

@class BrowserWindowController;
@class UrlSuggestionView;

@protocol UrlSuggestionViewDelegate
-(void)urlSuggestionView: (UrlSuggestionView*)urlSuggestionView didPickUrl: (NSString*)url;
@end

@interface UrlSuggestionView: NSScrollView<NSTableViewDataSource, NSTableViewDelegate> {
	// Not Retained
	id urlBar;
	id browserWindowController;
	
	BOOL isActive;
	NSTableView *tableView;
	NSArray *recentWebsites;
	NSMutableArray *filteredWebsites;
	NSString *previousQuery;
	NSInteger highlightedRow;
}

-(id)initForUrlBar: (NSTextField*)aUrlBar inBrowserWindowController: (BrowserWindowController*)aBrowserWindowController;
-(void)dismiss;

@end
