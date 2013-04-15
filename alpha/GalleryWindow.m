//
//  GalleryWindow.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/21/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "GalleryWindow.h"


@implementation GalleryWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	NSWindow* result = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[result setBackgroundColor:[NSColor colorWithDeviceWhite:0.00 alpha:.60]];
	[result setLevel:NSPopUpMenuWindowLevel - 3]; 
	[result setAlphaValue:1.0];
	[result setOpaque:NO];
	[result setHasShadow:NO];

	[result setMovableByWindowBackground:NO];
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

@end
