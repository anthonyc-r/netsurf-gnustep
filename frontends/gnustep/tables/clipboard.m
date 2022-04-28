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
#import <string.h>

#import "netsurf/netsurf.h"
#import "netsurf/clipboard.h"

/***********************/
/****** Clipboard ******/
/***********************/

// Put content of clipboard into buffer up to a maximum length
static void gnustep_clipboard_get(char **buffer, size_t *length) {
	NSLog(@"gnustep_clipboard_get");
	NSString *pb = [[NSPasteboard generalPasteboard] stringForType: NSStringPboardType];
	char *cstring = "";
	int len = 0;
	if (pb) {
		cstring = [pb cString];
		len = [pb cStringLength];
	}
	*length = len;
	*buffer = malloc(len + 1);
	strncpy(*buffer, cstring, len);
	(*buffer)[len] = '\0';
}

// Save the provided clipboard for later retreival above
static void gnustep_clipboard_set(const char *buffer, size_t length, nsclipboard_styles styles[], int n_styles) {
	NSLog(@"gnustep_clipboard_set");
	NSString *pb = [NSString stringWithCString: buffer length: length];
	[[NSPasteboard generalPasteboard] setString: pb forType: NSStringPboardType];
}

struct gui_clipboard_table gnustep_clipboard_table = {
	.get = gnustep_clipboard_get,
	.set = gnustep_clipboard_set
};
