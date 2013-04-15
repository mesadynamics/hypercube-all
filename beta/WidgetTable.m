//
//  WidgetTable.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/28/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "WidgetTable.h"
#import "MainController.h"


@implementation WidgetTable

- (void)awakeFromNib
{
	[super awakeFromNib];
	
		/* Use our custom NSImageCell subclass for the first column. */
    NSTableColumn *firstCol = [self tableColumnWithIdentifier:@"status"];
	NSImageCell *theImageCell = [[NSImageCell alloc] init];
	[firstCol setDataCell:theImageCell];
	[theImageCell release];

	saveEdit = nil;
}

- (void)textDidBeginEditing:(NSNotification *)aNotification
{
	NSText* textObject = [aNotification object];
	if(textObject) {
		[saveEdit release];
		saveEdit = [[textObject string] copy];
	}
}

- (BOOL)textShouldEndEditing:(NSText *)textObject
{
	NSString* trimmedString = [[textObject string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if(trimmedString && [trimmedString length])
		[textObject setString:trimmedString];
	else
		[textObject setString:[saveEdit copy]];
		
	return [super textShouldEndEditing:textObject];
}

	// Make return and tab only end editing, and not cause other cells to edit.
	// Found this code here: http://www.borkware.com/quickies/one?topic=NSTableView
	// It was not part of the original SourceListTableView routines from Matt Gemmell.
- (void)textDidEndEditing:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
	
    int textMovement = [[userInfo valueForKey:@"NSTextMovement"] intValue];

    if (textMovement == NSReturnTextMovement
			|| textMovement == NSTabTextMovement
			|| textMovement == NSBacktabTextMovement) {

        NSMutableDictionary *newInfo;
        newInfo = [NSMutableDictionary dictionaryWithDictionary: userInfo];

        [newInfo setObject:[NSNumber numberWithInt: NSIllegalTextMovement]
					forKey:@"NSTextMovement"];

        notification = [NSNotification notificationWithName:[notification name]
													 object:[notification object]
												   userInfo:newInfo];

    }

    [super textDidEndEditing: notification];
    [[self window] makeFirstResponder:self];

}

- (NSMenu*)menuForEvent:(NSEvent*)event
{
	//Find which row is under the cursor
	[[self window] makeFirstResponder:self];
	NSPoint menuPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	int row = [self rowAtPoint:menuPoint];
	
	if(row == -1 || row >= [self numberOfRows])
		return nil;
	
	/* Update the table selection before showing menu
	Preserves the selection if the row under the mouse is selected (to allow for
	multiple items to be selected), otherwise selects the row under the mouse */
	BOOL currentRowIsSelected = [[self selectedRowIndexes] containsIndex:row];
	if (!currentRowIsSelected)
		[self selectRow:row byExtendingSelection:NO];
	
	if ([self numberOfSelectedRows] <=0)
	{
        //No rows are selected, so the table should be displayed with all items disabled
		NSMenu* tableViewMenu = [[self menu] copy];
		int i;
		for (i=0;i<[tableViewMenu numberOfItems];i++)
			[[tableViewMenu itemAtIndex:i] setEnabled:NO];
		return [tableViewMenu autorelease];
	}
	
	NSString* provider = [providerTitle stringValue];
	if([provider isEqualToString:@"_Store"] == YES) {	 	
		return nil;
	}
	
	
	return [self menu];
}

- (void)keyDown:(NSEvent *)theEvent
{
 	MainController* main = (MainController*) [NSApp delegate];

    NSString *tString;
    unsigned int stringLength;
    unsigned int i;
    unichar tChar;
	
    tString = [theEvent characters];
	
    stringLength = [tString length];

    for (i = 0; i < stringLength; i++) {
        tChar = [tString characterAtIndex:i];
		
        if (tChar == 0x7F) {
            NSMenuItem *tMenuItem = [[NSMenuItem alloc] initWithTitle:@""
															   action:@selector(delete:)
														keyEquivalent:@""];
			
            if ([self validateMenuItem:tMenuItem] == YES)
				[main deleteWidget:self];
            else
                NSBeep();
			
            [tMenuItem release];
            return;
        }
    }

    [super keyDown:theEvent];
}


- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
	if([self selectedRow] == -1)
		return NO;

	//if([aMenuItem action] == @selector(rename:))
   	//	return YES;
		
	//if([aMenuItem action] == @selector(retag:))
   //		return YES;
		
	if([aMenuItem action] == @selector(selectAll:))
   		return YES;
 	
 	NSString* provider = [providerTitle stringValue];
	if([provider isEqualToString:@"_Store"] == NO) {	 	
		if([aMenuItem action] == @selector(delete:))
			return YES;
	}
	
   return NO;
}

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if(isLocal) {
		NSString* provider = [providerTitle stringValue];
		if(
			[provider isEqualToString:@"_Dashboard"] ||
			[provider isEqualToString:@"_Yahoo"] ||
			[provider isEqualToString:@"_Store"]
		)
			return NSDragOperationNone;
		
		if(
		   [provider isEqualToString:@"_Facebook"] ||
		   [provider isEqualToString:@"_Friendster"] ||
		   [provider isEqualToString:@"_Orkut"] ||
		   [provider isEqualToString:@"_MySpace"] ||
		   [provider isEqualToString:@"_Hi5"] ||
		   [provider isEqualToString:@"_Bebo"]
		)
			return NSDragOperationMove;
			
		return NSDragOperationCopy;
	}
	
	return NSDragOperationNone;
}

@end
