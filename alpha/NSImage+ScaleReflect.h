//
//  NSImage+ScaleReflect.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/24/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (ScaleReflect)

+ (NSImage*)scaleImage:(NSImage*)image toSize:(NSSize)size;
+ (NSImage*)scaleImage:(NSImage*)image toSize:(NSSize)size alignX:(int)alignX alignY:(int)alignY;
+ (NSImage *)reflectImage:(NSImage *)image;

@end
