#import <Cocoa/Cocoa.h>

@class UrlSuggestionView;

@protocol UrlSuggestionViewDelegate
-(void)urlSuggestionView: (UrlSuggestionView*)urlSuggestionView didPickUrl: (NSString*)url;
@end

@interface UrlSuggestionView: NSTableView {
	id urlBar;
	BOOL isActive;
}

-(id)initForUrlBar: (NSTextField*)aUrlBar;
-(void)dismiss;

@end
