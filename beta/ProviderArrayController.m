//
//  ProviderArrayController.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/28/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "ProviderArrayController.h"
#import "Provider.h"
#import "Widget.h"
#import "MainController.h"


@implementation ProviderArrayController


- (void)awakeFromNib
{
	[[tableView undoManager] setLevelsOfUndo:1];
	[tableView registerForDraggedTypes:[NSArray arrayWithObjects:CopiedRowsType, MovedRowsType, nil]];

	[tableView setDoubleAction:@selector(toggleProvider:)];
	[tableView setTarget:self];
	
	[self setSelectionIndex:1];
 	
	[super awakeFromNib];
}

- (NSTableView*)tableView
{
	return tableView;
}

- (void)toggleProvider:(id)sender
{
	int providerIndex = [self selectionIndex];
	if(providerIndex != NSNotFound) {
		Provider* provider = [[self arrangedObjects] objectAtIndex:providerIndex];
		NSNumber* canEdit = [provider canEdit];

		if([canEdit boolValue] == NO)
			return;

		[self open:self];
	}
}

- (void)setFloor:(int)index
{
	floor = index;
}

- (IBAction)userDelete:(id)sender
{
	int providerIndex = [self selectionIndex];
	if(providerIndex != NSNotFound) {
		Provider* provider = [[self arrangedObjects] objectAtIndex:providerIndex];
		NSNumber* canEdit = [provider canEdit];
		
		if([canEdit boolValue] == NO)
			return;

		NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedString(@"DeleteTitle", @"")
			defaultButton:NSLocalizedString(@"DeleteOK", @"")
			alternateButton:NSLocalizedString(@"DeleteCancel", @"")
			otherButton:nil
			informativeTextWithFormat:NSLocalizedString(@"DeleteMessage", @""), [provider title]];

		if([alert runModal] == 0) {
			return;
		}

		[self remove:sender];
	}
}

- (void)remove:(id)sender
{
	[super remove:sender];

	NSArray* objects = [self arrangedObjects];
	NSEnumerator* enumerator = [objects objectEnumerator];

	int editableObjects = 0;

	id item;
	while(item = [enumerator nextObject]) {
		if([[item canEdit] boolValue] == YES)
			editableObjects++;
	}
	
	if(editableObjects == 0)
		[self setSelectionIndex:1];
}

- (IBAction)open:(id)sender
{
	int providerIndex = [self selectionIndex];
	if(providerIndex != NSNotFound) {
		Provider* provider = [[self arrangedObjects] objectAtIndex:providerIndex];
		NSMutableArray* widgets = [provider widgets];
		int count = [widgets count];
		if(count) {
			NSMutableArray* widgetsToOpen  = [NSMutableArray arrayWithCapacity:count];
			NSEnumerator* enumerator = [widgets objectEnumerator];
			Widget* widget;
			while(widget = [enumerator nextObject]) {
				[widgetsToOpen addObject:[widget identifier]];
			}

			[manager switchWidgets:widgetsToOpen];
		}
	}
}

- (IBAction)rename:(id)sender
{
	[tableView editColumn:[tableView columnWithIdentifier:@"sourceNameColumn"] row:[tableView selectedRow] withEvent:nil select:YES];
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
			[[tableView undoManager] setActionName:@"Rename Collection"];
		}
	}
}
#endif

// NSTableView delegate
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
	Provider* provider = [[self arrangedObjects] objectAtIndex:rowIndex];
	NSNumber* canSelect = [provider canSelect];
	if(canSelect)
		return [canSelect boolValue];
		
	return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int providerIndex = [self selectionIndex];
	if(providerIndex == NSNotFound) {
		[self setSelectionIndex:1];
	}
	else {
		Provider* provider = [[self arrangedObjects] objectAtIndex:providerIndex];
		NSString* key = [provider key];
		
		MainController* main = (MainController*) [NSApp delegate];
		[main switchInfo:key];			

		if([key isEqualToString:@"_Store"])
			[main openStore];
		else
			[main closeStore];
		
		if([key isEqualToString:@"_Showcase"]) {
			[main openBrowser:@"http://www.amnestywidgets.com/hypercube/machost/fidget.php"];
		}
		else if([key isEqualToString:@"_Widgetbox"]) {
			[main openBrowser:@"http://www.widgetbox.com/cgallery/hypercube/home"];
		}
		else if([key isEqualToString:@"_Store"]) {
			if([main providerURLString])
				[main openBrowser:[main providerURLString]];
			else
				[main closeBrowser];
		}
		else if([[provider canLink] boolValue] == YES) {
			if([manager importFromDestinationProvider:provider] == NO) {
				NSString* destination = [key substringFromIndex:1];
				NSString* linkURL = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/deskhost/link_%@.html", destination];	
				[main openBrowser:linkURL destination:destination];
			}
			else
				[main closeBrowser];
		}
		else
			[main closeBrowser];
	}
}

