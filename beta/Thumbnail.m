//
//  Thumbnail.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/27/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "Thumbnail.h"


@implementation Thumbnail

- (void)drawRect:(NSRect)rect
{
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];

	[super drawRect:rect];
}

@end
