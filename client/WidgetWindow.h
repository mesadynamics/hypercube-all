//
//  WidgetWindow.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/7/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WidgetWindow : NSWindow {
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
}

@end


@interface ConfigureWindow : NSPanel
@end