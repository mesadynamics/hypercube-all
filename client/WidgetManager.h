//
//  WidgetManager.h
//  HypercubeClient
//
//  Created by Danny Espinoza on 12/11/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WidgetManager : NSObject {
	NSWindowController* widget;
}

+ (int)markerFromCode:(NSString*)code;
+ (NSString*)domainFromCode:(NSString*)code;
+ (NSString*)identifierFromCode:(NSString*)code;

+ (void)exportToDashboard:(NSString*)code title:(NSString*)name image:(NSImage*)image identifier:(NSString*)identifier dashboard:(NSString*)dashboardID width:(int)width height:(int)height;

- (id)initWithController:(NSWindowController*)controller;
- (IBAction)handleHide:(id)sender;
- (IBAction)handleShow:(id)sender;
- (IBAction)handleClose:(id)sender;

@end

@interface NSProxy (HypercubeServer)
- (void)widgetIsLoading:(NSString*)identifier;
- (void)widgetIsHiding:(NSString*)identifier;
- (void)widgetIsShowing:(NSString*)identifier;
- (void)widgetIsClosing:(NSString*)identifier;
@end;
