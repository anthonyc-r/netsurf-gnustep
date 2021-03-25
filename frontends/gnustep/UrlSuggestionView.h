#import <Cocoa/Cocoa.h>

@class UrlSuggestionView;

@protocol UrlSuggestionViewDelegate
-(void)urlSuggestionView: (UrlSuggestionView*)urlSuggestionView didPickUrl: (NSString*)url;
@end

@interface UrlSuggestionView: NSScrollView<NSTableViewDataSource, NSTableViewDelegate> {
	id urlBar;
	BOOL isActive;
	NSTableView *tableView;
	NSArray *recentWebsites;
	NSMutableArray *filteredWebsites;
	NSString *previousQuery;
}

-(id)initForUrlBar: (NSTextField*)aUrlBar;
-(void)dismiss;

@end
