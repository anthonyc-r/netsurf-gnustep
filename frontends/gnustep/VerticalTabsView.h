#import <Cocoa/Cocoa.h>

@class VerticalTabsView;

@protocol VerticalTabsViewItem
-(NSString*)label;
@end

@protocol VerticalTabsViewDelegate
-(void)verticalTabsView: (VerticalTabsView*)verticalTabsView didSelectTab: (id<VerticalTabsViewItem>)aTab;
@end

@interface VerticalTabsView: NSScrollView<NSTableViewDataSource, NSTableViewDelegate> {
	NSArray *tabItems;
	id tableView;
	id<VerticalTabsViewDelegate> delegate;
}

-(id)initWithTabs: (NSArray *)someTabItems;
-(void)reloadTabs;
-(void)setSelectedTab: (id<VerticalTabsViewItem>)aTab;
@end
