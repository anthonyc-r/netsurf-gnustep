/*
 * This file is part of NetSurf, http://netsurf.sourceforge.net/
 * Licensed under the GNU General Public License,
 *                http://www.opensource.org/licenses/gpl-license
 * Copyright 2004 James Bursa <bursa@users.sourceforge.net>
 */

#include "libxml/HTMLparser.h"
#include "netsurf/content/content.h"
#include "netsurf/render/html.h"
#include "netsurf/render/textplain.h"
#include "netsurf/utils/messages.h"


static const char header[] = "<html><body><pre>";
static const char footer[] = "</pre></body></html>";


bool textplain_create(struct content *c, const char *params[])
{
	if (!html_create(c, params))
		/* html_create() must have broadcast MSG_ERROR already, so we
		 * don't need to. */
		return false;
	htmlParseChunk(c->data.html.parser, header, sizeof(header) - 1, 0);
	return true;
}

bool textplain_process_data(struct content *c, char *data,
		unsigned int size)
{
	unsigned int i, s;
	char *d, *p;
	union content_msg_data msg_data;
	bool ret;

	/* count number of '<' in data buffer */
	for (d = data, i = 0, s = 0; i != size; i++, d++) {
		if (*d == '<')
			s++;
	}

	/* create buffer for modified input */
	d = calloc(size + 3*s, sizeof(char));
	if (!d) {
		msg_data.error = messages_get("NoMemory");
		content_broadcast(c, CONTENT_MSG_ERROR, msg_data);
		return false;
	}

	/* copy data across to modified buffer,
	 * replacing occurrences of '<' with '&lt;'
	 * This prevents the parser stripping sequences of '<...>'
	 */
	for (p = d, i = 0, s = 0; i != size; i++, data++) {
		if (*data == '<') {
			*p++ = '&';
			*p++ = 'l';
			*p++ = 't';
			*p++ = ';';
			s += 4;
		}
		else {
			*p++ = *data;
			s++;
		}
	}

	ret = html_process_data(c, d, s);

	free(d);

	return ret;
}

bool textplain_convert(struct content *c, int width, int height)
{
	htmlParseChunk(c->data.html.parser, footer, sizeof(footer) - 1, 0);
	c->type = CONTENT_HTML;
	return html_convert(c, width, height);
}
