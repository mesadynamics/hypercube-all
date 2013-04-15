//
//  SourceListImageCell.h
//  TableTester
//
//  Created by Matt Gemmell on Mon Dec 29 2003.
//  Copyright (c) 2003 Scotland Software. All rights reserved.
//


#import <Cocoa/Cocoa.h>


@interface SourceListImageCell : NSImageCell {
	NSTimer* animationTimer;
	NSTableView* tableView;
	NSTableColumn* tableColumn;
}

- (void)startAnimationInTable:(NSTableView*)table column:(NSTableColumn*)column;
- (void)animate:(id)sender;
- (void)stopAnimation;

@end
