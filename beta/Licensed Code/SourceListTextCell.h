//
//  SourceListTextCell.h
//  TableTester
//
//  Created by Matt Gemmell on Thu Dec 25 2003.
//  Copyright (c) 2003 Scotland Software. All rights reserved.
//


#import <Cocoa/Cocoa.h>


@interface SourceListTextCell : NSTextFieldCell {
	BOOL mIsEditingOrSelecting;
}

- (NSString*) truncateString:(NSString *)string forWidth:(double) inWidth andAttributes:(NSDictionary*)inAttributes;


@end
