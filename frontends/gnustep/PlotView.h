#include <AppKit/AppKit.h>

@interface PlotView: NSView {
	void *browser;
	BOOL reallyDraw;
	BOOL isDragging;
	NSPoint dragStart;
	NSSize lastSize;
}

-(void)setBrowser: (void*)aBrowser;

@end
