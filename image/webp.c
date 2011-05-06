 /*
 * Copyright 2010 Chris Young <chris@unsatisfactorysoftware.co.uk>
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

/** \file
 * Content for image/webp (libwebp implementation).
 *
 */

#include "utils/config.h"
#ifdef WITH_WEBP

#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <webp/decode.h>
#include "desktop/plotters.h"
#include "image/bitmap.h"
#include "content/content_protected.h"
#include "utils/log.h"
#include "utils/messages.h"
#include "utils/talloc.h"
#include "utils/utils.h"

typedef struct webp_content
{
	struct content base;
} webp_content;

static nserror webp_create(const content_handler *handler,
		lwc_string *imime_type, const http_parameter *params,
		llcache_handle *llcache, const char *fallback_charset,
		bool quirks, struct content **c);
static bool webp_convert(struct content *c);
static void webp_destroy(struct content *c);
static bool webp_redraw(struct content *c, int x, int y,
		int width, int height, const struct rect *clip,
		float scale, colour background_colour);
static nserror webp_clone(const struct content *old, struct content **newc);
static content_type webp_content_type(lwc_string *mime_type);

static const content_handler webp_content_handler = {
	webp_create,
	NULL,
	webp_convert,
	NULL,
	webp_destroy,
	NULL,
	NULL,
	NULL,
	webp_redraw,
	NULL,
	NULL,
	NULL,
	webp_clone,
	NULL,
	webp_content_type,
	false
};

static const char *webp_types[] = {
	"image/webp"
};

static lwc_string *webp_mime_types[NOF_ELEMENTS(webp_types)];

nserror webp_init(void)
{
	uint32_t i;
	lwc_error lerror;
	nserror error;

	for (i = 0; i < NOF_ELEMENTS(webp_mime_types); i++) {
		lerror = lwc_intern_string(webp_types[i],
				strlen(webp_types[i]),
				&webp_mime_types[i]);
		if (lerror != lwc_error_ok) {
			error = NSERROR_NOMEM;
			goto error;
		}

		error = content_factory_register_handler(webp_mime_types[i],
				&webp_content_handler);
		if (error != NSERROR_OK)
			goto error;
	}

	return NSERROR_OK;

error:
	webp_fini();

	return error;
}

void webp_fini(void)
{
	uint32_t i;

	for (i = 0; i < NOF_ELEMENTS(webp_mime_types); i++) {
		if (webp_mime_types[i] != NULL)
			lwc_string_unref(webp_mime_types[i]);
	}
}

nserror webp_create(const content_handler *handler,
		lwc_string *imime_type, const http_parameter *params,
		llcache_handle *llcache, const char *fallback_charset,
		bool quirks, struct content **c)
{
	webp_content *webp;
	nserror error;

	webp = talloc_zero(0, webp_content);
	if (webp == NULL)
		return NSERROR_NOMEM;

	error = content__init(&webp->base, handler, imime_type, params,
			llcache, fallback_charset, quirks);
	if (error != NSERROR_OK) {
		talloc_free(webp);
		return error;
	}

	*c = (struct content *) webp;

	return NSERROR_OK;
}

/**
 * Convert a CONTENT_WEBP for display.
 *
 * No conversion is necessary. We merely read the WebP dimensions.
 */

bool webp_convert(struct content *c)
{
	union content_msg_data msg_data;
	const uint8_t *data;
	unsigned char *imagebuf = NULL;
	unsigned long size;
	int width = 0, height = 0;
	char title[100];
	int res = 0;
	uint8_t *res_p = NULL;

	data = (uint8_t *)content__get_source_data(c, &size);

	res = WebPGetInfo(data, size, &width, &height);
	if (res == 0) {
		msg_data.error = messages_get("NoMemory");
		content_broadcast(c, CONTENT_MSG_ERROR, msg_data);
		return false;
	}

	c->bitmap = bitmap_create(width, height, BITMAP_NEW | BITMAP_OPAQUE);
	if (!c->bitmap) {
		msg_data.error = messages_get("NoMemory");
		content_broadcast(c, CONTENT_MSG_ERROR, msg_data);
		return false;
	}

	imagebuf = bitmap_get_buffer(c->bitmap);
	if (!imagebuf) {
		msg_data.error = messages_get("NoMemory");
		content_broadcast(c, CONTENT_MSG_ERROR, msg_data);
		return false;
	}
	unsigned int row_width = bitmap_get_rowstride(c->bitmap);

	res_p = WebPDecodeRGBAInto(data, size, imagebuf,
				row_width * height, row_width);
	if (res_p == NULL) {
		msg_data.error = messages_get("NoMemory");
		content_broadcast(c, CONTENT_MSG_ERROR, msg_data);
		return false;
	}

	c->width = width;
	c->height = height;
	snprintf(title, sizeof(title), messages_get("WebPTitle"),
		width, height, size);
	content__set_title(c, title);

	bitmap_modified(c->bitmap);

	content_set_ready(c);
	content_set_done(c);

	content_set_status(c, "");
	return true;
}


/**
 * Destroy a CONTENT_WEBP and free all resources it owns.
 */

void webp_destroy(struct content *c)
{
	if (c->bitmap != NULL)
		bitmap_destroy(c->bitmap);
}


/**
 * Redraw a CONTENT_WEBP.
 */

bool webp_redraw(struct content *c, int x, int y,
		int width, int height, const struct rect *clip,
		float scale, colour background_colour)
{
	return plot.bitmap(x, y, width, height,
			c->bitmap, background_colour, BITMAPF_NONE);
}


nserror webp_clone(const struct content *old, struct content **newc)
{
	webp_content *webp;
	nserror error;

	webp = talloc_zero(0, webp_content);
	if (webp == NULL)
		return NSERROR_NOMEM;

	error = content__clone(old, &webp->base);
	if (error != NSERROR_OK) {
		content_destroy(&webp->base);
		return error;
	}

	/* Simply replay convert */
	if (old->status == CONTENT_STATUS_READY ||
			old->status == CONTENT_STATUS_DONE) {
		if (webp_convert(&webp->base) == false) {
			content_destroy(&webp->base);
			return NSERROR_CLONE_FAILED;
		}
	}

	*newc = (struct content *) webp;

	return NSERROR_OK;
}

content_type webp_content_type(lwc_string *mime_type)
{
	return CONTENT_IMAGE;
}

#endif
