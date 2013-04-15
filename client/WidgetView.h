//
//  WidgetView.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/7/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WidgetView : NSView {
	NSImage* badge;
	
	NSColor* fillColor;

	BOOL mouseIn;
	BOOL menuIn;
	NSPoint mousePoint;
	
	NSTimer* fader;
	int fadeValue;

	ProcessSerialNumber lastFrontProcess;
	BOOL switchProcess;

	BOOL maxRefresh;
	NSRect refreshRect;
}

- (void)setFillColor:(NSColor*)color;

- (void)loadBadge;
- (void)zeroBadge;

- (void)handleFade:(id)sender;

- (void)suspend;
- (void)resume;

- (void)setMaxRefresh:(BOOL)value;
- (void)setRefreshRect:(NSRect)value;

@end


@interface ConfigureView : NSView
@end