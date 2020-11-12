#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "AppDelegate.h"


@implementation AppDelegate 

-(void)applicationDidFinishLaunching: (NSNotification*)aNotification {
	NSLog(@"NSApp did finish launching..");
	[NSBundle loadNibNamed: @"NetSurf" owner: self];
}

@end

int main(int argc, char **argv) {	
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSApplication *app = [NSApplication sharedApplication];
	AppDelegate *delegate = [AppDelegate new];
	[app setDelegate: delegate];
	[app run];
	[pool release];
	return 0;
}