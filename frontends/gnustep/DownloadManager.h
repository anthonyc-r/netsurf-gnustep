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

@class DownloadManager;
@class DownloadItem;
struct download_context;

@protocol DownloadManagerDelegate
-(void)downloadManagerDidAddDownload: (DownloadManager*)aDownloadManager;
-(void)downloadManager: (DownloadManager*)aDownloadManager didRemoveItems: (NSArray*)downloadItems;
-(void)downloadManager: (DownloadManager*)aDownloadManager didUpdateItem: (DownloadItem*)aDownloadItem;
@end

@interface DownloadItem: NSObject {
	BOOL completed;
	BOOL cancelled;
	NSUInteger size;
	NSUInteger confirmedSize, sizeUntilNow;
	NSLock *confirmedSizeLock;
	NSUInteger written;
	NSInteger index;
	NSDate *startDate;
	NSURL *destination;
	NSOutputStream *outputStream;
	NSString *error;
	BOOL runThread;
	NSThread *downloadThread;
	DownloadManager *manager;
	NSTimeInterval lastWrite;
	struct download_context *ctx;
}
-(BOOL)appendToDownload: (NSData*)data;
-(void)cancel;
-(void)complete;
-(BOOL)isComplete;
-(BOOL)isCancelled;
-(void)failWithMessage: (NSString*)message;
-(NSURL*)destination;
-(NSString*)detailsText;
-(NSString*)remainingText;
-(NSString*)speedText;
-(double)completionProgress;
-(NSInteger)index;
@end

@interface DownloadManager: NSObject {
	NSMutableArray *downloads;
	id<DownloadManagerDelegate> delegate;
}
+(DownloadManager*)defaultDownloadManager;
-(DownloadItem*)createDownloadForDestination: (NSURL*)path withContext: (struct download_context*)ctx;
-(NSArray*)downloads;
-(void)removeDownloadsAtIndexes: (NSIndexSet*)anIndexSet;
-(void)cancelDownloadsAtIndexes: (NSIndexSet*)anIndexSet;
-(void)openDownloadAtIndex: (NSInteger)index;
-(id)delegate;
-(void)setDelegate: (id<DownloadManagerDelegate>)aDelegate;
@end