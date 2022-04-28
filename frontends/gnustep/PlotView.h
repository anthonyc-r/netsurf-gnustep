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

@interface PlotView: NSView {
	void *browser;
	BOOL reallyDraw;
	BOOL isDragging;
	NSPoint dragStart;
	NSSize lastSize;
	BOOL showCaret;
	NSRect caretRect;
	BOOL didResize;
}

-(void)setBrowser: (void*)aBrowser;
-(void)placeCaretAtX: (int)x y: (int)y height: (int)height;
-(void)removeCaret;
-(void)reload: (id)sender;
-(void)stopReloading: (id)sender;
-(void)showDropdownMenuWithOptions: (NSArray*)options atLocation: (NSPoint)location control: (struct form_control*)control;
-(void)zoomIn: (id)sender;
-(void)zoomOut: (id)sender;
-(void)resetZoom: (id)sender;
@end
