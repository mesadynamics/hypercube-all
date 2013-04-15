//
//  DimText.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 1/4/08.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "DimText.h"
#import "DimTextCell.h"


@implementation DimText

+ (Class)cellClass
{
	return [DimTextCell class];
}

- initWithCoder: (NSCoder *)origCoder
{
	if(![origCoder isKindOfClass: [NSKeyedUnarchiver class]]){
		self = [super initWithCoder: origCoder]; 
	} else {
		NSKeyedUnarchiver *coder = (id)origCoder;
		
		NSString *oldClassName = [[[self superclass] cellClass] className];
		Class oldClass = [coder classForClassName: oldClassName];
		if(!oldClass)
			oldClass = [[super superclass] cellClass];
		[coder setClass: [[self class] cellClass] forClassName: oldClassName];
		self = [super initWithCoder: coder];
		[coder setClass: oldClass forClassName: oldClassName];
	}
	
	return self;
}

@end
