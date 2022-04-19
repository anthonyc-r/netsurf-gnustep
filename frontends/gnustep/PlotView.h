#import <AppKit/AppKit.h>

@interface PlotView: NSView {
	void *browser;
	BOOL reallyDraw;
	BOOL isDragging;
	NSPoint dragStart;
	NSSize lastSize;
	BOOL showCaret;
	NSRect caretRect;
	BOOL didResize;
}

-(void)setBrowser: (void*)aBrowser;
-(void)placeCaretAtX: (int)x y: (int)y height: (int)height;
-(void)removeCaret;
-(void)reload: (id)sender;
-(void)stopReloading: (id)sender;
-(void)showDropdownMenuWithOptions: (NSArray*)options atLocation: (NSPoint)location control: (struct form_control*)control;
-(void)zoomIn: (id)sender;
-(void)zoomOut: (id)sender;
-(void)resetZoom: (id)sender;
@end
