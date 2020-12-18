
THIS FORK
=======

This fork aims at getting a usable version of NetSurf running under the
GNUstep library. I will note that there is (I think) a working update of
the old cocoa port, checkout github/mmuman's repos for this. However,
this port requires CoreFoundation, and CoreGraphics dependencies. While there
are GNUstep implementations of these, they're underdeveloped, and indeed, I 
couldn't get them to build under OpenBSD.

So, this port aims at a ground-up GNUstep-specific (Perhaps it would compile 
under MacOS, perhaps not, I don't particularly care about this platform) port,
making liberal use of code snippets from the cocoa port where possible. For
example large chunks of the plotter and font functions are pulled from the 
cocoa port.

This port compiles with just basic GNUstep base, gui, and back libraries 
unlike the cocoa port.

Current State
----------------
Works for basic use, can navigate to, and browse websites.

What still needs doing
----------------
Tabs, bookmarks, history,
other bits and bobs probably.


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
