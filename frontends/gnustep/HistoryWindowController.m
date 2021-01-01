#import <Cocoa/Cocoa.h>
#import <stdio.h>
#import <string.h>

#import "HistoryWindowController.h"
#import "Website.h"
#import "AppDelegate.h"
#import "desktop/global_history.h"

/*
This history implementation just appends the website_data structures to a file named based on the
month and year it was visited. The outline view used here only has 2 levels, the top levels mapping
1-to-1 with Sections, each section representing one month's (one file's) contents.

Website entires are actually written to these files by the [Website addToHistory] method in
website.h

When deleting a history entry, rather than rejigging the whole file, it just writes 0's over it's
location in the file (keeping the size info). Entris overwritten in this way are ignored when 
scanning the history files. 
When deleting a section, it's entire file is simply deleted. When doing select-all->delete, this 
will go through deleting all the sections and removing their files, and no time is wasted 0ing
entries beforehand, as each item representing a 'section' is returned before it's children.
*/

@interface Section: NSObject {
	NSString *name;
	NSString *filename;
	NSString *filepath;
	NSMutableArray *items;
}
@end
@implementation Section
+(id)sectionWithName: (NSString*)aName items: (NSMutableArray*)someItems referencingFilepath: (NSString*)aFilepath {
	Section *section = [[[Section alloc] init] autorelease];
	section->name = [aName retain];
	section->items = [someItems retain];
	section->filepath = [aFilepath retain];
	return section;
}
-(NSString*)name {
	return name;
}
-(NSString*)filepath {
	return filepath;
}
-(NSMutableArray*)items {
	return items;
}
-(void)setItems: (NSMutableArray*)someItems {
	[items release];
	items = [someItems retain];
}
-(void)dealloc {
	[name release];
	[items release];
	[filepath release];
	[super dealloc];
}
@end

@implementation HistoryWindowController

-(id)init {
	if (self = [super initWithWindowNibName: @"History"]) {
		sections = [[NSMutableArray alloc] init];
		searchValue = nil;
	}
	return self;
}

-(void)dealloc {
	[sections release];
	[super dealloc];
}

-(NSMutableArray*)getHistoryFromPath: (NSString*)path {
	size_t nread, wsize;
	long fileoff;
	int lens[2];
	FILE *f = fopen([path cString], "r");
	struct website_data *wdata;
	Website *website;
	NSMutableArray *ret = [NSMutableArray array];

	if (f == NULL) {
		NSLog(@"Error opening file: %@", path);
		return ret;
	}
	fileoff = 0;
	while (1) {
		if ((nread = fread(lens, sizeof (int), 2, f)) < 2) {
			break;
		}
		wsize = lens[0] + lens[1] + sizeof (struct website_data);
		// 0 Value of url_len implies this has been cleared. Skip.
		if (lens[1] == 0) {
			fseek(f, wsize - (nread * sizeof (int)), SEEK_CUR);
			continue;
		}
		// Else it's valid, rewind and read the whole structure in.
		fseek(f, -nread * sizeof (int), SEEK_CUR);
		wdata = malloc(wsize);
		fread(wdata, wsize, 1, f);
		website = [[[Website alloc] initWithData: wdata atFileOffset: fileoff] 
			autorelease];
		// If there's a search value set, skip non-matching websites.
		if (searchValue == nil || [[website name] rangeOfString: searchValue options: 
			NSCaseInsensitiveSearch].location != NSNotFound) {
			[ret addObject: website];
		}
		fileoff = ftell(f);
	}
	fclose(f);
	return ret;
}
-(NSMutableArray*)getAllHistory {
	NSCalendarDate *date = [NSCalendarDate calendarDate];
	NSInteger currentMonth = [date monthOfYear];
	NSInteger currentYear = [date yearOfCommonEra];
	NSInteger fileYear, fileMonth;
	NSString *path = [NSString stringWithFormat: @"%@/%@", NSHomeDirectory(), 
		HISTORY_PATH];
	NSString *fpath, *filename, *sectionName;
	NSArray *yearAndDate;
	NSError *error = nil;
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: path
		error: &error];
	NSMutableArray *ret = [NSMutableArray array];

	if (error != nil) {
		NSLog(@"Error fetching files in history dir: %@", path);
		return ret;
	}

	NSEnumerator *reversedFiles = [[files sortedArrayUsingSelector: 
		@selector(caseInsensitiveCompare:)] reverseObjectEnumerator];
	while ((filename = [reversedFiles nextObject]) != nil) {
		if ([filename hasPrefix: @"history_"]) {
			yearAndDate = [[filename substringFromIndex: 8] 
				componentsSeparatedByString: @"_"];
			fileYear = [[yearAndDate firstObject] integerValue];
			fileMonth = [[yearAndDate objectAtIndex: 1] integerValue];

			if (fileYear == currentYear && fileMonth == currentMonth) {
				sectionName = @"This Month";
			} else if ((fileYear == currentYear && fileMonth == currentMonth - 1)
				 || (currentMonth == 1 && currentYear == fileYear + 1 &&
				fileMonth == 12)) {
	
				sectionName = @"Last Month";
			} else {
				sectionName = [NSString stringWithFormat: @"%ld/%ld", 
					fileMonth, fileYear];
			}
			fpath = [path stringByAppendingPathComponent: filename];
			[ret addObject: [Section sectionWithName: sectionName
				items: [self getHistoryFromPath: fpath] referencingFilepath:
				fpath]];
		}
	}
	return ret;
}

