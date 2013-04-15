//
//  WidgetController.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/7/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface WidgetController : NSWindowController {
    IBOutlet WebView* webView;
    IBOutlet NSBox* configPanel1;
    IBOutlet NSBox* configPanel2;
    IBOutlet NSBox* confirmPanel;
    IBOutlet NSTextField* configName;
    IBOutlet NSTextField* configLevelTitle;
    IBOutlet NSButton* configSleep;
    IBOutlet NSButton* configPause;
    IBOutlet NSButton* configHost;
	
	id widgetManager;
	NSString* widgetCode;
	NSString* domain;

	SInt32 macVersion;

	NSTrackingRectTag tracker;

	int configLevel;
	int configDrag;

	int optionLevel;
	int optionDrag;
	int optionBackground;
	int optionOpacity;
	NSPoint optionLocation;
		
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
}

- (WebView*)getWebView;

- (NSString*)getIdentifier;
- (void)setIdentifier:(NSString*)name;
- (NSString*)getDomain;
- (void)setDomain:(NSString*)name;

- (BOOL)getHypercube;
- (void)setHypercube:(BOOL)hypercube;
- (BOOL)getGallery;
- (void)setGallery:(BOOL)gallery;

- (void)setWidgetManager:(id)object;

- (void)loadSnippet:(NSString*)snippet syndicate:(BOOL)syndicate;
- (void)loadRequest:(NSURLRequest*)request;

- (void)show;
- (void)hide;
- (void)focus;

- (BOOL)isReady;
- (BOOL)isOrWillBeVisible;
- (BOOL)adjustSize:(id)sender;
- (void)checkForFlash:(BOOL)force;

- (void)broadcastAdd:(id)sender;
- (void)broadcastRemove:(id)sender;

- (IBAction)handleHide:(id)sender;
- (IBAction)handleClose:(id)sender;
- (IBAction)handleLevel:(id)sender;
- (IBAction)handleDrag:(id)sender;
- (IBAction)handleDashboard:(id)sender;
- (IBAction)handleDesktop:(id)sender;
- (IBAction)handleHypercube:(id)sender;
- (IBAction)handleUninstall:(id)sender;
- (IBAction)handleReload:(id)sender;
- (IBAction)handleRedraw:(id)sender;
- (IBAction)handleScreenshot:(id)sender;

- (IBAction)handleInfo:(id)sender;
- (IBAction)handleOpacity:(id)sender;
- (IBAction)handleBackground:(id)sender;
- (IBAction)handleConfigure1:(id)sender;
- (IBAction)handleConfigure2:(id)sender;
- (IBAction)handleSettings:(id)sender;
- (IBAction)handleConfirmNo:(id)sender;
- (IBAction)handleConfirmYes:(id)sender;

- (void)resetOptionLevel;
- (void)setOptionLevel:(int)value;
- (void)setOptionDrag:(int)value;
- (void)setOptionBackground:(int)value;
- (void)setOptionOpacity:(int)value;

- (void)readOptions;
- (void)writeOptions;

- (void)launchURL:(NSURL*)url;
- (void)redraw;
- (void)redrawFlash:(id)sender;
@end
