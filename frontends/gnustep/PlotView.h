#include <AppKit/AppKit.h>

@interface PlotView: NSView {
	void *browser;
}

-(void)setBrowser: (void*)aBrowser;

@end
