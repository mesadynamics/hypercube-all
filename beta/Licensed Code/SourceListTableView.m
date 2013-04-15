//
//  SourceListTableView.m
//  TableTester
//
//  Created by Matt Gemmell on Wed Dec 24 2003.
//  Copyright (c) 2003 Scotland Software. All rights reserved.
//


#import "SourceListTableView.h"
#import "SourceListImageCell.h"
#import "SourceListTextCell.h"
#import "MainController.h"


@implementation SourceListTableView

- (void)awakeFromNib
{
		/* Make the intercell spacing similar to that used in iCal's Calendars list. */
	[self setRowHeight:20];
    [self setIntercellSpacing:NSMakeSize(0.0, 0.0)];
    
		/* Use our custom NSImageCell subclass for the first column. */
    NSTableColumn *firstCol = [[self tableColumns] objectAtIndex:0];
	SourceListImageCell *theImageCell = [[SourceListImageCell alloc] init];
	[firstCol setDataCell:theImageCell];
	[theImageCell release];
    
		/* Use our custom NSTextFieldCell subclass for the second column. */
    NSTableColumn *secondCol = [[self tableColumns] objectAtIndex:1];
    SourceListTextCell *theTextCell = [[SourceListTextCell alloc] init];
    [secondCol setDataCell:theTextCell];
	[[secondCol dataCell] setFont:[NSFont labelFontOfSize:[NSFont smallSystemFontSize]]];
    [theTextCell release];
		
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
	NSMutableString* legalString = [trimmedString mutableCopy];
	[legalString replaceOccurrencesOfString:@"_" withString:@"-" options:0 range:NSMakeRange(0, [legalString length])];
	[legalString replaceOccurrencesOfString:@"[" withString:@"(" options:0 range:NSMakeRange(0, [legalString length])];
	[legalString replaceOccurrencesOfString:@"]" withString:@")" options:0 range:NSMakeRange(0, [legalString length])];
	[legalString replaceOccurrencesOfString:@":" withString:@"-" options:0 range:NSMakeRange(0, [legalString length])];
	[legalString replaceOccurrencesOfString:@"/" withString:@"," options:0 range:NSMakeRange(0, [legalString length])];
	[legalString replaceOccurrencesOfString:@"\\" withString:@"," options:0 range:NSMakeRange(0, [legalString length])];

	if(legalString && [legalString length])
		[textObject setString:legalString];
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

	MainController* main = (MainController*) [NSApp delegate];
	[main renameProvider:self];
}

	// If the Delete key is pressed, delete the selected list item.
	// This was not part of the original SourceListTableView routines from Matt Gemmell.
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
			
            if ([self validateMenuItem:tMenuItem] == YES) {
				[main deleteProvider:self];
            }
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
	if([aMenuItem action] == @selector(delete:))
		return YES;
	
    return NO;
}

-(NSMenu*)menuForEvent:(NSEvent*)event
{
	//Find which row is under the cursor
	[[self window] makeFirstResponder:self];
	NSPoint menuPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	int row = [self rowAtPoint:menuPoint];

	if(row == -1 || row >= [self numberOfRows] || [[self delegate] tableView:self shouldSelectRow:row] == NO)
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
	
	return [self menu];
}

@end
