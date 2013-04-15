//
//  WidgetArrayController.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/28/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "WidgetArrayController.h"
#import "Widget.h"
#import "WidgetManager.h"
#import "MainController.h"


@implementation WidgetArrayController

- (void)awakeFromNib
{
	NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	[self setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	//extern SInt32 gMacVersion;
	//if(gMacVersion >= 0x1040)
	//	[tableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:YES];
		
	[[tableView undoManager] setLevelsOfUndo:1];

	[tableView registerForDraggedTypes:[NSArray arrayWithObject:CopiedRowsType]];
	
	[tableView setDoubleAction:@selector(toggleWidget:)];
	[tableView setTarget:self];
 	
	[super awakeFromNib];
}

- (NSTableView*)tableView
{
	return tableView;
}

- (void)toggleWidget:(id)sender
{
	int widgetIndex = [self selectionIndex];
	if(widgetIndex != NSNotFound) {
		Widget* widget = [[self arrangedObjects] objectAtIndex:widgetIndex];
		
		NSString* provider = [providerTitle stringValue];
		if([provider isEqualToString:@"_Dashboard"] || [provider isEqualToString:@"_Yahoo"]) {
			NSString* code = [widget code];
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:code]];
			
			return;
		}
		
		if([provider isEqualToString:@"_Store"]) {
			NSString* identifier = [widget identifier];
			NSString* key = [identifier substringFromIndex:10];
			NSString* url = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/publishers/pages/%@.html", key];
			
			MainController* main = (MainController*) [NSApp delegate];
			[main openProvider:url];
			
			return;
		}

		NSString* statusName = [[widget status] name];
		if([statusName isEqualToString:@"NoImage"]) {
			NSString* code = [widget code];
			[manager launchWidgetWithCode:code];
		}
		else if([statusName isEqualToString:@"IconSleeping"]) {
			NSString* widgetID = [widget identifier];
			
			NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:widgetID host:nil];
			if(proxy)
				[proxy handleShow:nil];
		}
	}
}

- (IBAction)installDashboard:(id)sender
{
	int widgetIndex = [self selectionIndex];
	if(widgetIndex != NSNotFound) {
		Widget* widget = [[self arrangedObjects] objectAtIndex:widgetIndex];
		
		NSString* code = [widget code];
		NSString* title = [widget title];
		NSData* imageData = [widget image];
		
		[manager exportWidgetWithCode:code title:title imageData:imageData platform:@"Dashboard"];
	}
}

- (IBAction)userLaunch:(id)sender
{
	NSString* provider = [providerTitle stringValue];

	NSArray* selected = [self selectedObjects];
	NSEnumerator* enumerator = [selected objectEnumerator];

	Widget* widget;
	while(widget = [enumerator nextObject]) {
		NSString* code = [widget code];
		
		if([provider isEqualToString:@"_Dashboard"] || [provider isEqualToString:@"_Yahoo"]) {
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:code]];
			continue;
		}
		
		NSString* statusName = [[widget status] name];
		if([statusName isEqualToString:@"NoImage"]) {
			NSString* code = [widget code];
			[manager launchWidgetWithCode:code];
		}
		else if([statusName isEqualToString:@"IconSleeping"]) {
			NSString* widgetID = [widget identifier];
			
			NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:widgetID host:nil];
			if(proxy)
				[proxy handleShow:nil];
		}
	}
}

- (IBAction)userShow:(id)sender
{
	NSArray* selected = [self selectedObjects];
	NSEnumerator* enumerator = [selected objectEnumerator];

	Widget* widget;
	while(widget = [enumerator nextObject]) {
		NSString* widgetID = [widget identifier];
		NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:widgetID host:nil];
		if(proxy)
			[proxy handleShow:nil];
	}
}

- (IBAction)userHide:(id)sender
{
	NSArray* selected = [self selectedObjects];
	NSEnumerator* enumerator = [selected objectEnumerator];

	Widget* widget;
	while(widget = [enumerator nextObject]) {
		NSString* widgetID = [widget identifier];
		NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:widgetID host:nil];
		if(proxy)
			[proxy handleHide:nil];
	}
}

- (IBAction)userClose:(id)sender
{
	NSArray* selected = [self selectedObjects];
	NSEnumerator* enumerator = [selected objectEnumerator];

	Widget* widget;
	while(widget = [enumerator nextObject]) {
		NSString* widgetID = [widget identifier];
		NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:widgetID host:nil];
		if(proxy)
			[proxy handleClose:nil];
	}
}

