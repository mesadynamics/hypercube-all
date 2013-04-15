//
//  WidgetTable.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/28/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMRemovableColumnsTableView.h"


@interface WidgetTable : AMRemovableColumnsTableView {
	IBOutlet NSTextField* providerTitle;
	NSString* saveEdit;
}

@end