// Drag and Drop
- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if(isLocal)
		return NSDragOperationMove;

	return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	int providerIndex = [self selectionIndex];
	if(providerIndex != NSNotFound) {
		Provider* provider = [[self arrangedObjects] objectAtIndex:providerIndex];
		NSNumber* canEdit = [provider canEdit];
		if([canEdit boolValue] == NO)
			return NO;
		
		NSArray* typesArray = [NSArray arrayWithObject:MovedRowsType];
		[pboard declareTypes:typesArray owner:self];
		
		NSIndexSet* rowToMove = [NSIndexSet indexSetWithIndex:[rowIndexes firstIndex]];
			
		NSData* rowArchive = [NSKeyedArchiver archivedDataWithRootObject:rowToMove];
		[pboard setData:rowArchive forType:MovedRowsType];
		
		return YES;
	}
	
	return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard
{
	extern SInt32 gMacVersion;
	if(gMacVersion < 0x1040) {
		int providerIndex = [self selectionIndex];
		if(providerIndex != NSNotFound) {
			Provider* provider = [[self arrangedObjects] objectAtIndex:providerIndex];
			NSNumber* canEdit = [provider canEdit];
			if([canEdit boolValue] == NO)
				return NO;
			
			NSArray* typesArray = [NSArray arrayWithObject:MovedRowsType];
			[pboard declareTypes:typesArray owner:self];
			
			NSIndexSet* rowToMove = [NSIndexSet indexSetWithIndex:[[rows objectAtIndex:0] intValue]];
				
			NSData* rowArchive = [NSKeyedArchiver archivedDataWithRootObject:rowToMove];
			[pboard setData:rowArchive forType:MovedRowsType];
		}
	}
	
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op
{
	int maxRows = [tableView numberOfRows];
	if(row >= maxRows)
		row = maxRows - 1;
		
	int selectedRow = [tableView selectedRow];

	NSPasteboard* pb = [info draggingPasteboard];
	if([[pb types] containsObject:MovedRowsType]) {
		if(row < floor)
			row = floor;
			
		if(row == selectedRow || row == selectedRow - 1)
			return NSDragOperationNone;

		[tv setNeedsDisplay:YES];
		[tv setDropRow:row+1 dropOperation:NSTableViewDropAbove];
			
		return op;
	}
	
	if(row < 0)
		row = 0;
		
	Provider* provider = [[self arrangedObjects] objectAtIndex:row];
	NSString* key = [provider key];

	[tv setNeedsDisplay:YES];
	
	if([info draggingSourceOperationMask] == NSDragOperationMove && [key isEqualToString:@"_Web"])
		;
	else {
		NSNumber* canDrop = [provider canDrop];
		if([canDrop boolValue] == NO)
			return NSDragOperationNone;
	}
		
	if(row == selectedRow)
		return NSDragOperationNone;
	
	[tv setDropRow:row dropOperation:NSTableViewDropOn];
		
    return op;
}

- (BOOL)tableView:(NSTableView*)tv
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op
{
	NSPasteboard* pb = [info draggingPasteboard];
	if([[pb types] containsObject:MovedRowsType]) {
		NSData* rowsData = [[info draggingPasteboard] dataForType:MovedRowsType];
		NSIndexSet* rowToMove = [NSKeyedUnarchiver unarchiveObjectWithData:rowsData];
		
		int fromRow = [rowToMove firstIndex];
		id providerToMove = [[self arrangedObjects] objectAtIndex:fromRow];
		[providerToMove retain];
		[self removeObject:providerToMove];
		if(row > fromRow)
			[self insertObject:providerToMove atArrangedObjectIndex:row - 1];
		else
			[self insertObject:providerToMove atArrangedObjectIndex:row];
		[providerToMove release];
			
		return NO;
	}
	
	NSData* rowsData = [[info draggingPasteboard] dataForType:CopiedRowsType];

	Provider* provider = [[self arrangedObjects] objectAtIndex:row];
	NSMutableArray* widgets = [provider widgets];
	
	NSString* key = [provider key];

	if([key isEqualToString:@"_Yahoo"]) {
		NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedString(@"BetaTitle", @"")
			defaultButton:NSLocalizedString(@"OK", @"")
			alternateButton:nil
			otherButton:nil
			informativeTextWithFormat:NSLocalizedString(@"BetaYahoo", @"")];

		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		
		return NO;
	}
	
	if([[provider canLink] boolValue] == YES) {
		NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedString(@"InstallTitle", @"")
			defaultButton:NSLocalizedString(@"InstallOK", @"")
			alternateButton:NSLocalizedString(@"InstallCancel", @"")
			otherButton:nil
			informativeTextWithFormat:NSLocalizedString(@"InstallMessage", @""), [key substringFromIndex:1]];

		if([alert runModal] == 0)
			return NO;
	}
	
	if(rowsData) {
		NSMutableArray* rowCopies = [NSKeyedUnarchiver unarchiveObjectWithData:rowsData];
		NSEnumerator* enumerator = [rowCopies objectEnumerator];
		NSString* identifier;

		if([rowCopies count] > 1) {
			if([key isEqualToString:@"_Dashboard"]) {
				NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedString(@"DashboardTitle", @"")
					defaultButton:NSLocalizedString(@"OK", @"")
					alternateButton:nil
					otherButton:nil
					informativeTextWithFormat:NSLocalizedString(@"DashboardLimit", @"")];

				NSImage* dashboardIcon = [[NSWorkspace sharedWorkspace] iconForFileType:@"wdgt"];
				[alert setIcon:dashboardIcon];
				[alert setAlertStyle:NSInformationalAlertStyle];
				[alert runModal];
				
				return NO;
			}
		}
		
		while((identifier = [enumerator nextObject])) {
			Widget* widget = [manager widgetWithIdentifier:identifier];
			if(widget == nil)
				continue;

			if([key isEqualToString:@"_Dashboard"]) {
				NSString* code = [widget code];
				NSString* title = [widget title];
				NSData* imageData = [widget image];
				
				[manager exportWidgetWithCode:code title:title imageData:imageData platform:@"Dashboard"];
			}
			else if([key isEqualToString:@"_Yahoo"]) {
				NSString* code = [widget code];
				NSString* title = [widget title];
				NSData* imageData = [widget image];
				
				[manager exportWidgetWithCode:code title:title imageData:imageData platform:@"Yahoo"];
			}
			else if([[provider canLink] boolValue] == YES) {
				NSString* escapedTitle = [[widget title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSString* escapedCode = [[widget code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSMutableString* temp = [escapedCode mutableCopy];
				[temp replaceOccurrencesOfString:@" " withString:@"%20" options:0 range:NSMakeRange(0, [temp length])];
				[temp replaceOccurrencesOfString:@"&" withString:@"%26" options:0 range:NSMakeRange(0, [temp length])];
				[temp replaceOccurrencesOfString:@"<" withString:@"%3C" options:0 range:NSMakeRange(0, [temp length])];
				[temp replaceOccurrencesOfString:@">" withString:@"%3E" options:0 range:NSMakeRange(0, [temp length])];

				id defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];
				
				NSString* destination = [key substringFromIndex:1];
				NSString* userKey = [NSString stringWithFormat:@"%@User", destination];	
				NSString* cubeKey = [NSString stringWithFormat:@"%@Cube", destination];	
				NSString* user = [defaults valueForKey:userKey];
				NSString* cube = [defaults valueForKey:cubeKey];
				
				if([user isEqualToString:@""] || [cube isEqualToString:@""]) {
					NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedString(@"NoLinkTitle", @"")
													 defaultButton:NSLocalizedString(@"OK", @"")
												   alternateButton:nil
													   otherButton:nil
										 informativeTextWithFormat:NSLocalizedString(@"NoLinkMessage", @""), destination];
					
					[alert setAlertStyle:NSInformationalAlertStyle];
					[alert runModal];
					
					return NO;
				}

				NSString* dbKey = [manager installToDestination:key user:user cube:cube title:escapedTitle code:temp];
				if(dbKey && [dbKey isEqualToString:@"0"] == NO) {
					Widget* destinationWidget = [[Widget alloc] initWithWidget:widget];
					[destinationWidget setKey:dbKey];
					[widgets addObject:destinationWidget];
				}
			}
			else if([widgets indexOfObjectIdenticalTo:widget] == NSNotFound) {
				if([info draggingSourceOperationMask] == NSDragOperationMove) {
					MainController* main = (MainController*) [NSApp delegate];
					Provider* web = [main providerWithKey:@"_Web"];

					Widget* libraryWidget = [[manager library] objectForKey:identifier];
					if(libraryWidget == nil) {
						libraryWidget = [[Widget alloc] initWithWidget:widget];
						[[manager library] setObject:libraryWidget forKey:identifier];
						
						NSMutableArray* webWidgets = [web widgets];
						[webWidgets addObject:libraryWidget];
					}
					
					if(libraryWidget && [provider isEqualTo:web] == NO && [widgets indexOfObjectIdenticalTo:libraryWidget] == NSNotFound)
						[widgets addObject:libraryWidget];
				}
				else
					[widgets addObject:widget];
			}	
		}

		return YES;
	}
	
	return NO;
}

@end