// Called when a history item is added in [Website addToHistory];
-(void)updateItems: (NSNotification*)aNotification {
	id object = [aNotification object];
	Section *section;
	if ([object isKindOfClass: [Website class]]) {
		section = [sections firstObject];
		// If we don't have this month's section, just force a full reload...
		if (![[section name] isEqualTo: @"This Month"]) {
			NSLog(@"No current month section to add to, full reload");
			[self onWindowAppeared];
			return;
		}
		[[section items] addObject: object];
		[outlineView reloadData];
	}
}

// NOTE: - windowWillClose only gets called the first time the window is closed. gnustep bug?
-(BOOL)windowShouldClose: (id)sender {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[sections release];
	sections = nil;
	[searchValue release];
	searchValue = nil;
	[searchBar setStringValue: nil];
	return YES;
}

-(void)onWindowAppeared {
	[sections release];
	sections = [[self getAllHistory] retain];
	[outlineView reloadData];
	for (NSUInteger i = 0; i < [sections count]; i++) {
		[outlineView expandItem: [sections objectAtIndex: i] expandChildren: NO];
	}
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[[NSNotificationCenter defaultCenter] addObserver: self 
		selector: @selector(updateItems:)
		name: WebsiteHistoryUpdatedNotificationName
		object: nil];
}
-(void)showWindow: (id)sender {
	[self onWindowAppeared];
	[super showWindow: sender];
}
-(void)awakeFromNib {
	[self onWindowAppeared];
}

-(BOOL)validateMenuItem: (NSMenuItem*)aMenuItem {
	NSInteger tag = [aMenuItem tag];
	if (tag == TAG_MENU_REMOVE || tag == TAG_MENU_OPEN) {
		return [outlineView numberOfSelectedRows] > 0;
	}
	return YES;
}

-(void)open: (id)sender {
	NSEnumerator *selected = [outlineView selectedRowEnumerator];
	id row, item;
	while ((row = [selected nextObject]) != NULL) {
		item = [outlineView itemAtRow: [row integerValue]];
		if ([item isKindOfClass: [Website class]]) {
			[[NSApp delegate] openWebsite: item];
			break;
		}
	}
}

-(void)copy: (id)sender {
	NSEnumerator *selected = [outlineView selectedRowEnumerator];
	id row, item;
	while ((row = [selected nextObject]) != NULL) {
		item = [outlineView itemAtRow: [row integerValue]];
		if ([item isKindOfClass: [Website class]]) {
			[[NSPasteboard generalPasteboard] setString: [item url]
				forType: NSStringPboardType];
			break;
		}
	}
}

-(void)clearSearch: (id)sender {
	[searchValue release];
	searchValue = nil;
	[searchBar setStringValue: @""];
	[self onWindowAppeared];
}

-(void)search: (id)sender {
	if ([[sender stringValue] length] == 0) {
		[self clearSearch: sender];
	} else {
		[searchValue release];
		searchValue = [[sender stringValue] retain];
		[self onWindowAppeared];
	}
}

