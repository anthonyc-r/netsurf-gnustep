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

#import "netsurf/window.h"
#import "netsurf/clipboard.h"
#import "netsurf/download.h"
#import "netsurf/fetch.h"
#import "netsurf/search.h"
#import "netsurf/layout.h"
#import "netsurf/bitmap.h"

extern struct gui_window_table gnustep_window_table;
extern struct gui_clipboard_table gnustep_clipboard_table;
extern struct gui_download_table gnustep_download_table;
extern struct gui_fetch_table gnustep_fetch_table;
extern struct gui_search_table gnustep_search_table;
extern struct gui_bitmap_table gnustep_bitmap_table;
extern struct gui_layout_table gnustep_layout_table;