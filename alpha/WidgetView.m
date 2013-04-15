//
//  WidgetView.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/7/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "WidgetView.h"

BOOL gSuspendWidgetView = NO;

enum {
	configInverseText1 = 2000,
	configInverseText2 = 2001,
	configInverseText3 = 2002
};

@implementation WidgetView

- (void)awakeFromNib
{
	badge = nil;
	saveBadge = nil;
	fillColor = nil;
	altMenu = nil;
	
	mouseIn = NO;
	fader = nil;
	fadeValue = 0;

	switchProcess = NO;

	maxRefresh = NO;
	
	NSDictionary* txtDict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont systemFontOfSize:11.0], NSFontAttributeName,
		[NSColor colorWithDeviceWhite:.80 alpha:1.0], NSForegroundColorAttributeName,
		nil];
		
	NSButton* button = (NSButton*) [self viewWithTag:configInverseText1];
	NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:[button title] attributes:txtDict];
	[button setAttributedTitle:attrStr];
	[attrStr release];
	
	button = (NSButton*) [self viewWithTag:configInverseText2];
	attrStr = [[NSAttributedString alloc] initWithString:[button title] attributes:txtDict];
	[button setAttributedTitle:attrStr];
	[attrStr release];
	
	button = (NSButton*) [self viewWithTag:configInverseText3];
	attrStr = [[NSAttributedString alloc] initWithString:[button title] attributes:txtDict];
	[button setAttributedTitle:attrStr];
	[attrStr release];
}

- (void)dealloc
{
	[fillColor release];
	[badge release];
	
	[super dealloc];
}

- (void)setFillColor:(NSColor*)color
{
	[fillColor release];
	fillColor = [color retain];
}

- (void)setPopupMenu:(NSMenu*)menu
{
	if(menu) {
		altMenu = [self menu];
		[self setMenu:menu];
	}
	else {
		[self setMenu:altMenu];
		altMenu = nil;
	}
}

- (void)loadBadge
{
	badge = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Options" ofType:@"png"]];	

	NSPoint currentLocation = [[self window] mouseLocationOutsideOfEventStream];
	NSPoint viewLocation = [self convertPoint:currentLocation fromView:nil];
	if([self mouse:viewLocation inRect:[self frame]])
		[self mouseEntered:nil];
}

- (void)hideBadge:(BOOL)set
{
	if(set) {
		saveBadge = badge;
		badge = nil;

		[fader invalidate];
		fader = nil;
		
		fadeValue = 0;
	}
	else {
		badge = saveBadge;
		saveBadge = nil;
		
		mouseIn = NO;
	}
}

- (void)zeroBadge
{
	[fader invalidate];
	fader = nil;
	
	fadeValue = 0;

	mouseIn = NO;
}

- (void)drawRect:(NSRect)aRect
{
	if(badge && (mouseIn || fader)) {
		NSRect frame = [self frame];
		NSRect badgeFrame = NSMakeRect(frame.origin.x + frame.size.width - 20.0, frame.origin.y + frame.size.height - 20.0, 20.0, 20.0);
		[badge drawInRect:badgeFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:(float)fadeValue / 100.0];
	}
	else if(saveBadge) {	
		NSRect frame = [self frame];
		frame.origin.x += frame.size.width - 250.0;
		frame.origin.y += frame.size.height - 175.0;
		frame.size.width = 250.0;
		frame.size.height = 175.0;
		
		frame = NSInsetRect(frame, 2.0, 2.0);
				
		int minX = NSMinX(frame);
		int midX = NSMidX(frame);
		int maxX = NSMaxX(frame);
		int minY = NSMinY(frame);
		int midY = NSMidY(frame);
		int maxY = NSMaxY(frame);
		float radius = 10.0;
		
		NSBezierPath *bgPath = [NSBezierPath bezierPath];
		
		// Bottom edge and bottom-right curve
		[bgPath moveToPoint:NSMakePoint(midX, minY)];
		[bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
										 toPoint:NSMakePoint(maxX, midY) 
										  radius:radius];
		
		[bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
										 toPoint:NSMakePoint(midX, maxY) 
										  radius:radius];
		 
		// Top edge and top-left curve
		[bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
										 toPoint:NSMakePoint(minX, midY) 
										  radius:radius];
		
		// Left edge and bottom-left curve
		[bgPath appendBezierPathWithArcFromPoint:frame.origin 
										 toPoint:NSMakePoint(midX, minY) 
										  radius:radius];
		[bgPath closePath];
		[[NSColor colorWithDeviceWhite:0.1 alpha:1.0] set];
		[bgPath fill];
	}
	
	if(fillColor) {
		NSRect frame = [self frame];
		
		if(saveBadge)
			frame.size.width -= 250.0;
		else
			frame.size.width -= 20;
			
		NSBezierPath* fill = [NSBezierPath bezierPathWithRect:frame];
		[fillColor set];
		[fill fill];
	}
}

