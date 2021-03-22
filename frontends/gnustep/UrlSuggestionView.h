#import <Cocoa/Cocoa.h>

@class UrlSuggestionView;

@protocol UrlSuggestionViewDelegate
-(void)urlSuggestionView: (UrlSuggestionView*)urlSuggestionView didPickUrl: (NSString*)url;
@end

@interface UrlSuggestionView: NSTableView {

}

-(id)initForUrlBar: (NSTextField*)aUrlBar;
-(void)updateQuery: (NSString*)aQuery;
-(void)dismiss;

@end
