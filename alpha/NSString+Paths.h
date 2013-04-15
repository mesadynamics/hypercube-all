//
//  NSString+Paths.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/23/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (Paths)

+ (NSBezierPath *) createPathForString:(NSString*)string withFont:(NSFont *) font withX: (float)x withY: (float)y;

@end
