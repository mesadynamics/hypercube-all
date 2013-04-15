//
//  WidgetArrayController.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/28/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WidgetManager.h"


@interface WidgetArrayController : NSArrayController {
    IBOutlet NSTableView* tableView;
	IBOutlet WidgetManager* manager;
	IBOutlet NSTextField* providerTitle;
	NSString* searchString;
}

- (NSTableView*)tableView;
- (void)toggleWidget:(id)sender;

- (IBAction)search:(id)sender;

- (IBAction)installDashboard:(id)sender;

- (IBAction)userLaunch:(id)sender;
- (IBAction)userShow:(id)sender;
- (IBAction)userHide:(id)sender;
- (IBAction)userClose:(id)sender;
- (IBAction)userDelete:(id)sender;

- (IBAction)rename:(id)sender;
- (IBAction)retag:(id)sender;

- (void)setSearchString:(NSString *)string;

@end
