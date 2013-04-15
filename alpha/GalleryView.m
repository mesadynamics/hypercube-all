//
//  GalleryView.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/22/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "GalleryView.h"

#define CUBEALPHA	.40
#define CUBERATIO	6.0

@implementation GalleryView

- (void)awakeFromNib
{
	border = nil;
	//cubeImage = nil;
	
	maxRefresh = NO;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:[self window]];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];    
	[[NSNotificationCenter defaultCenter] removeObserver:self];    

	[border release];
	//[cubeImage release];
		
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{
#if 0
	if(cubeImage) {
		NSRect cubeFrame = NSInsetRect(frame, frame.size.width / CUBERATIO, frame.size.height / CUBERATIO);

		[cubeImage drawInRect:cubeFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:CUBEALPHA];
		
		NSBezierPath* path = [NSBezierPath bezierPath];
		
			[path moveToPoint:NSMakePoint(0.0, 0.0)];
			[path lineToPoint:NSMakePoint(cubeFrame.origin.x, cubeFrame.origin.y)];
			
			[path moveToPoint:NSMakePoint(0.0, frame.size.height)];
			[path lineToPoint:NSMakePoint(cubeFrame.origin.x, cubeFrame.origin.y + cubeFrame.size.height)];
		
			[path moveToPoint:NSMakePoint(frame.size.width, frame.size.height)];
			[path lineToPoint:NSMakePoint(cubeFrame.origin.x + cubeFrame.size.width, cubeFrame.origin.y + cubeFrame.size.height)];
		
			[path moveToPoint:NSMakePoint(frame.size.width, 0.0)];
			[path lineToPoint:NSMakePoint(cubeFrame.origin.x + cubeFrame.size.width, cubeFrame.origin.y)];
			
			[path appendBezierPathWithRect:cubeFrame];
		
		[path closePath];
		
		[[NSColor colorWithDeviceWhite:CUBEALPHA/2.0 alpha:1.0] set];
		[path stroke];	
	}
#endif

	[[NSColor colorWithDeviceWhite:0.05 alpha:1.0] set];
	[border fill];
	
	[[NSColor colorWithDeviceWhite:.80 alpha:1.0] set];
	[border stroke];
}

- (void)setNeedsDisplayInRect:(NSRect)invalidRect
{
	if(maxRefresh) {
		if(NSIntersectsRect(invalidRect, refreshRect)) {
			NSRect contentFrame = [self frame];
			contentFrame.origin.x = 0.0;
			contentFrame.origin.y = 0.0;
			[super setNeedsDisplayInRect:contentFrame];
		}
		else
			[super setNeedsDisplayInRect:invalidRect];
	}
	else
		[super setNeedsDisplayInRect:invalidRect];
}

- (void)setMaxRefresh:(BOOL)value
{
	maxRefresh = value;
}

- (void)setRefreshRect:(NSRect)value
{
	refreshRect = value;
}

#if 0
- (void)setCubeImage:(NSImage*)image
{
	cubeImage = [image retain];
	
	NSRect frame = [self frame];
	NSRect cubeFrame = NSInsetRect(frame, frame.size.width / CUBERATIO, frame.size.height / CUBERATIO);

	NSSize imageSize = NSMakeSize(cubeFrame.size.width, cubeFrame.size.height);
	[cubeImage setSize:imageSize];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if(NSPointInRect([theEvent locationInWindow], galleryFrame) == NO)
		[[self window] close];
}

#endif

// Notifications
- (void)windowDidResize:(NSNotification *)aNotification
{
	NSRect frame = [self frame];
	
	// Make background path
    NSRect galleryFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height);
	galleryFrame = NSInsetRect(galleryFrame, 100.0, 100.0);
	
	if(galleryFrame.size.width > galleryFrame.size.height)
		galleryFrame.size.width = (galleryFrame.size.width + galleryFrame.size.height) / 2.0;
	else
		galleryFrame.size.height = (galleryFrame.size.width + galleryFrame.size.height) / 2.0;

	if(galleryFrame.size.width < 832.0)
		galleryFrame.size.width = 832.0;

	galleryFrame.origin.x = (frame.size.width - galleryFrame.size.width) * .5;
	galleryFrame.origin.y = (frame.size.height - galleryFrame.size.height) * .5;

    int minX = NSMinX(galleryFrame);
    int midX = NSMidX(galleryFrame);
    int maxX = NSMaxX(galleryFrame);
    int minY = NSMinY(galleryFrame);
    int midY = NSMidY(galleryFrame);
    int maxY = NSMaxY(galleryFrame);
    float radius = 20.0;
	
	[border release];
    border = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [border moveToPoint:NSMakePoint(midX, minY)];
    [border appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                     toPoint:NSMakePoint(maxX, midY) 
                                      radius:radius];
    
	[border appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:radius];
     
    // Top edge and top-left curve
    [border appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:radius];
    
    // Left edge and bottom-left curve
    [border appendBezierPathWithArcFromPoint:galleryFrame.origin 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [border closePath];
	[border setLineWidth:2.0];
	[border retain];
}

@end
