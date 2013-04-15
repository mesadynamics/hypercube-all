//
//  WidgetController.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/7/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "WidgetManager.h"
#import "DownCloud.h"


@interface WidgetController : NSWindowController {
    IBOutlet WebView* webView;
    IBOutlet NSPanel* configure;
	IBOutlet NSPopUpButton* level;
	IBOutlet NSPopUpButton* drag;
	IBOutlet NSPopUpButton* background;
	IBOutlet NSSlider* opacity;
	IBOutlet NSButton* goOpaque;
 	
	NSString* widgetCode;
	NSString* domain;

	NSTrackingRectTag tracker;

	int configLevel;
	int configDrag;

	int optionLevel;
	int optionDrag;
	int optionBackground;
	int optionOpacity;
	NSPoint optionLocation;
	NSSize optionSize;
	BOOL optionGoOpaque;
		
	BOOL isInHypercube;
	BOOL isInGallery;
	
	BOOL isReady;
	BOOL willBeVisible;
	BOOL shouldHideOnReady;
	BOOL didSetTitle;
		
	BOOL foundOptions;
	BOOL foundGlobals;
	BOOL allowBrowserSpawning;
	BOOL allowSleeping;
	BOOL allowPausing;
	BOOL allowHosting;
	
	BOOL didPause;
	NSView* widgetView;
	NSView* widgetParentView;

	BOOL isIPhoneApp;
	BOOL hasFlash;
	
	BOOL terminateNow;
	BOOL readyAfterAdjust;
	BOOL doSyndicate;
	BOOL doReduceCPU;
	BOOL doExport;
	
	BOOL exportDashboard;
	BOOL exportYahoo;
	
	// dc
	DownCloud* dc;
}

- (BOOL)loadWidget:(NSString*)identifier;
- (BOOL)loadSnippet:(NSString*)snippet;
- (BOOL)loadRequest:(NSURLRequest*)request;

- (void)ready;
- (void)show;
- (void)hide;

- (BOOL)isReady;
- (BOOL)isOrWillBeVisible;
- (BOOL)adjustReady:(id)sender;
- (BOOL)adjustSize:(id)sender;
- (void)checkForFlash:(BOOL)force;

- (IBAction)handleHide:(id)sender;
- (IBAction)handleShow:(id)sender;
- (IBAction)handleClose:(id)sender;
- (IBAction)handleReload:(id)sender;
- (IBAction)handleRedraw:(id)sender;

- (IBAction)handleOpenConfigure:(id)sender;
- (IBAction)handleCloseConfigure:(id)sender;
- (IBAction)handleOpacity:(id)sender;

- (void)setOptionLevel:(int)value;
- (void)setOptionDrag:(int)value;
- (void)setOptionBackground:(int)value;
- (void)setOptionOpacity:(int)value;

- (void)readOptions;
- (void)writeOptions;

- (void)launchURL:(NSURL*)url;
- (void)redraw;
//- (void)redrawFlash:(id)sender;

- (void)broadcastAdd:(id)sender;
@end

@interface WebPreferences (Private)
- (void)setCacheModel:(WebCacheModel)cacheModel;
@end

