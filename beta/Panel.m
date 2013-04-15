//
//  Panel.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/28/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "Panel.h"
//#import "CTGradient.h"


@implementation Panel

- (void)drawRect:(NSRect)rect
{
	//extern SInt32 gMacVersion;

	//if(gMacVersion < 0x1040) {
		[[NSColor colorWithCalibratedRed:.439 green:.529 blue:.607 alpha:1.0] set];
		NSRectFill(rect);
	//}
	//else
	//	[[CTGradient panelGradient] fillRect:rect angle:270];

	NSRect lineRect = [self frame];
	lineRect.origin.x = 0;
	lineRect.origin.y = 0;

	lineRect.origin.y = lineRect.size.height-1;
	lineRect.size.height = 1;
	[[NSColor colorWithCalibratedWhite:.50 alpha:1.0] set];
	NSRectFill(lineRect);

	//[super drawRect:rect];
}

@end
