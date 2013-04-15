//
//  GalleryGrid.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/22/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GalleryGrid : NSMatrix {
	BOOL featured;
	NSAttributedString* fTitle;
	NSAttributedString* oTitle;
	NSBezierPath* fStroke;
	NSBezierPath* oStroke;
}

- (void)setFeatured:(BOOL)value;

@end
