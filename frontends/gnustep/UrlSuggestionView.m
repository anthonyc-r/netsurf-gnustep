#import <Cocoa/Cocoa.h>
#import "UrlSuggestionView.h"
#import "BrowserWindowController.h"
#import "Preferences.h"

#define ENTRY_HEIGHT 25
#define MAX_HEIGHT 200

@interface UrlSuggestionView(Private)
-(void)updateActivationState;
-(void)onPreferencesUpdated: (NSNotification*)aNotification;
-(void)onUrlContentsChanged: (NSNotification*)aNotification;
-(void)updateQuery: (NSString*)query;
@end

@implementation UrlSuggestionView

-(id)initForUrlBar: (NSTextField*)aUrlBar inBrowserWindowController: (BrowserWindowController*)aBrowserWindowController {
	if ((self = [super init])) {
		urlBar = aUrlBar;
		browserWindowController = aBrowserWindowController;
		NSRect frame = [aUrlBar frame];
		frame.size.height = 0;
		[self setFrame: frame];
 	 	[[NSNotificationCenter defaultCenter] addObserver: self
 			 selector: @selector(onPreferencesUpdated:)
 			 name: PreferencesUpdatedNotificationName
 			 object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self
			selector: @selector(onUrlContentsChanged:)
			name: NSControlTextDidChangeNotification
			object: urlBar];
		[self updateActivationState];
		[self setAutoresizingMask: [aUrlBar autoresizingMask]];
		tableView = [[NSTableView alloc] init];
		[tableView setDelegate: self];
		[tableView setDataSource: self];
		[tableView setRowHeight: ENTRY_HEIGHT];
		NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier: @"name"];
		[col setEditable: NO];
		[col setWidth: frame.size.width];
		[tableView addTableColumn: col];
		[col release];
		[tableView setHeaderView: nil];
		[self setDocumentView: tableView];
		[tableView release];
		
		[[aUrlBar superview] addSubview: self];
	}
	return self;
}

-(void)dealloc {
	[filteredWebsites release];
	[recentWebsites release];
	[previousQuery release];
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[super dealloc];
}

-(void)dismiss {

}

-(void)onPreferencesUpdated: (NSNotification*)aNotification {
	NSDictionary *dict = [aNotification object];
	PreferenceType type = (PreferenceType)[[dict objectForKey: @"type"]
		integerValue];
	if (type == PreferenceTypeShowUrlSuggestions) {
		[self updateActivationState];
	}
}

-(void)updateActivationState {
	isActive = [[Preferences defaultPreferences] showUrlSuggestions];
	if (isActive) {
		[self setHidden: NO];

	} else {
		[self setHidden: YES];

	}
}

-(void)onUrlContentsChanged: (NSNotification*)aNotification {
	NSLog(@"contents changed?!");
	if (!isActive) {
		return;
	}
	id editor = [[aNotification userInfo] objectForKey: @"NSFieldEditor"];
	NSString *query = [editor string];
	[self updateQuery: query];
}

-(void)updateQuery: (NSString*)query {
	if (recentWebsites == nil) {
		NSMutableArray *recents = [NSMutableArray array];
		NSArray *files = [Website getAllHistoryFiles];
		NSInteger max = MIN([files count], 2);
		NSString *file;
		for (NSInteger i = 0; i < max; i++) {
			file = [files objectAtIndex: i];
			[recents addObjectsFromArray: [Website getHistoryFromFile: file
				matching: nil]];
		}
		recentWebsites = [recents retain];
		NSLog(@"recents: %@", recentWebsites);
	}
	if (previousQuery == nil) {
		NSLog(@"prev query is nil");
		previousQuery = [query retain];
	}
	NSLog(@"Query %@, prev %@", query, previousQuery);
	if (![query hasPrefix: previousQuery] || filteredWebsites == nil) {
		NSLog(@"Restarting search");
		[filteredWebsites release];
		filteredWebsites = [recentWebsites mutableCopy];
	}
	if ([query length] > 0) {
		NSPredicate *queryPredicate = [NSPredicate predicateWithFormat: 
			@"url contains %@ OR name contains %@", query, query];
		[filteredWebsites filterUsingPredicate: queryPredicate];
	} else {
		[filteredWebsites removeAllObjects];	
	}
	NSLog(@"%@", filteredWebsites);
	[previousQuery release];
	previousQuery = [query copy];
	[tableView reloadData];
	NSRect frame = [self frame];
	CGFloat oldHeight = frame.size.height;
	frame.size.height = MIN(MAX_HEIGHT, [filteredWebsites count] * ENTRY_HEIGHT);
	frame.origin.y -= (frame.size.height - oldHeight);
	[self setFrame: frame];
}

// MARK: - Table View


-(NSInteger)numberOfRowsInTableView: (NSTableView*)aTableView {
	return [filteredWebsites count];
}

-(id)tableView: (NSTableView*)aTableView objectValueForTableColumn: (NSTableColumn*)aColumn row: (NSInteger)aRow {
	return [[filteredWebsites objectAtIndex: aRow] url];
}

-(void)tableView: (NSTableView*)aTableView setObjectValue: (id)object forTableColumn: (NSTableColumn*)aColumn row: (NSInteger)aRow {

}

-(CGFloat)tableView: (NSTableView*)aTableView heightOfRow: (NSInteger)aRow {
	NSLog(@"heith of row");
	return 20;
}

-(void)tableViewSelectionDidChange: (NSNotification*)aNotification {
	NSInteger row = [tableView selectedRow];
	if (row == NSNotFound) {
		return;
	}
	Website *selectedWebsite = [filteredWebsites objectAtIndex: row];
	[urlBar setStringValue: [selectedWebsite url]];
	[self updateQuery: @""];
	[browserWindowController openWebsite: selectedWebsite];
	NSLog(@"Selection changed");
}

@end
