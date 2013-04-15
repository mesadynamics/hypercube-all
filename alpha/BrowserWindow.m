//
//  BrowserWindow.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/19/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "BrowserWindow.h"


@implementation BrowserWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	shouldRedoInitials = YES;
	forceDisplay = NO;
	tracker = 0;
	
	if((aStyle & NSResizableWindowMask) != 0)
		canResize = YES;
	else
		canResize = NO;

	NSWindow* result = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[result setBackgroundColor:[NSColor clearColor]];
	[result setLevel:NSFloatingWindowLevel]; 
	[result setAlphaValue:1.0];
	[result setOpaque:NO];
	[result setHasShadow:NO];

	[result setMovableByWindowBackground:NO];
	[result setAcceptsMouseMovedEvents:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self];
	
	return (id)result;
}

- (void)awakeFromNib
{
	NSButton* closeButton = [[NSButton alloc] initWithFrame:NSMakeRect(4.0, [self frame].size.height - 18.0, 14.0, 14.0)];
    [[self contentView] addSubview:closeButton];
    [closeButton setBezelStyle:NSRoundedBezelStyle];
    [closeButton setButtonType:NSMomentaryChangeButton];
    [closeButton setBordered:NO];
    [closeButton setImage:[NSImage imageNamed:@"BrowserClose"]];
    [closeButton setTitle:@""];
    [closeButton setImagePosition:NSImageBelow];
    [closeButton setTarget:[self delegate]];
    [closeButton setFocusRingType:NSFocusRingTypeNone];
    [closeButton setAction:@selector(close)];
	[closeButton setAutoresizingMask:( NSViewMinYMargin )]; 
	[closeButton release];

	if(canResize) {
		NSButton* resizeButton = [[NSButton alloc] initWithFrame:NSMakeRect([self frame].size.width - 16.0, 0.0, 16.0, 16.0)];
		[[self contentView] addSubview:resizeButton];
		[resizeButton setBezelStyle:NSRoundedBezelStyle];
		[resizeButton setButtonType:NSMomentaryChangeButton];
		[resizeButton setBordered:NO];
		[resizeButton setImage:[NSImage imageNamed:@"BrowserResize"]];
		[resizeButton setTitle:@""];
		[resizeButton setImagePosition:NSImageBelow];
		[resizeButton setTarget:self];
		[resizeButton setFocusRingType:NSFocusRingTypeNone];
	   // [resizeButton setAction:@selector(orderOut:)];
		[resizeButton setEnabled:NO];
		[resizeButton setAutoresizingMask:( NSViewMinXMargin )]; 
		[resizeButton release];
	}
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (BOOL)canBecomeMainWindow
{
	return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];    

	if(tracker) {
		[[self contentView] removeTrackingRect:tracker];
		tracker = 0;
	}

    [super dealloc];
}

- (void)windowDidResize:(NSNotification *)aNotification
{
    [self setBackgroundColor:[BrowserWindow backgroundImageForFrame:[self frame] withTitle:[self title]]];
	
    if(forceDisplay)
        [self display];

	if(tracker) {
		[[self contentView] removeTrackingRect:tracker];
		tracker = 0;
	}
	
	NSRect frame = [self frame];
	frame.origin.x = 0.0;
	frame.origin.y = 0.0;	
	
	tracker = [[self contentView] addTrackingRect:frame owner:[self contentView] userData:nil assumeInside:NO];
}

