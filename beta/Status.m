//
//  Status.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/28/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "Status.h"
//#import "CTGradient.h"


@implementation Status

- (void)drawRect:(NSRect)rect
{
	//extern SInt32 gMacVersion;

	//if(gMacVersion < 0x1040) {
		[[NSColor colorWithCalibratedRed:.59 green:.62 blue:.67 alpha:1.0] set];
		NSRectFill(rect);
	//}
	//else
	//	[[CTGradient panelGradient] fillRect:rect angle:90];

	NSRect lineRect = [self frame];
	lineRect.origin.x = 0;
	lineRect.origin.y = 0;

	NSImage* image = [NSImage imageNamed:@"LCD"];
	[image drawInRect:lineRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

	lineRect.origin.y = lineRect.size.height-1;
	lineRect.size.height = 1;
	[[NSColor colorWithCalibratedWhite:.25 alpha:1.0] set];
	NSRectFill(lineRect);
	//lineRect.origin.y = 0;
	//[[NSColor colorWithCalibratedWhite:.75 alpha:1.0] set];
	//NSRectFill(lineRect);


	//[super drawRect:rect];
}

@end
