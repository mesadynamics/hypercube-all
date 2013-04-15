//
//  StyledWindow.m
//
//  Created by Jeff Ganyard on 11/3/06.
//  rev 2: 11/15/06 - now supports toolbars properly
/*
	Copyright (c) 2006 Bithaus.

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

	Sending an email to ganyard (at) bithaus.com informing where the code is being used would be appreciated.
 */

/*
 Additionally Pimping by Mark Hill, MachineCodex Software 25.08.2007
 * Modified the styledBackground method so that:
	* CTGradients are drawn direct into the bg image
	* Enforced the use of accessors to get at the various styling properties
 * Added lazy default value setting to all accessors
 * Declared a bunch of static floats for key styling values
 * Added more support for NSToolbar
 */

/*
 further pimpage - jeff ganyard 09 oct 2007
 added separate gradient for bottom border
 final (I hope) support for toolbars
 */

#import "StyledWindow.h"

static float kTopGradientHeight			= 76.0; // dje
static float kTopGradientStartWhite		= 0.77;
static float kTopGradientEndWhite		= 0.59;
static float kTopBorderEdgeWhite		= 0.34;

static float kBottomGradientHeight		= 28.0; // dje
static float kBottomGradientStartWhite	= 0.76;
static float kBottomGradientEndWhite	= 0.59;
static float kBottomBorderEdgeWhite		= 0.25;

static float kBackgroundWhite			= 1.0;

@implementation StyledWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
{
	unsigned int newStyle;
	
	topBorderStartColor = nil;
	topBorderEndColor = nil;
	topBorderEdgeColor = nil;
	
	bottomBorderStartColor = nil;
	bottomBorderEndColor = nil;
	bottomBorderEdgeColor = nil;
	
	bgColor = nil;
	
	if (styleMask & NSTexturedBackgroundWindowMask) {
		newStyle = styleMask;
	} else {
		newStyle = (NSTexturedBackgroundWindowMask | styleMask);
	}
	if (self = [super initWithContentRect:contentRect styleMask:newStyle backing:bufferingType defer:flag]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self];

		[self setBackgroundColor:[self styledBackground]];

		return self;
	}
	return nil;
}

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
- (void)setToolbar:(NSToolbar *)toolbar
{
	// Only actually call this if we respond to it on this machine
	if ([toolbar respondsToSelector:@selector(setShowsBaselineSeparator:)]) {
		[toolbar setShowsBaselineSeparator:NO];
	}
	[super setToolbar:toolbar];

	[self setBackgroundColor:[self styledBackground]];
	[self display];
}
#endif

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:self];
	
	[topBorderStartColor release];
	[topBorderEndColor release];
	[topBorderEdgeColor release];
	
	[bottomBorderStartColor release];
	[bottomBorderEndColor release];
	[bottomBorderEdgeColor release];

	[topGradient release];
	[bottomGradient release];
	
	[super dealloc];
}

- (void)windowDidResize:(NSNotification *)aNotification
{
	[self setBackgroundColor:[self styledBackground]];
	if ([self forceDisplay]) {
		[self display];
	}
}

//- (void)setMinSize:(NSSize)aSize
//{
//	[super setMinSize:NSMakeSize(MAX(aSize.width, 150.0), MAX(aSize.height, 150.0))];
//}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animationFlag
{
	[self setForceDisplay:YES];
	[super setFrame:frameRect display:displayFlag animate:animationFlag];
	[self setForceDisplay:NO];
}

#pragma mark -
#pragma mark Background

- (NSColor *)styledBackground
{
	extern SInt32 gMacVersion;
	if(gMacVersion < 0x1040) {
		return bgColor;
	}
	
	float winHeight = [self frame].size.height;
    float topCombinedHeight = ([self toolbarHeight] + [self topBorderHeight]);
	NSImage *bg = [[NSImage alloc] initWithSize:NSMakeSize(1,winHeight)];

	[bg lockFocus];

	[[self bgColor] set];
	NSRectFill(NSMakeRect(0, 0, 1, winHeight));

    [[self topGradient] fillRect:NSMakeRect(0, winHeight - topCombinedHeight, 1, topCombinedHeight) angle:90];
	[[self topBorderEdgeColor] set];
	NSRectFill(NSMakeRect(0, winHeight - topCombinedHeight, 1, 1));

	[[self bottomGradient] fillRect:NSMakeRect(0, 0, 1, [self bottomBorderHeight]) angle:90];
	[[self bottomBorderEdgeColor] set];
	NSRectFill(NSMakeRect(0, bottomBorderHeight, 1, 1));

	[bg unlockFocus];
	
	return [NSColor colorWithPatternImage:[bg autorelease]];
}

- (BOOL)forceDisplay
{
	return forceDisplay;
}

- (void)setForceDisplay:(BOOL)flag
{
	forceDisplay = flag;
}

#pragma mark -
#pragma mark Gradients

- (void)refreshTopGradient 
{
	[self setTopGradient:[CTGradient gradientWithBeginningColor:[self topBorderEndColor] endingColor:[self topBorderStartColor]]];	
}

- (void)refreshBottomGradient 
{	
	[self setBottomGradient:[CTGradient gradientWithBeginningColor:[self bottomBorderEndColor] endingColor:[self bottomBorderStartColor]]];	
}

