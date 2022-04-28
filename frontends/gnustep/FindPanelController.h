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
 
#import <AppKit/AppKit.h>

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