- (IBAction)userDelete:(id)sender
{
	NSString* locationString = NSLocalizedString(@"RemoveCollection", @"");
	NSString* provider = [providerTitle stringValue];

	NSAlert* alert = nil;
	BOOL removeFromLibrary = NO;
	BOOL removeFromDestination = NO;
	BOOL removeFromFinder = NO;
	
	if([provider isEqualToString:@"_Web"]) {
		locationString = NSLocalizedString(@"RemoveLibrary", @"");
		
		NSString* message = [NSString stringWithFormat:NSLocalizedString(@"RemoveMessage", @""), locationString];
		NSString* warning = NSLocalizedString(@"RemoveWarning", @"");

		alert = [NSAlert alertWithMessageText:NSLocalizedString(@"RemoveTitle", @"")
			defaultButton:NSLocalizedString(@"RemoveOK", @"")
			alternateButton:NSLocalizedString(@"RemoveCancel", @"")
			otherButton:nil
			informativeTextWithFormat:@"%@\r\r%@\r", message, warning];
			
		[alert setAlertStyle:NSCriticalAlertStyle];
		
		removeFromLibrary = YES;
	}
	else if(
	   [provider isEqualToString:@"_Facebook"] ||
	   [provider isEqualToString:@"_Friendster"] ||
	   [provider isEqualToString:@"_Orkut"] ||
	   [provider isEqualToString:@"_MySpace"] ||
	   [provider isEqualToString:@"_Hi5"] ||
	   [provider isEqualToString:@"_Bebo"]
	) {
		locationString = [provider substringFromIndex:1];
		
		removeFromDestination = YES;
	}
	else if([provider isEqualToString:@"_Dashboard"])
	{
		locationString = [provider substringFromIndex:1];

		alert = [NSAlert alertWithMessageText:NSLocalizedString(@"DisableTitle", @"")
			defaultButton:NSLocalizedString(@"DisableOK", @"")
			alternateButton:NSLocalizedString(@"DisableCancel", @"")
			otherButton:nil
			informativeTextWithFormat:NSLocalizedString(@"DisableMessage", @""), locationString];

		[alert setAlertStyle:NSCriticalAlertStyle];

		removeFromFinder = YES;
	}
	else if([provider isEqualToString:@"_Yahoo"])
	{
		locationString = @"Yahoo! Widget Engine";

		alert = [NSAlert alertWithMessageText:NSLocalizedString(@"DisableTitle", @"")
			defaultButton:NSLocalizedString(@"DisableOK", @"")
			alternateButton:NSLocalizedString(@"DisableCancel", @"")
			otherButton:nil
			informativeTextWithFormat:NSLocalizedString(@"DisableMessage", @""), locationString];
			
		[alert setAlertStyle:NSCriticalAlertStyle];

		removeFromFinder = YES;
	}
	
	if(alert == nil) {	
		alert = [NSAlert alertWithMessageText:NSLocalizedString(@"RemoveTitle", @"")
			defaultButton:NSLocalizedString(@"RemoveOK", @"")
			alternateButton:NSLocalizedString(@"RemoveCancel", @"")
			otherButton:nil
			informativeTextWithFormat:NSLocalizedString(@"RemoveMessage", @""), locationString];
	}
	
	if([alert runModal] == 0)
		return;

	if(removeFromLibrary) {
		MainController* main = (MainController*) [NSApp delegate];

		NSArray* removeObjects = [self selectedObjects];
		NSEnumerator* enumerator = [removeObjects objectEnumerator];

		id item;
		while(item = [enumerator nextObject])
			[item retain];

		[self remove:sender];
		
		enumerator = [removeObjects objectEnumerator];
		while(item = [enumerator nextObject]) {
			[main deleteWidgetFromLibrary:item];
			[item release];
		}
		
		return;
	}
	
	if(removeFromDestination) {
		NSArray* removeObjects = [self selectedObjects];
		NSEnumerator* enumerator = [removeObjects objectEnumerator];

		Widget* widget;
		while(widget = [enumerator nextObject]) {
			id defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];

			NSString* destination = [provider substringFromIndex:1];
			NSString* userKey = [NSString stringWithFormat:@"%@User", destination];	
			NSString* cubeKey = [NSString stringWithFormat:@"%@Cube", destination];	
			NSString* user = [defaults valueForKey:userKey];
			NSString* cube = [defaults valueForKey:cubeKey];

			[manager removeFromDestination:provider user:user cube:cube key:[widget key]];
		}	
	}
	
	if(removeFromFinder) {
		NSArray* removeObjects = [self selectedObjects];
		NSEnumerator* enumerator = [removeObjects objectEnumerator];

		Widget* widget;
		while(widget = [enumerator nextObject]) {
			NSWorkspace* ws = [NSWorkspace sharedWorkspace];
			NSString* path = [widget code];
			NSString* dir = [path stringByDeletingLastPathComponent];
			NSString* name = [path lastPathComponent];
			
			NSInteger tag = 0;
			[ws performFileOperation:NSWorkspaceRecycleOperation source:dir destination:@"" files:[NSArray arrayWithObject:name] tag:&tag];
		}
	}
	
	[self remove:sender];
}

- (IBAction)rename:(id)sender
{
	[tableView editColumn:[tableView columnWithIdentifier:@"nameColumn"] row:[tableView selectedRow] withEvent:nil select:YES];
}

- (IBAction)retag:(id)sender
{
	[tableView editColumn:[tableView columnWithIdentifier:@"tagsColumn"] row:[tableView selectedRow] withEvent:nil select:YES];
}

// Search
- (void)setSearchString:(NSString *)string
{
    [searchString release];

    if([string length] == 0)
        searchString = nil;
    else
        searchString = [string copy];
}

