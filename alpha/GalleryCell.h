//
//  GalleryCell.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/23/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GalleryCell : NSButtonCell {
	NSString* identifier;
	BOOL featured;
}

+ (NSImage*)getMirroredImage:(NSImage*)image scale:(BOOL)scale;

- (NSString*)getIdentifier;
- (void)setIdentifier:(NSString*)name;
- (void)setFeatured:(BOOL)value;

- (void)setGalleryImage:(NSImage*)image;
- (void)setGalleryTitle:(NSString*)string;

@end
