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

#include <string.h>

#import "netsurf/netsurf.h"
#import "netsurf/download.h"
#import "desktop/download.h"
#import "utils/nsurl.h"
#import "DownloadManager.h"
#import "AppDelegate.h"
#import "Preferences.h"

#define CMP_HEAD(MIME,IN,EXT) if (strncmp(MIME, IN, 40) == 0) { return EXT; }
#define CMP(MIME,IN,EXT) else if (strncmp(MIME, IN, 40) == 0) { return EXT; }

static const char *getext(const char *mime) {
	CMP_HEAD ("image/jpeg", mime, "jpeg")
	CMP ("text/css", mime, "css")
	CMP ("text/html", mime, "html")
	CMP ("image/gif", mime, "gif")
	CMP ("image/png", mime, "png")
	CMP ("application/zip", mime, "zip")
	CMP ("application/gzip", mime, "gz")
	CMP ("image/webm", mime, "webm")
	CMP ("application/pdf", mime, "pdf")
	CMP ("audio/mpeg", mime, "mp3")
	CMP ("audio/wav", mime, "wav")
	CMP ("audio/webm", mime, "webm")
	CMP ("application/octet-stream", mime, "bin")
	CMP ("image/tiff", mime, "tiff")
	CMP ("audio/aac", mime, "aac")
	CMP ("audio/ogg", mime, "ogg")
	CMP ("application/x-7z-compressed", mime, "7z")
	CMP ("application/x-bzip", mime, "bz")
	CMP ("application/x-bzip2", mime, "bz2")
	CMP ("image/bmp", mime, "bmp")
	CMP ("text/csv", mime, "csv")
	CMP ("application/epub+zip", mime, "epub")
	CMP ("image/vnd.microsoft.icon", mime, "ico")
	CMP ("text/javascript", mime, "js")
	CMP ("application/json", mime, "json")
	CMP ("video/mpeg", mime, "mpeg")
	CMP ("application/rtf", mime, "rtf")
	return NULL;
}

static BOOL askwrite(NSString *filename) {
	NSAlert *alert = [[NSAlert alloc] init];
	NSString *informativeText = [NSString stringWithFormat:  @"A file named '%@' already exists, do you wish to overwrite it?\nThe existing file will be deleted.", filename];
	[alert setMessageText: @"File Exists"];
	[alert setInformativeText: informativeText];
	[alert addButtonWithTitle: @"Overwrite"];
	[alert addButtonWithTitle: @"Cancel"];
	[alert setAlertStyle: NSWarningAlertStyle];
	NSInteger result = [alert runModal];
	[alert release];
	return result == NSAlertFirstButtonReturn;
}

/**********************/
/****** Download ******/
/**********************/
// This won't really return a window ref, but a ref to a download item.
static struct gui_download_window *gnustep_download_create(struct download_context *ctx, struct gui_window *parent) {
	NSLog(@"gnustep_download_create");
	const char *name = download_context_get_filename(ctx);
	const char *mime = download_context_get_mime_type(ctx);
	const char *ext = getext(mime);
	NSString *filename;
	if (ext != NULL) {
		filename = [NSString stringWithFormat: @"%s.%s", name, ext];
	} else {
		filename = [NSString stringWithCString: name];
	}
	if ([filename length] < 1) {
		NSLog(@"Filename was empty");
		return NULL;
	}
	NSString *destination = [[[Preferences defaultPreferences] downloadLocationPath]
		stringByAppendingPathComponent: filename];

	NSURL *url = [NSURL URLWithString: destination];
	if (url == nil) {
		NSLog(@"Failed to create url with path %@", destination);
		return NULL;
	}
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath: [url absoluteString]];
	BOOL confirmOverwrites = [[Preferences defaultPreferences] confirmBeforeOverwriting];
	if (confirmOverwrites) {
		NSLog(@"Will confirm before overwriting...");
	}
	BOOL shouldProceed = !exists || !confirmOverwrites || askwrite(filename);
	if (!shouldProceed) {
		NSLog(@"Won't continue...");
		return NULL;
	}
	if (exists) {
		NSError *err = nil;
		[[NSFileManager defaultManager] removeItemAtURL: url error: &err];
		if (err != nil) {
			NSLog(@"Error deleting existing file at %@", url);
			return NULL;
		}
	}
	DownloadItem *download = [[DownloadManager defaultDownloadManager]
		createDownloadForDestination: url withContext: ctx];
	[[NSApp delegate] showDownloadsWindow: nil];
	return (struct gui_download_window*)download;
}

// ??
static nserror gnustep_download_data(struct gui_download_window *dw,	const char *data, unsigned int size) {
	BOOL success = [(id)dw appendToDownload: [NSData dataWithBytesNoCopy: (void*)data
		length: size freeWhenDone: NO]];
	if (success) {
		return NSERROR_OK;
	} else {
		return NSERROR_SAVE_FAILED;
	}
}

// Error occurred during download
static void gnustep_download_error(struct gui_download_window *dw, const char *error_msg) {
	NSLog(@"gnustep_download_error");
	[(id)dw failWithMessage: [NSString stringWithCString: error_msg]];
}

// Download completed
static void gnustep_download_done(struct gui_download_window *dw) {
	NSLog(@"gnustep_download_done");
	[(id)dw complete];
}

struct gui_download_table gnustep_download_table = {
	.create = gnustep_download_create,
	.data = gnustep_download_data,
	.error = gnustep_download_error,
	.done = gnustep_download_done
};