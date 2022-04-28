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

#import "netsurf/netsurf.h"
#import "netsurf/search.h"


/********************/
/****** Search ******/
/********************/

// Change displayed search status found/notfound?
static void gnustep_search_status(bool found, void *p) {
	NSLog(@"gnustep_search_status");
	[(id)p setFound: found ? YES : NO];
}

// Show hourglass if active else stop hourglass
static void gnustep_search_hourglass(bool active, void *p) {
	NSLog(@"gnustep_search_hourglass");
}

// Add search string to recent searches list
static void gnustep_search_add_recent(const char *string, void *p) {
	NSLog(@"gnustep_search_add_recent");
}

// Set the next match button to active/inactive
static void gnustep_search_forward_state(bool active, void *p) {
	NSLog(@"gnustep_search_forward_state");
	[(id)p setCanFindNext: active ? YES : NO];
}

// set the previous match button to active/inactive
static void gnustep_search_back_state(bool active, void *p) {
	NSLog(@"gnustep_search_back_state");
	[(id)p setCanFindPrevious: active ? YES : NO];
}

struct gui_search_table gnustep_search_table = {
	.status = gnustep_search_status,
	.hourglass = gnustep_search_hourglass,
	.add_recent = gnustep_search_add_recent,
	.forward_state = gnustep_search_forward_state,
	.back_state = gnustep_search_back_state
};