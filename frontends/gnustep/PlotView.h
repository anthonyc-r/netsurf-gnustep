#include <AppKit/AppKit.h>

@interface PlotView: NSView {
	void *browser;
	BOOL reallyDraw;
	BOOL isDragging;
	NSPoint dragStart;
}

-(void)setBrowser: (void*)aBrowser;

@end
