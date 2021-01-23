
THIS FORK
=======

This fork aims at getting a usable version of NetSurf running under the
GNUstep library. I will note that there is (I think) a working update of
the old cocoa port, checkout github/mmuman's repos for this. However,
this port requires CoreFoundation, and CoreGraphics dependencies. This 
port compiles with just basic GNUstep base, gui, and back libraries 
unlike the cocoa port.

![Screenshot](/screenshots/screenshot.jpeg)
With Rik theme, client side decorations and mac-style menu.

Current State
----------------
Works pretty well, has history, download management, bookmarks.

What still needs doing
----------------
Tabs, preferences, other bits and bobs probably.


This has only been tested on OpenBSD macppc, there's probably issues with
the Makefile on other platforms.


Props to Sven Weidauer for the original cocoa port. Original copyright notice
has been included in files consisting of large parts of his work.

ORIGINAL NETSURF README
----------------

NetSurf
=======

This document should help point you at various useful bits of information.


Building NetSurf
----------------

Read the [Quick Start](docs/quick-start.md) document for instructions.


Creating a new port
-------------------

Look at the existing front ends for example implementations.
The framebuffer front end is simplest and most self-contained.
Also, you can [contact the developers](http://www.netsurf-browser.org/contact/)
for help.


Further documentation
---------------------

* [Developer documentation](http://www.netsurf-browser.org/developers/)
* [Developer wiki](http://wiki.netsurf-browser.org/Documentation/)
* [Code style guide](http://www.netsurf-browser.org/developers/StyleGuide.pdf)