- (void)setTitle:(NSString *)value
{
    [super setTitle:value];
    [self windowDidResize:nil];
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animationFlag
{
    forceDisplay = YES;
    [super setFrame:frameRect display:displayFlag animate:animationFlag];
    forceDisplay = NO;
}

- (void)orderOut:(id)sender
{
	[[self parentWindow] removeChildWindow:self];
	[super orderOut:sender];
}

+ (NSColor *)backgroundImageForFrame:(NSRect)frame withTitle:(NSString*)title
{
    float alpha = 1.0;   
    float titlebarHeight = 19.0;
    NSImage *bg = [[NSImage alloc] initWithSize:frame.size];
    [bg lockFocus];
    
    // Make background path
    NSRect bgRect = NSMakeRect(0, 0, [bg size].width, [bg size].height);
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 6.0;
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
    [bgPath appendBezierPathWithArcFromPoint:bgRect.origin 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [bgPath closePath];
    
    // Composite background color into bg
	NSColor *c0 = [NSColor colorWithDeviceRed:0.004 green:0.027 blue:.024 alpha:alpha];
 	[c0 set];
   [bgPath fill];
    
    // Make titlebar path
    NSRect titlebarRect = NSMakeRect(0, [bg size].height - titlebarHeight, [bg size].width, titlebarHeight);
    minX = NSMinX(titlebarRect);
    midX = NSMidX(titlebarRect);
    maxX = NSMaxX(titlebarRect);
    minY = NSMinY(titlebarRect);
    midY = NSMidY(titlebarRect);
    maxY = NSMaxY(titlebarRect);
    NSBezierPath *titlePath = [NSBezierPath bezierPath];
    
	float max = [bg size].height * .4;
	
    // Bottom edge and bottom-right curve
    [titlePath moveToPoint:NSMakePoint(minX, minY-max)];
    [titlePath lineToPoint:NSMakePoint(maxX, minY-max)];
    
    // Right edge and top-right curve
    [titlePath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:radius];
    
    // Top edge and top-left curve
    [titlePath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, minY) 
                                      radius:radius];
    
    [titlePath closePath];

    // Titlebar
    NSColor *c1 = [NSColor colorWithDeviceRed:0.165 green:0.176 blue:.184 alpha:alpha];
    //NSColor *c2 = [NSColor colorWithDeviceRed:0.004 green:0.027 blue:.024 alpha:alpha];
	//[titlePath fillGradientFrom:c1 to:c2];
	[c1 set];
	[titlePath fill];
 
			{
    NSRect bgRect = NSMakeRect(20, 20, [bg size].width-40, [bg size].height-40);
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 6.0;
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
    [bgPath appendBezierPathWithArcFromPoint:bgRect.origin 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [bgPath closePath];

	[[NSColor colorWithDeviceWhite:.1 alpha:1.0] set];
   [bgPath fill];
		}
		
   
    // Title
    NSFont* titleFont = [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]];
    NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle alloc] init];
	[paraStyle autorelease];
	
    [paraStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    [paraStyle setAlignment:NSCenterTextAlignment];
    [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
    NSDictionary* txtDict = [NSDictionary dictionaryWithObjectsAndKeys:
        titleFont, NSFontAttributeName,
        [NSColor colorWithDeviceRed:.314*2.0 green:.353*2.0 blue:.345*2.0 alpha:1.0], NSForegroundColorAttributeName,
        paraStyle, NSParagraphStyleAttributeName,
        nil];
    
    NSSize titleSize = [title sizeWithAttributes:txtDict];
    // We vertically centre the title in the titlbar area, and we also horizontally 
    // inset the title by 19px, to allow for the 3px space from window's edge to close-widget, 
    // plus 13px for the close widget itself, plus another 3px space on the other side of 
    // the widget.


	[NSGraphicsContext saveGraphicsState]; 
	NSShadow* theShadow = [[NSShadow alloc] init]; 
	[theShadow setShadowOffset:NSMakeSize(-2, 2)]; 
	[theShadow setShadowBlurRadius:0.3]; 

	[theShadow setShadowColor:[NSColor colorWithDeviceRed:.031 green:.071 blue:.059 alpha:1.0]]; 
	[theShadow set];

    NSRect titleRect = NSInsetRect(titlebarRect, 19.0, (titlebarRect.size.height - titleSize.height) / 2.0);
    [title drawInRect:titleRect withAttributes:txtDict];
    [bg unlockFocus];
  
	[NSGraphicsContext restoreGraphicsState];
	[theShadow release]; 
  
    return [NSColor colorWithPatternImage:[bg autorelease]];
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
		
		if (canResize && initialLocation.x > initialFrame.size.width - 20.0 && initialLocation.y < 20.0) {
			shouldDrag = NO;
		}
		else {
			//mouseDownType = PALMOUSEDRAGSHOULDMOVE;
			shouldDrag = YES;
		}
		
		screenFrame = [[NSScreen mainScreen] frame];
		windowFrame = [self frame];
		
		minHeight = windowFrame.origin.y+(windowFrame.size.height-200);
	}
	
	// 1. Is the Event a resize drag (test for bottom right-hand corner)?
	if (shouldDrag == NO)
	{
		// i. Remember the current downpoint
		NSPoint currentLocationOnScreen = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
		currentLocation = [theEvent locationInWindow];
		
		// ii. Adjust the frame size accordingly
		float heightDelta = (currentLocationOnScreen.y - initialLocationOnScreen.y);
		
		if ((initialFrame.size.height - heightDelta) < 201)
		{
			windowFrame.size.height = 200;
			//windowFrame.origin.y = initialLocation.y-(initialLocation.y - windowFrame.origin.y)+heightDelta;
			windowFrame.origin.y = minHeight;
		} else
		{
			windowFrame.size.height = (initialFrame.size.height - heightDelta);
			windowFrame.origin.y = (initialFrame.origin.y + heightDelta);
		}
		
		windowFrame.size.width = initialFrame.size.width + (currentLocation.x - initialLocation.x);
		if (windowFrame.size.width < 301)
		{
			windowFrame.size.width = 300;
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
		
		screenFrame = [[NSScreen mainScreen] visibleFrame];
		
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

#if 0
@implementation NSBezierPath (Additions)

- (void)fillGradientFrom:(NSColor*)inStartColor to:(NSColor*)inEndColor
{
	CIImage*	coreimage;
	
	inStartColor = [inStartColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	inEndColor = [inEndColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		
	CIColor* startColor = [CIColor colorWithRed:[inStartColor redComponent] green:[inStartColor greenComponent] blue:[inStartColor blueComponent] alpha:[inStartColor alphaComponent]];
	CIColor* endColor = [CIColor colorWithRed:[inEndColor redComponent] green:[inEndColor greenComponent] blue:[inEndColor blueComponent] alpha:[inEndColor alphaComponent]];
	
	CIFilter* filter;
	
	filter = [CIFilter filterWithName:@"CILinearGradient"];
	[filter setValue:startColor forKey:@"inputColor0"];
	[filter setValue:endColor forKey:@"inputColor1"];
	
	CIVector* startVector;
	CIVector* endVector;
	
	endVector = [CIVector vectorWithX:0.0 Y:[self bounds].origin.y];
	startVector = [CIVector vectorWithX:[self bounds].size.width Y:[self bounds].origin.y];
		
	[filter setValue:startVector forKey:@"inputPoint0"];
	[filter setValue:endVector forKey:@"inputPoint1"];
	
	coreimage = [filter valueForKey:@"outputImage"];
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	
	CIContext* context;
	
	context = [[NSGraphicsContext currentContext] CIContext];
	
	[self setClip];
	
	[context drawImage:coreimage atPoint:CGPointZero fromRect:CGRectMake([self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width, [self bounds].origin.y+[self bounds].size.height)];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end

#endif
