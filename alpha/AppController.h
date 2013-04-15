//
//  AppController.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 2/21/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WidgetManager.h"


@interface AppController : NSObject {
	NSStatusItem* statusItem;
	IBOutlet NSMenu* mainMenu;
	IBOutlet NSMenu* widgetMenu;

	IBOutlet NSWindow* theAbout;
	IBOutlet NSWindow* thePreferences;
		
	IBOutlet NSTextField* code;
	IBOutlet NSWindow* creator;
	
	WidgetManager* widgetManager;
	NSSound* createSound;
	
	int pasteCount;
	NSString* pasteBuffer;
	NSTimer* pasteTimer;
	
	// global prefs
	int hypercubeVersion;
	BOOL prefLaunchHidden;
	BOOL prefNoClickImport;
	BOOL prefReduceCPU; // OS X only
	BOOL prefUISound;
	BOOL prefCreateSound;
}

- (void)handleIdle:(id)sender;

- (IBAction)handleHypercube:(id)sender;
- (IBAction)handleGallery:(id)sender;
- (IBAction)handleCreateWidget:(id)sender;
- (IBAction)handleGetWidgets:(id)sender;
- (IBAction)handleHide:(id)sender;
- (IBAction)handleShow:(id)sender;
- (IBAction)handleShowAll:(id)sender;

- (void)readPrefs;
- (void)writePrefs;

- (BOOL)prefUISound;

- (IBAction)handleBeta:(id)sender;

// common
- (IBAction)handleAbout:(id)sender;
- (IBAction)handleUpdate:(id)sender;
- (IBAction)handleOnline:(id)sender;
- (IBAction)handleContact:(id)sender;

@end
