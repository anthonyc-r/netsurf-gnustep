#import <Cocoa/Cocoa.h>

@interface HistoryWindowController: NSWindowController {
	id outlineView;
	BOOL ignoreRefresh;
	NSMutableDictionary *historyItems;
}

@end