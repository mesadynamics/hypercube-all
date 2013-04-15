//
//  DimTextCell.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 1/4/08.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "DimTextCell.h"


@implementation DimTextCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(id)controlView
{
	NSColor* color = [self textColor];
	float r, g, b, a;
	[color getRed:&r green:&g blue:&b alpha:&a];

	BOOL saveEnabled = [self isEnabled];
	[self setEnabled:YES];
	
	if(saveEnabled)
		[self setTextColor:[NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0]];
	else
		[self setTextColor:[NSColor colorWithCalibratedRed:r green:g blue:b alpha:.5]];

	[super drawInteriorWithFrame:cellFrame inView:controlView];
	
	[self setEnabled:saveEnabled];
}


@end
