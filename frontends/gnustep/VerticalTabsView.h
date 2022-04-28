/*
 * Copyright 2022 Anthony Cohn-Richardby <anthonyc@gmx.co.uk>
 *
 * This file is part of NetSurf, http://www.netsurf-browser.org/
 *
 * NetSurf is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 * NetSurf is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
-(void)setDelegate: (id<VerticalTabsViewDelegate>)aDelegate;
@end
