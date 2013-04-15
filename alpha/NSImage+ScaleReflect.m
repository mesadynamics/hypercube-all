//
//  NSImage+ScaleReflect.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/24/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "NSImage+ScaleReflect.h"


@implementation NSImage (ScaleReflect)

+ (NSImage*)scaleImage:(NSImage*)image toSize:(NSSize)size
{
	return [NSImage scaleImage:image toSize:size alignX:0 alignY:0];
}

+ (NSImage*)scaleImage:(NSImage*)image toSize:(NSSize)size alignX:(int)alignX alignY:(int)alignY
{
	NSSize originalSize = [image size];
	NSSize scaledSize = size;
	
	if(originalSize.width > originalSize.height)
		scaledSize.height = (size.height * originalSize.height) / originalSize.width;
	else
		scaledSize.width = (size.width * originalSize.width) / originalSize.height;

	NSImage* icon = [[NSImage alloc] initWithSize:size];

	[icon lockFocus];
		float xoff = 0.0;
		float yoff = 0.0;
		
		if(alignX == 0)
			xoff = (size.width - scaledSize.width) * 0.50;
		else if(alignX == 1)
			xoff = (size.width - scaledSize.width);
			
		if(alignY == 0)
			yoff = (size.height - scaledSize.height) * 0.50;
		else if(alignY == 1)
			yoff = (size.height - scaledSize.height);
		
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		[image drawInRect:NSMakeRect(xoff, yoff, scaledSize.width, scaledSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[icon unlockFocus];
	
	return [icon autorelease];
}

+ (NSImage *)reflectImage:(NSImage *)image
{
	NSImage* reflection = [[NSImage alloc] initWithSize:[image size]];
	[reflection setFlipped:YES];

	[reflection lockFocus];

		NSImage* gradient = [NSImage imageNamed:@"Gradient"];
		[gradient drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
		
		[image drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeSourceIn fraction:1.0];
	
	[reflection unlockFocus];

	return [reflection autorelease];
}

@end
