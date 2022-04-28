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
#import <libgen.h>
#import "utils/url.h"
#import "netsurf/fetch.h"


/*******************/
/****** Fetch ******/ 
/*******************/

// Return the MIME type of the specified file. Returned string can be inval on next req.
static const char *gnustep_fetch_filetype(const char *unix_path) {
	NSLog(@"gnustep_fetch_filetype");
	char *bnam;
	char *ext;
	
	bnam = basename(unix_path);
	ext = strrchr(bnam, '.');
	if (ext == NULL) {
		return "text/html";
	}
	ext += 1;

	if (strncmp(ext, "css", 3) == 0) {
		return "text/css";
	} else if (strncmp(ext, "jpeg", 4) == 0 || strncmp(ext, "jpg", 3) == 0) {
		return "image/jpeg";
	} else if (strncmp(ext, "gif", 3) == 0) {
		return "image/gif";
	} else if (strncmp(ext, "png", 3) == 0) {
		return "image/png";
	} else if (strncmp(ext, "txt", 3) == 0) {
		return "text/plain";
	} else {
		return "text/html";
	}
}

static const char *gnustep_fetch_get_resource_url(const char *path) {
	struct nsurl *url = NULL;
	NSString *nspath = [[NSBundle mainBundle] pathForResource: [NSString 
		stringWithUTF8String: path] ofType: @""];
	if (nspath == nil) {
		return NULL;
	}
	nsurl_create([[[NSURL fileURLWithPath: nspath] absoluteString] UTF8String], &url);
	return url;
}

struct gui_fetch_table gnustep_fetch_table = {
	.filetype = gnustep_fetch_filetype,
	.get_resource_url = gnustep_fetch_get_resource_url
};
