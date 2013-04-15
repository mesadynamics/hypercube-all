//
//  BrowserView.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/19/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BrowserView : NSView {
	ProcessSerialNumber lastFrontProcess;
	BOOL mouseIn;
	BOOL switchProcess;
}

@end
