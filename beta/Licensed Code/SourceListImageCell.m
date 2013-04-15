//
//  SourceListImageCell.m
//  TableTester
//
//  Created by Matt Gemmell on Mon Dec 29 2003.
//  Copyright (c) 2003 Scotland Software. All rights reserved.
//


#import "SourceListImageCell.h"
#import "CTGradient.h"


@implementation SourceListImageCell

- (id)init
{
    if((self = [super init])) {
        [self setImageAlignment:NSImageAlignTop];
		
		animationTimer = nil;
		[self setDoubleValue:0.0];
    }
	
    return self;
}

#define ConvertAngle(a) (fmod((90.0-(a)), 360.0))
#define DEG2RAD  0.017453292519943295

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[controlView lockFocus];

		/* Determine whether we should draw a blue or grey gradient. */
		/* We will automatically redraw when our parent view loses/gains focus, or when our parent window loses/gains main/key status. */
	if ([self isHighlighted]) {
		extern SInt32 gMacVersion;

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
	}
	
	/* Now draw our image. */
	NSImage *img = [self image];
	NSSize imgSize = [img size];
	NSPoint drawPoint = NSMakePoint(cellFrame.origin.x + 33, cellFrame.origin.y + cellFrame.size.height);

	// Fine tuning.
	drawPoint.y -= 2;

	[img compositeToPoint:drawPoint fromRect:NSMakeRect(0, 0, imgSize.width, imgSize.height) operation:NSCompositeSourceOver fraction:1.0];

//
//  AMIndeterminateProgressIndicatorCell.m
//  IPICellTest
//
//  Created by Andreas on 23.01.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//
	if (animationTimer) {
		cellFrame = NSInsetRect(cellFrame, 2, 2);
		cellFrame.origin.x += 9;
		
		float flipFactor = ([controlView isFlipped] ? 1.0 : -1.0);
		int step = round([self doubleValue]/(5.0/60.0));
		float cellSize = MIN(cellFrame.size.width, cellFrame.size.height);
		NSPoint center = cellFrame.origin;
		center.x += cellSize/2.0;
		center.y += cellFrame.size.height/2.0;
		float outerRadius;
		float innerRadius;
		float strokeWidth = cellSize*0.08;
		if (cellSize >= 32.0) {
			outerRadius = cellSize*0.38;
			innerRadius = cellSize*0.23;
		} else {
			outerRadius = cellSize*0.48;
			innerRadius = cellSize*0.27;
		}
		float a; // angle
		NSPoint inner;
		NSPoint outer;
		[NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
		[NSBezierPath setDefaultLineWidth:strokeWidth];
		a = (270+(step* 30))*DEG2RAD;
		a = flipFactor*a;
		int i;
		for (i = 0; i < 12; i++) {
			[[NSColor colorWithCalibratedWhite:MIN(sqrt(i)*0.25, 0.8) alpha:1.0] set];
			outer = NSMakePoint(center.x+cos(a)*outerRadius, center.y+sin(a)*outerRadius);
			inner = NSMakePoint(center.x+cos(a)*innerRadius, center.y+sin(a)*innerRadius);
			[NSBezierPath strokeLineFromPoint:inner toPoint:outer];
			a -= flipFactor*30*DEG2RAD;
		}
	}
	
	[controlView unlockFocus];
}

- (void)startAnimationInTable:(NSTableView*)table column:(NSTableColumn*)column
{
	if(animationTimer == nil) {
		tableView = table;
		tableColumn = column;
		animationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0/60.0 target:self selector:@selector(animate:) userInfo:nil repeats:YES];
	}
}

- (void)animate:(id)sender
{
	if ([[tableView window] isVisible]) {
		double value = fmod(([self doubleValue] + (5.0/60.0)), 1.0);
		[self setDoubleValue:value];
		// redraw column
		int columnIndex = [[tableView tableColumns] indexOfObject:tableColumn];
		NSRect redrawRect = [tableView rectOfColumn:columnIndex];
		[tableView setNeedsDisplayInRect:redrawRect];
	}
}

- (void)stopAnimation
{
	[animationTimer invalidate];
	[self animate:nil];
}



@end
