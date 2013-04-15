//
//  GlassButton.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/29/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "GlassButton.h"


@implementation GlassButton


- (void)mouseDown:(NSEvent *)theEvent
{
	if([self menu]) {
		NSImage* img = [[self image] retain];
		NSImage* alt = [self alternateImage];
		[self setImage:alt];
		[self display];
		[[self window] update];
		[NSMenu popUpContextMenu:[self menu] withEvent:theEvent forView:self];
		[self setImage:img];
		[img release];
	}
	else
		[super mouseDown:theEvent];
}

@end