-(void)removeHistoryFileForSection: (Section*)aSection {
	BOOL isDir = YES;
	BOOL exists = NO;
	exists = [[NSFileManager defaultManager] fileExistsAtPath: [aSection filepath] isDirectory: 
		&isDir];
	if (!exists || isDir) {
		NSLog(@"Refusing to delete non-existant or directory-type file at path: %@", 
			[aSection filepath]);
		return;
	}
	if (remove([[aSection filepath] cString]) == -1) {
		NSLog(@"Failed to remove at path: %@", [aSection filepath]);
	}

}
// NOTE: - I'm just writing 0's over the entry in the file here, instead of rewriting large chunks
// and then trimming. The files will be deleted when there are no entries anyhow.
-(void)clearDataForWebsite: (Website*)aWebsite inSection: (Section*)aSection {
	BOOL isDir = YES;
	BOOL exists = NO;
	exists = [[NSFileManager defaultManager] fileExistsAtPath: [aSection filepath] isDirectory: 
		&isDir];
	if (!exists || isDir) {
		NSLog(@"Refusing to delete non-existant or directory-type file at path: %@", 
			[aSection filepath]);
		return;
	}
	FILE *f = fopen([[aSection filepath] cString], "r+");
	if (f == NULL) {
		NSLog(@"Could not open file for reading and writing at path %@", 
			[aSection filepath]);
		return;
	}
	if (fseek(f, [aWebsite fileOffset], SEEK_SET) == -1) {
		NSLog(@"Failed to seek to position of website in file");
		return;
	}
	int nread;
	int lens[2];
	if ((nread = fread(lens, sizeof (int), 2, f)) < 2) {
		NSLog(@"Failed to read lengths for website entry");
		return;
	}
	int wsize = sizeof (struct website_data) + lens[0] + lens[1];
	struct website_data *wdata = calloc(1, wsize);
	wdata->len_name = lens[0] + lens[1];
	fseek(f, -nread * sizeof (int), SEEK_CUR);
	if (fwrite(wdata, wsize, 1, f) < 1) {
		NSLog(@"Failed to overwrite 0'd website entry");
		return;
	}
	fclose(f);
	free(wdata);
}	

-(void)remove: (id)sender {
	NSEnumerator *selected = [outlineView selectedRowEnumerator];
	id row, item;
	Section *parent;

	// Keep track of deleted sections, so we don't bother with selected children of them.
	NSMutableSet *deletedSections = [NSMutableSet set];
	// Effectiveness of the 'is section' shortcircuit relies on the upper levels being
	// enumerated first, which appears to be the case.
	while ((row = [selected nextObject]) != NULL) {
		item = [outlineView itemAtRow: [row integerValue]];
		// This shortcut only holds true if we're not filtering.
		if (searchValue == nil && [item isKindOfClass: [Section class]]) {
			// Can take a shortcut and delete the whole backing file in this case.
			[self removeHistoryFileForSection: item];
			[deletedSections addObject: item];
			[sections removeObject: item];
		} else if ([item isKindOfClass: [Website class]]) {
			parent = [outlineView parentForItem: item];
			if (![deletedSections containsObject: parent]) {
				[[parent items] removeObject: item];
				// Again, we only know if it's truly empty if not filtering.
				if (searchValue == nil && [[parent items] count] == 0) {
					// If it's now empty we can clean up the file.
					[self removeHistoryFileForSection: parent];
					[sections removeObject: parent];
				} else {
					// Else we just write 0's over most of it's data.
					[self clearDataForWebsite: item inSection: parent];
				}
			}
		}
	}
	[outlineView reloadData];
}

-(id)outlineView: (NSOutlineView*)outlineView child: (NSInteger)index ofItem: (id)item {	
	if (item == nil) {
		return [sections objectAtIndex: index];
	} else {
		NSUInteger count = [[item items] count];
		return [[item items] objectAtIndex: count - (index + 1)];
	}
}

-(BOOL)outlineView: (NSOutlineView*)outlineView isItemExpandable: (id)item {
	if ([item isKindOfClass: [Section class]]) {
		return YES;
	} else {
		return NO;
	}
}

-(NSInteger)outlineView: (NSOutlineView*)outlineView numberOfChildrenOfItem: (id)item {
	if (item == nil) {
		return [sections count];
	} else if ([item isKindOfClass: [Section class]]) {
		return [[item items] count];
	} else {
		return 0;
	}
}

-(id)outlineView: (NSOutlineView*)outlineView objectValueForTableColumn: (NSTableColumn*)tableColumn byItem: (id)item {
	return [item name];
}

-(BOOL)outlineView: (NSOutlineView*)outlineView shouldSelectItem: (id)item {
	return YES;
}

@end