- (void)handleFade:(id)sender
{
	if(mouseIn) {
		if(fadeValue < 100)
			fadeValue += 20;
		else {
			[fader invalidate];
			fader = nil;
		}
	}
	else {
		if(fadeValue > 0)
			fadeValue -= 20;
		else {
			[fader invalidate];
			fader = nil;
		}
	}
		
	NSRect aRect = [self frame];
	NSRect badgeFrame = NSMakeRect(aRect.origin.x + aRect.size.width - 20.0, aRect.origin.y + aRect.size.height - 20.0, 20.0, 20.0);
	[self setNeedsDisplayInRect:badgeFrame];
	[[self window] update];
	[[self window] flushWindow];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (void)mouseEntered:(NSEvent*)theEvent
{
	if(gSuspendWidgetView)
		return;
		
	NSWindow* modal = [NSApp modalWindow];
	if(modal)
		return;

	switchProcess = NO;

	if([[self window] level] == NSFloatingWindowLevel) {
		GetFrontProcess(&lastFrontProcess);
		
		ProcessSerialNumber currentProcess;
		GetCurrentProcess(&currentProcess);
		
		Boolean result;
		SameProcess(&lastFrontProcess, &currentProcess, &result);
		if(result == false) {
			[NSApp activateIgnoringOtherApps:YES];
			switchProcess = YES;
		}
	}
	
	[[self window] makeKeyWindow];
	
	mouseIn = YES;

	if(fader == nil)
		fader = [NSTimer
			scheduledTimerWithTimeInterval:(double) 0.05
			target:self
			selector:@selector(handleFade:)
			userInfo:nil
			repeats:YES];
}

- (void)mouseExited:(NSEvent*)theEvent
{
	if(gSuspendWidgetView)
		return;

	mouseIn = NO;

	if(fader == nil)
		fader = [NSTimer
			scheduledTimerWithTimeInterval:(double) 0.05
			target:self
			selector:@selector(handleFade:)
			userInfo:nil
			repeats:YES];
			
	if(switchProcess) {		
		ProcessSerialNumber frontProcess;
		GetFrontProcess(&frontProcess);
		
		ProcessSerialNumber currentProcess;
		GetCurrentProcess(&currentProcess);
		
		Boolean result;
		SameProcess(&frontProcess, &currentProcess, &result);
		
		if(result)
			SetFrontProcessWithOptions(&lastFrontProcess, kSetFrontProcessFrontWindowOnly);
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint local_point = [self convertPoint:event_location fromView:nil];
	
	NSRect frame = [self frame];
	local_point.x = frame.size.width - local_point.x;
	local_point.y = frame.size.height - local_point.y;
	
	if(local_point.x <= 20.0 && local_point.y <= 20.0) {
		mousePoint = [NSEvent mouseLocation];
		menuIn = YES;
	}	
	else
		menuIn = NO;
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if(menuIn) {
		/*NSPoint event_location = [theEvent locationInWindow];
		NSPoint local_point = [self convertPoint:event_location fromView:nil];
		
		NSRect frame = [self frame];
		local_point.x = frame.size.width - local_point.x;
		local_point.y = frame.size.height - local_point.y;*/
		
		if(NSEqualPoints([NSEvent mouseLocation], mousePoint))
			[NSMenu popUpContextMenu:[self menu] withEvent:theEvent forView:self];
	}
	
	menuIn = NO;
}

- (void)suspend
{
	gSuspendWidgetView = YES;
	switchProcess = NO;
	
	[self mouseExited:nil];
}

- (void)resume
{
	gSuspendWidgetView = NO;
}

- (void)setNeedsDisplayInRect:(NSRect)invalidRect
{
	if(maxRefresh) {
		if(NSIntersectsRect(invalidRect, refreshRect))
			[super setNeedsDisplayInRect:[self frame]];
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

@end
