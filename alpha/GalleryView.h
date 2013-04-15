//
//  GalleryView.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/22/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GalleryView : NSView {	
	NSBezierPath* border;
	//NSImage* cubeImage;
	
	BOOL maxRefresh;
	NSRect refreshRect;
 }

- (void)setMaxRefresh:(BOOL)value;
- (void)setRefreshRect:(NSRect)value;
//- (void)setCubeImage:(NSImage*)image;

@end
