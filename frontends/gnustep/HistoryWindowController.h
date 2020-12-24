#import <Cocoa/Cocoa.h>

@interface HistoryWindowController: NSWindowController {
	id outlineView;
	NSMutableDictionary *historyItems;
}

@end