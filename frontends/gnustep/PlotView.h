#include <AppKit/AppKit.h>

@interface PlotView: NSView {
	void *browser;
	BOOL reallyDraw;
}

-(void)setBrowser: (void*)aBrowser;

@end