- (IBAction)search:(id)sender
{
    [self setSearchString:[sender stringValue]];
    [self rearrangeObjects];
}

#if 0
// Undo
- (id)newObject
{
	id object = [super newObject];
	
	extern SInt32 gMacVersion;
	if(gMacVersion >= 0x1040)
		[[object properties] addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionOld context:nil];

	return object;
}

- (void)changeKeyPath:(NSString *)keyPath ofObject:(id)obj toValue:(id)newValue
{
	[obj setValue:newValue forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	extern BOOL gUndoIsActive;
	
	if(gUndoIsActive) {
		if([keyPath isEqualTo:@"title"]) {
			id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
			[[[tableView undoManager] prepareWithInvocationTarget:self] changeKeyPath:keyPath ofObject:object toValue:oldValue];
			[[tableView undoManager] setActionName:@"Rename Widget"];
		}
	}
}
#endif

// NSTableView delegate
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return NO;
}

// Drag and Drop
- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	NSString* provider = [providerTitle stringValue];
	if(
		[provider isEqualToString:@"_Dashboard"] ||
		[provider isEqualToString:@"_Yahoo"] ||
		[provider isEqualToString:@"_Store"]
	)
		return NO;

    NSArray* typesArray = [NSArray arrayWithObject:CopiedRowsType];
	[pboard declareTypes:typesArray owner:self];
	
	NSMutableArray* rowCopies = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
	
    unsigned int currentIndex = [rowIndexes firstIndex];
    while(currentIndex != NSNotFound) {
		Widget* widget = [[self arrangedObjects] objectAtIndex:currentIndex];
		[rowCopies addObject:[widget identifier]];
        currentIndex = [rowIndexes indexGreaterThanIndex:currentIndex];
    }
	
	NSData* rowArchive = [NSKeyedArchiver archivedDataWithRootObject:rowCopies];
    [pboard setData:rowArchive forType:CopiedRowsType];
	
    return YES;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard
{
	extern SInt32 gMacVersion;
	if(gMacVersion < 0x1040) {
		NSString* provider = [providerTitle stringValue];
		if(
			[provider isEqualToString:@"_Dashboard"] ||
			[provider isEqualToString:@"_Yahoo"] ||
			[provider isEqualToString:@"_Store"]
		)
			return NO;

		NSArray* typesArray = [NSArray arrayWithObject:CopiedRowsType];
		[pboard declareTypes:typesArray owner:self];
		
		NSMutableArray* rowCopies = [NSMutableArray arrayWithCapacity:[rows count]];
		
		NSEnumerator* enumerator = [rows objectEnumerator];
		NSNumber* item;
		while(item = [enumerator nextObject]) {
			unsigned int currentIndex = [item intValue];
			Widget* widget = [[self arrangedObjects] objectAtIndex:currentIndex];
			[rowCopies addObject:[widget identifier]];
		}
		
		NSData* rowArchive = [NSKeyedArchiver archivedDataWithRootObject:rowCopies];
		[pboard setData:rowArchive forType:CopiedRowsType];
	}

	return YES;	
}

// Live Search
- (NSArray*)arrangeObjects:(NSArray *)objects
{
    NSArray* returnObjects = objects;

    if(searchString != nil) {
		BOOL searchTitle = YES;
		BOOL searchProvider = YES;
		BOOL searchTags = YES;
	
		NSString* match = searchString;
		if([match hasPrefix:@"n:"]) {
			match = [searchString substringFromIndex:2];
			searchProvider = NO;
			searchTags = NO;
		}
		else if([match hasPrefix:@"p:"]) {
			match = [searchString substringFromIndex:2];
			searchTitle = NO;
			searchTags = NO;
		}
		else if([match hasPrefix:@"t:"]) {
			match = [searchString substringFromIndex:2];
			searchTitle = NO;
			searchProvider = NO;
		}

		if([match length] == 0)
			return [super arrangeObjects:returnObjects];

        NSMutableArray* filteredObjects = [NSMutableArray arrayWithCapacity:[objects count]];
        NSEnumerator* enumerator = [objects objectEnumerator];

        id item;
		while(item = [enumerator nextObject]) {
			NSRange range;
			NSString* search;
			
			range.location = NSNotFound;
			
			if(searchTitle && range.location == NSNotFound) {
				search = [item valueForKeyPath:@"title"];
				range = [search rangeOfString:match options:NSCaseInsensitiveSearch];
				if(range.location != NSNotFound)
					[filteredObjects addObject:item];
			}
			
            if(searchProvider && range.location == NSNotFound) {
				search = [item valueForKeyPath:@"provider"];
				range = [search rangeOfString:match options:NSCaseInsensitiveSearch];
				if(range.location != NSNotFound)
					[filteredObjects addObject:item];
			}
			
            if(searchTags && range.location == NSNotFound) {
				search = [item valueForKeyPath:@"tags"];
				range = [search rangeOfString:match options:NSCaseInsensitiveSearch];
				if(range.location != NSNotFound)
					[filteredObjects addObject:item];
			}
        }

        returnObjects = filteredObjects;
    }

    return [super arrangeObjects:returnObjects];
}

@end
