//
//  StyledWindow.h
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

#import <Cocoa/Cocoa.h>
#import "CTGradient.h"

@interface StyledWindow : NSWindow
{
	BOOL forceDisplay;

	float topBorderHeight;
	float bottomBorderHeight;
	float titleBarHeight;
	
	NSColor *topBorderStartColor;
	NSColor *topBorderEndColor;
	NSColor *topBorderEdgeColor;
	
	NSColor *bottomBorderStartColor;
	NSColor *bottomBorderEndColor;
	NSColor *bottomBorderEdgeColor;
	
	NSColor *bgColor;

	CTGradient *topGradient;
	CTGradient *bottomGradient;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;

- (NSColor *)styledBackground;

- (BOOL)forceDisplay;
- (void)setForceDisplay:(BOOL)flag;

- (float)toolbarHeight;

- (float)topBorderHeight;
- (void)setTopBorderHeight:(float)newTopBorderHeight;

- (float)bottomBorderHeight;
- (void)setBottomBorderHeight:(float)newBottomBorderHeight;

- (NSColor *)topBorderStartColor;
- (void)setTopBorderStartColor:(NSColor *)newTopBorderStartColor;

- (NSColor *)topBorderEndColor;
- (void)setTopBorderEndColor:(NSColor *)newTopBorderEndColor;

- (NSColor *)topBorderEdgeColor;
- (void)setTopBorderEdgeColor:(NSColor *)newTopBorderEdgeColor;

- (NSColor *)bottomBorderStartColor;
- (void)setBottomBorderStartColor:(NSColor *)newBottomBorderStartColor;

- (NSColor *)bottomBorderEndColor;
- (void)setBottomBorderEndColor:(NSColor *)newBottomBorderEndColor;

- (NSColor *)bottomBorderEdgeColor;
- (void)setBottomBorderEdgeColor:(NSColor *)newBottomBorderEdgeColor;

- (NSColor *)bgColor;
- (void)setBgColor:(NSColor *)newBgColor;

- (CTGradient *)topGradient;
- (void)setTopGradient:(CTGradient *)value;

- (CTGradient *)bottomGradient;
- (void)setBottomGradient:(CTGradient *)value;

@end
