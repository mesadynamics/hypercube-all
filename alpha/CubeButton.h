//
//  CubeButton.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 6/14/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CubeButton : NSButton {
	NSImage* overImage;
	NSTrackingRectTag tracker;
	BOOL mouseIn;
	BOOL didFlip;
	
	NSSound* enterSound;
}

- (id)initWithFrame:(NSRect)frameRect imageNamed:(NSString*)image inWindow:(NSWindow*)window;

@end
