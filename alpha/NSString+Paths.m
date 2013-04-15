//
//  NSString+Paths.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/23/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "NSString+Paths.h"


@implementation NSString (Paths)

+ (NSBezierPath *) createPathForString:(NSString*)string withFont:(NSFont *) font withX: (float)x withY: (float)y
{
    NSTextView *textview;
    textview = [[NSTextView alloc] init];

    [textview setString: string];
    [textview setFont: font];

    NSLayoutManager *layoutManager;
    layoutManager = [textview layoutManager];

    NSRange range;
    range = [layoutManager glyphRangeForCharacterRange:
                               NSMakeRange (0, [string length])
                           actualCharacterRange: nil];
    NSGlyph *glyphs;
    glyphs = (NSGlyph *) malloc (sizeof(NSGlyph)
                                 * (range.length * 2));
    [layoutManager getGlyphs: glyphs  range: range];

    NSBezierPath *path;
    path = [NSBezierPath bezierPath];

    [path moveToPoint: NSMakePoint (x, y)];
    [path appendBezierPathWithGlyphs: glyphs
          count: range.length  inFont: font];

    free (glyphs);
    [textview release];

    return (path);

}

@end
