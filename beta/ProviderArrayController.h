//
//  ProviderArrayController.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/28/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WidgetManager.h"


@interface ProviderArrayController : NSArrayController {
    IBOutlet NSTableView* tableView;
	IBOutlet WidgetManager* manager;
	
	int floor;
}

- (NSTableView*)tableView;
- (void)toggleProvider:(id)sender;

- (void)setFloor:(int)index;

- (IBAction)userDelete:(id)sender;
- (IBAction)rename:(id)sender;
- (IBAction)open:(id)sender;

@end
