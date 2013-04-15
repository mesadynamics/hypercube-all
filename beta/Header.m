//
//  Header.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/28/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "Header.h"


@implementation Header

- (void)drawRect:(NSRect)rect
{
	[[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] set];
	NSRectFill(rect);

	NSRect lineRect = [self frame];
	lineRect.origin.x = 0;
	lineRect.origin.y = lineRect.size.height - 23;
	lineRect.size.height = 23;
	
	if(NSIntersectsRect(rect, lineRect)) {
		NSImage* image = [NSImage imageNamed:@"BlackBar"];
		[image drawInRect:lineRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
}

@end
