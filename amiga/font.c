/*
 * Copyright 2008 - 2016 Chris Young <chris@unsatisfactorysoftware.co.uk>
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

#include "amiga/os3support.h"

#include <proto/diskfont.h>
#include <proto/exec.h>
#include <proto/graphics.h>

#include "utils/log.h"
#include "utils/nsoption.h"
#include "desktop/browser.h"
#include "desktop/font.h"

#include "amiga/font.h"
#include "amiga/font_bullet.h"
#include "amiga/font_diskfont.h"
#include "amiga/font_scan.h"

void ami_font_setdevicedpi(int id)
{
	DisplayInfoHandle dih;
	struct DisplayInfo dinfo;
	ULONG ydpi = nsoption_int(screen_ydpi);
	ULONG xdpi = nsoption_int(screen_ydpi);

	if(nsoption_bool(bitmap_fonts) == true) {
		LOG("WARNING: Using diskfont.library for text. Forcing DPI to 72.");
		nsoption_int(screen_ydpi) = 72;
	}

	browser_set_dpi(nsoption_int(screen_ydpi));

	if(id && (nsoption_int(monitor_aspect_x) != 0) && (nsoption_int(monitor_aspect_y) != 0))
	{
		if((dih = FindDisplayInfo(id)))
		{
			if(GetDisplayInfoData(dih, &dinfo, sizeof(struct DisplayInfo),
				DTAG_DISP, 0))
			{
				int xres = dinfo.Resolution.x;
				int yres = dinfo.Resolution.y;

				if((nsoption_int(monitor_aspect_x) != 4) || (nsoption_int(monitor_aspect_y) != 3))
				{
					/* AmigaOS sees 4:3 modes as square in the DisplayInfo database,
					 * so we correct other modes to "4:3 equiv" here. */
					xres = (xres * nsoption_int(monitor_aspect_x)) / 4;
					yres = (yres * nsoption_int(monitor_aspect_y)) / 3;
				}

				xdpi = (yres * ydpi) / xres;

				LOG("XDPI = %ld, YDPI = %ld (DisplayInfo resolution %d x %d, corrected %d x %d)", xdpi, ydpi, dinfo.Resolution.x, dinfo.Resolution.y, xres, yres);
			}
		}
	}

	ami_xdpi = xdpi;
	ami_devicedpi = (xdpi << 16) | ydpi;
}

/* The below are simple font routines which should not be used for page rendering */

struct TextFont *ami_font_open_disk_font(struct TextAttr *tattr)
{
	struct TextFont *tfont = OpenDiskFont(tattr);
	return tfont;
}

void ami_font_close_disk_font(struct TextFont *tfont)
{
	CloseFont(tfont);
}

/* Font initialisation */
void ami_font_init(void)
{
	if(nsoption_bool(bitmap_fonts) == false) {
		ami_font_bullet_init();
	} else {
		ami_font_diskfont_init();
	}
}

void ami_font_fini(void)
{
	if(nsoption_bool(bitmap_fonts) == false) {
		ami_font_bullet_fini();
	}
}

/* Stub entry points */
static bool nsfont_width(const plot_font_style_t *fstyle,
		const char *string, size_t length,
		int *width)
{
	if(__builtin_expect(ami_nsfont == NULL, 0)) return false;
	return ami_nsfont->width(fstyle, string, length, width);
}

static bool nsfont_position_in_string(const plot_font_style_t *fstyle,
		const char *string, size_t length,
		int x, size_t *char_offset, int *actual_x)
{
	if(__builtin_expect(ami_nsfont == NULL, 0)) return false;
	return ami_nsfont->posn(fstyle, string, length, x, char_offset, actual_x);
}

static bool nsfont_split(const plot_font_style_t *fstyle,
		const char *string, size_t length,
		int x, size_t *char_offset, int *actual_x)
{
	if(__builtin_expect(ami_nsfont == NULL, 0)) return false;
	return ami_nsfont->split(fstyle, string, length, x, char_offset, actual_x);
}

const struct font_functions nsfont = {
	nsfont_width,
	nsfont_position_in_string,
	nsfont_split
};

