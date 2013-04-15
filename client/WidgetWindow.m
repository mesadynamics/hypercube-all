//
//  WidgetWindow.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/7/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "WidgetWindow.h"


@implementation WidgetWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	shouldRedoInitials = YES;
	
	NSRect farRect = contentRect;
	farRect.origin.x = 8192.0;
	farRect.origin.y = 8192.0;

	NSWindow* result = [super initWithContentRect:farRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[result setBackgroundColor:[NSColor clearColor]];
	[result setLevel:NSFloatingWindowLevel]; 
	[result setAlphaValue:1.0];
	[result setOpaque:NO];
	[result setHasShadow:NO];

	[result setMovableByWindowBackground:YES];
	[result setAcceptsMouseMovedEvents:YES];
		
	return (id)result;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (BOOL)canBecomeMainWindow
{
	return YES;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if([self isMovableByWindowBackground] || [self acceptsMouseMovedEvents] == NO)
		return;
	
	if (shouldRedoInitials)
	{
		initialLocation = [theEvent locationInWindow];
		initialLocationOnScreen = [self convertBaseToScreen:[theEvent locationInWindow]];
				
		initialFrame = [self frame];
		shouldRedoInitials = NO;
		
		if (initialLocation.x < 20.0 && initialLocation.y < 20.0) {
			shouldDrag = NO;
		}
		else {
			//mouseDownType = PALMOUSEDRAGSHOULDMOVE;
			shouldDrag = YES;
		}

		screenFrame = [[NSScreen mainScreen] frame];
		windowFrame = [self frame];
		
		minHeight = windowFrame.origin.y+(windowFrame.size.height-288);
	}
	
	// 1. Is the Event a resize drag (test for bottom right-hand corner)?
	if (shouldDrag == NO)
	{
		// i. Remember the current downpoint
		NSPoint currentLocationOnScreen = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
		currentLocation = [theEvent locationInWindow];
		
		// ii. Adjust the frame size accordingly
		float heightDelta = (currentLocationOnScreen.y - initialLocationOnScreen.y);
		
		if ((initialFrame.size.height - heightDelta) < 289)
		{
			windowFrame.size.height = 288;
			//windowFrame.origin.y = initialLocation.y-(initialLocation.y - windowFrame.origin.y)+heightDelta;
			windowFrame.origin.y = minHeight;
		} else
		{
			windowFrame.size.height = (initialFrame.size.height - heightDelta);
			windowFrame.origin.y = (initialFrame.origin.y + heightDelta);
		}
		
		windowFrame.size.width = initialFrame.size.width + (currentLocation.x - initialLocation.x);
		if (windowFrame.size.width < 323)
		{
			windowFrame.size.width = 323;
		}
		
		// iii. Set
		[self setFrame:windowFrame display:YES animate:NO];
	}
    else
	{
		//grab the current global mouse location; we could just as easily get the mouse location 
		//in the same way as we do in -mouseDown:
		currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
		newOrigin.x = currentLocation.x - initialLocation.x;
		newOrigin.y = currentLocation.y - initialLocation.y;
		
		// Don't let window get dragged up under the menu bar
		if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) )
		{
			newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
		}
		
		//go ahead and move the window to the new location
		[self setFrameOrigin:newOrigin];
		
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	shouldRedoInitials = YES;
}

@end


@implementation ConfigureWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	NSWindow* result = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[result setBackgroundColor:[NSColor clearColor]];
	[result setOpaque:NO];
	[result setHasShadow:NO];
    
	return (id)result;
}

@end