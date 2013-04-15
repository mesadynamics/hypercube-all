//
//  GalleryController.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/21/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "GalleryGrid.h"	

//#define TransparentGallery	1


@interface GalleryController : NSWindowController {
    IBOutlet WebView* webView;
	IBOutlet GalleryGrid* grid;
	IBOutlet NSTextField* title;
	IBOutlet NSBox* box;
	
	NSButton* homeButton;
	NSButton* backButton;
	NSButton* forwardButton;
	NSButton* scrollUpButton;
	NSButton* scrollDownButton;

	NSButton* presets[7];
	
	NSString* home;

	NSRect gridFrame;
	NSRect boxFrame;
	NSTrackingRectTag tracker;
	
	BOOL isSilent;
	BOOL isSpoofing;
	
#if defined(TransparentGallery)
	id domObject;
	BOOL hasFlash;
	BOOL hasTransparentFlash;
#endif

	id widgetManager;
}

- (WebView*)webView;
- (GalleryGrid*)grid;
- (void)setGalleryTitle:(NSString*)string;

- (void)setWidgetManager:(id)object;
- (void)createButtons:(id)target;
- (void)adjustGridForCount:(int)count;

- (void)startBrowser:(BOOL)forInfo;
- (void)stopBrowser;

- (void)setHome:(NSString*)homeURL spoof:(BOOL)spoof;
- (void)goHome;

- (void)checkScrollers;
- (void)scrollDown;
- (void)scrollUp;

- (void)showPresets:(BOOL)value;
- (void)setPresetButton:(int)tag;

@end
