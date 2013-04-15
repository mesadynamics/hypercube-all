//
//  SourceListTextCell.m
//  TableTester
//
//  Created by Matt Gemmell on Thu Dec 25 2003.
//  Copyright (c) 2003 Scotland Software. All rights reserved.
//
//  Modified by Dave Batton.


#import "SourceListTextCell.h"
#import "CTGradient.h"


@implementation SourceListTextCell

- (id) init
{
    if((self = [super init])) {
		[self setWraps:NO];  // Important so the text doesn't wrap during editing.
		mIsEditingOrSelecting = NO;
	}
	
	return self;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[controlView lockFocus];
	
	NSString* stringValue = [self stringValue];
	BOOL isTitle = ([self isEnabled] == NO && [stringValue hasSuffix:@"\r"]);
	
	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:[[self attributedStringValue] attributesAtIndex:0 effectiveRange:NULL]];
	[attrs setObject:[NSFont fontWithName:@"Lucida Grande" size:11] forKey:NSFontAttributeName];
	if(isTitle) {
		NSFont *font = [attrs objectForKey:@"NSFont"];
		NSFont *newFont = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSBoldFontMask];
		[attrs setValue:newFont forKey:@"NSFont"];
		[attrs setValue:[NSColor colorWithCalibratedRed:.23 green:.27 blue:.32 alpha:1.0] forKey:@"NSColor"];
	}

	cellFrame.size.width += 10;  // Added this to get it to draw the full width of the object properly. -DB
		
	if (!isTitle && [self isHighlighted]) {
		extern SInt32 gMacVersion;

			/* Determine whether we should draw a blue or grey gradient. */
			/* We will automatically redraw when our parent view loses/gains focus, or when our parent window loses/gains main/key status. */
		if (([[controlView window] firstResponder] == controlView) && 
				[[controlView window] isMainWindow] &&
				[[controlView window] isKeyWindow])
		{
			if(gMacVersion < 0x1040) {
				[[NSColor colorWithCalibratedRed:.22 green:.46 blue:.84 alpha:1.0] set];
				NSRectFill(cellFrame);
			}
			else
				[[CTGradient sourceListSelectedGradient] fillRect:cellFrame angle:270];

			//NSImage* image = [NSImage imageNamed:@"LCD2"];
			//[image drawInRect:cellFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

			NSRect lineRect = cellFrame;
			lineRect.size.height = 1;
			[[NSColor colorWithCalibratedRed:.27 green:.50 blue:.78 alpha:1.0] set];
			NSRectFill(lineRect);
		} else
		{
			if(gMacVersion < 0x1040) {
				[[NSColor colorWithCalibratedWhite:.5 alpha:1.0] set];
				NSRectFill(cellFrame);
			}
			else
				[[CTGradient sourceListUnselectedGradient] fillRect:cellFrame angle:270];
		}
		
			// If this line is selected, we want a bold white font.
		NSFont *font = [attrs objectForKey:@"NSFont"];
		NSFont *newFont = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSBoldFontMask];
		[attrs setValue:newFont forKey:@"NSFont"];
		[attrs setValue:[NSColor whiteColor] forKey:@"NSColor"];
	}

	NSRect inset = [self drawingRectForBounds:cellFrame];
	inset.origin.x += 4; // Nasty to hard-code this. Can we get it to draw its own content, or determine correct inset?
	float width = inset.size.width - 16;
	
	if(isTitle) {
		inset.origin.y += 4;
		inset.origin.x -= 44;

		[NSGraphicsContext saveGraphicsState]; 

		NSShadow* theShadow = [[NSShadow alloc] init]; 
		[theShadow setShadowOffset:NSMakeSize(0, -1)]; 
		[theShadow setShadowBlurRadius:0.3]; 

		[theShadow setShadowColor:[NSColor whiteColor]]; 
		
		[theShadow set];
		
		[stringValue drawAtPoint:inset.origin withAttributes:attrs];

		[NSGraphicsContext restoreGraphicsState];
		[theShadow release]; 
	}
	else {
		NSString *displayString = [self truncateString:stringValue forWidth:width andAttributes:attrs];
		[displayString drawAtPoint:inset.origin withAttributes:attrs];
	}
	
	[controlView unlockFocus];
}




	// Not from Matt's class. Added this later. -DB
- (NSString*)truncateString:(NSString *)string forWidth:(double) inWidth andAttributes:(NSDictionary*)inAttributes
{
    unichar  ellipsesCharacter = 0x2026;
    NSString* ellipsisString = [NSString stringWithCharacters:&ellipsesCharacter length:1];
	
    NSString* truncatedString = [NSString stringWithString:string];
    int truncatedStringLength = [truncatedString length];
	
    if ((truncatedStringLength > 2) && ([truncatedString sizeWithAttributes:inAttributes].width > inWidth))
    {
        double targetWidth = inWidth - [ellipsisString sizeWithAttributes:inAttributes].width;
        NSCharacterSet* whiteSpaceCharacters = [NSCharacterSet 
			whitespaceAndNewlineCharacterSet];
		
        while([truncatedString sizeWithAttributes:inAttributes].width > 
			  targetWidth && truncatedStringLength)
        {
            truncatedStringLength--;
            while ([whiteSpaceCharacters characterIsMember:[truncatedString characterAtIndex:(truncatedStringLength -1)]])
            {
                // never truncate immediately after whitespace
                truncatedStringLength--;
            }
			
            truncatedString = [truncatedString substringToIndex:truncatedStringLength];
        }
		
        truncatedString = [truncatedString stringByAppendingString:ellipsisString];
    }
	
    return truncatedString;
}





	//	This method is from Red Sweater Software's RSVerticallyCenteredTextField class.
	//  It was not part of the original SourceListTableView routines from Matt Gemmell.
	//  Created by Daniel Jalkut on 6/17/06.
	//  Copyright 2006 Red Sweater Software. All rights reserved.
	//	MIT License
- (NSRect)drawingRectForBounds:(NSRect)theRect
{
		// Get the parent's idea of where we should draw
	NSRect newRect = [super drawingRectForBounds:theRect];
	
	// When the text field is being edited or selected, we have to turn off the magic because it screws up the configuration of the field editor.  We sneak around this by intercepting selectWithFrame and editWithFrame and sneaking a reduced, centered rect in at the last minute.
	if (mIsEditingOrSelecting == NO) {
			// Get our ideal size for current text
		NSSize textSize = [self cellSizeForBounds:theRect];
		
			// Center that in the proposed rect
		float heightDelta = newRect.size.height - textSize.height;	
		if (heightDelta > 0) {
			newRect.size.height -= heightDelta;
			newRect.origin.y += (heightDelta / 2);
		}
		newRect.size.width -= 1;
	}
	
	return newRect;
}




- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{
	aRect = [self drawingRectForBounds:aRect];
	mIsEditingOrSelecting = YES;	
	[super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	mIsEditingOrSelecting = NO;
}



- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{	
	aRect = [self drawingRectForBounds:aRect];
	mIsEditingOrSelecting = YES;
	[super editWithFrame:aRect inView:controlView editor:textObj delegate:anObject event:theEvent];
	mIsEditingOrSelecting = NO;
}




@end
