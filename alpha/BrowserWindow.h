//
//  BrowserWindow.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/19/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface BrowserWindow : NSWindow {
	BOOL canResize;
	
	BOOL shouldDrag;
	BOOL shouldRedoInitials;
	NSPoint initialLocation;
	NSPoint initialLocationOnScreen;
	NSRect initialFrame;
	NSPoint currentLocation;
	NSPoint newOrigin;
	NSRect screenFrame;
	NSRect windowFrame;
	float minHeight;
	
    BOOL forceDisplay;

	NSTrackingRectTag tracker;
}

+ (NSColor *)backgroundImageForFrame:(NSRect)frame withTitle:(NSString*)title;

@end