- (CTGradient *)topGradient;
{
    if(!topGradient)
		[self refreshTopGradient];
    
    return [[topGradient retain] autorelease];    
}
- (void)setTopGradient:(CTGradient *)value;
{
    if (topGradient != value) {
        [topGradient release];
        topGradient = [value retain];
    }    
}

- (CTGradient *)bottomGradient;
{
    if(!bottomGradient)
		[self refreshBottomGradient];
    
    return [[bottomGradient retain] autorelease];    
}
- (void)setBottomGradient:(CTGradient *)value;
{
    if (bottomGradient != value) {
        [bottomGradient release];
        bottomGradient = [value retain];
    }    
}

#pragma mark -
#pragma mark Heights

- (float)toolbarHeight
{
    NSRect windowFrame = [NSWindow contentRectForFrameRect:[self frame] styleMask:[self styleMask]];
    float toolbarHeight = NSHeight(windowFrame) - NSHeight([[self contentView] frame]);

    return toolbarHeight;
}

- (float)topBorderHeight
{
	if (!topBorderHeight)
		[self setTopBorderHeight:kTopGradientHeight];

    return topBorderHeight;
}

- (void)setTopBorderHeight:(float)value
{
	topBorderHeight = value;
}


- (float)bottomBorderHeight
{
	if (!bottomBorderHeight) {
		[self setBottomBorderHeight:kBottomGradientHeight];        
    }
	return bottomBorderHeight;
}

- (void)setBottomBorderHeight:(float)value
{
	bottomBorderHeight = value;
}

#pragma mark -
#pragma mark Top Colors

- (NSColor *)topBorderStartColor
{
	if (!topBorderStartColor) {
		[self setTopBorderStartColor:[NSColor colorWithDeviceWhite:kTopGradientStartWhite alpha:1.0]];
	}
	return topBorderStartColor; 
}
- (void)setTopBorderStartColor:(NSColor *)color
{
	if (topBorderStartColor != color) {
		[color retain];
		[topBorderStartColor release];
		topBorderStartColor = color;
        [self refreshTopGradient];
        [self display];
	}
}

- (NSColor *)topBorderEndColor
{
	if (!topBorderEndColor) {
		[self setTopBorderEndColor:[NSColor colorWithDeviceWhite:kTopGradientEndWhite alpha:1.0]];
	}
	return topBorderEndColor; 
}
- (void)setTopBorderEndColor:(NSColor *)color
{
	if (topBorderEndColor != color) {
		[color retain];
		[topBorderEndColor release];
		topBorderEndColor = color;
        [self refreshTopGradient];
        [self display];
	}
}

- (NSColor *)topBorderEdgeColor
{
	if (!topBorderEdgeColor) {
		[self setTopBorderEdgeColor:[NSColor colorWithDeviceWhite:kTopBorderEdgeWhite alpha:1.0]];
	}
	return topBorderEdgeColor; 
}
- (void)setTopBorderEdgeColor:(NSColor *)color
{
	if (topBorderEdgeColor != color) {
		[color retain];
		[topBorderEdgeColor release];
		topBorderEdgeColor = color;
	}
}

#pragma mark -
#pragma mark Bottom Colors

- (NSColor *)bottomBorderStartColor
{
	if (!bottomBorderStartColor) {
		[self setBottomBorderStartColor:[NSColor colorWithDeviceWhite:kBottomGradientStartWhite alpha:1.0]];
	}
	return bottomBorderStartColor; 
}
- (void)setBottomBorderStartColor:(NSColor *)color
{
	if (bottomBorderStartColor != color) {
		[color retain];
		[bottomBorderStartColor release];
		bottomBorderStartColor = color;
        [self refreshBottomGradient];
	}
}

- (NSColor *)bottomBorderEndColor
{
	if (!bottomBorderEndColor) {
		[self setBottomBorderEndColor:[NSColor colorWithDeviceWhite:kBottomGradientEndWhite alpha:1.0]];
	}
	return bottomBorderEndColor; 
}
- (void)setBottomBorderEndColor:(NSColor *)color
{
	if (bottomBorderEndColor != color) {
		[color retain];
		[bottomBorderEndColor release];
		bottomBorderEndColor = color;
        [self refreshBottomGradient];
	}
}

- (NSColor *)bottomBorderEdgeColor
{
	if (!bottomBorderEdgeColor) {
		[self setBottomBorderEdgeColor:[NSColor colorWithDeviceWhite:kBottomBorderEdgeWhite alpha:1.0]];
	}
	return bottomBorderEdgeColor; 
}
- (void)setBottomBorderEdgeColor:(NSColor *)color
{
	if (bottomBorderEdgeColor != color) {
		[color retain];
		[bottomBorderEdgeColor release];
		bottomBorderEdgeColor = color;
	}
}

#pragma mark -
#pragma mark Background Color

- (NSColor *)bgColor
{
	if (!bgColor) {
		[self setBgColor:[NSColor colorWithDeviceWhite:kBackgroundWhite alpha:1.0]];
	}
	return bgColor; 
}
- (void)setBgColor:(NSColor *)newBgColor
{
	if (bgColor != newBgColor) {
		[newBgColor retain];
		[bgColor release];
		bgColor = newBgColor;
	}
}

@end
