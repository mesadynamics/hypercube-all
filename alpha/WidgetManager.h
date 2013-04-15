//
//  WidgetManager.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/13/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WidgetController.h"
#import "BrowserController.h"
#import "GalleryController.h"


@interface WidgetManager : NSObject {
	NSString* cubeDomain;
	NSSound* switchSound;
	NSSound* clickSound;
	NSSound* welcomeSound;

	NSMutableDictionary* providers;
	NSMutableDictionary* coders;
	NSMutableDictionary* tags;
	
	BOOL usingDefaultLibrary;
	int updateDay; // day of last update
	int updateHash; // widgets served since last update
	BOOL isUpdating;
	BOOL syndicate;
	int preset;

	NSMutableArray* providersFeatured;
	NSMutableArray* providersHidden;
	NSMutableArray* providersSpoofed;
	
	NSMutableDictionary* widgets; // code library
	NSMutableDictionary* menus; // menu items (desktop only)
	NSMutableDictionary* instances; // widget controllers
	
	NSMutableArray* desktop;
	NSMutableArray* hypercube;
	NSMutableArray* hidden;
	
	NSMutableDictionary* images; // generic image library (e.g. providers)
	
	BOOL isInHypercube;
	BOOL isInGallery;
	
	NSMenu* widgetMenu;

	NSString* createTitle;
	BOOL createTitleCustom;
	NSString* createThumbnail;
	BOOL createThumbnailCustom;
	
	int galleryMode;
	NSTextField* cubeTitle;
	NSWindow* cube;
	NSWindow* gallery;
	NSMutableArray* cubeWindows;
	NSMutableArray* galleryWindows;

	int imageSessionCount;
	NSTimer* imageSessionTimer;
	NSMutableDictionary* imageSessions;
	NSMutableDictionary* sessionData;
	NSMutableDictionary* sessionID;
	
	// client integration
	char* widgetData;
	NSString* widgetName;
}

+ (NSDictionary*)widgetWithCode:(id)code title:(id)title image:(id)image;
+ (int)markerFromCode:(NSString*)code;
+ (NSString*)domainFromCode:(NSString*)code;
+ (NSString*)identifierFromCode:(NSString*)code;

- (id)initWithMenu:(NSMenu*)menu inCube:(NSString*)domain;

- (WidgetController*)createWidgetController;
- (BrowserController*)createBrowserController;

- (BOOL)testWidgetWithCode:(NSString*)code;
- (BOOL)installWidgetWithCode:(NSString*)code create:(BOOL)create force:(BOOL)force;
- (BOOL)verifyCode:(NSString*)code;
- (BOOL)matchCode:(NSString*)code fromDomain:(NSString*)domain andPrefix:(NSString*)prefix withTitle:(NSString*)title;

- (WidgetController*)createWidget:(NSString*)code identifier:(NSString*)identifier domain:(NSString*)domain;
- (BOOL)addWidget:(NSString*)code title:(NSString*)title image:(NSImage*)image identifier:(NSString*)identifier;

- (void)addMenuItem:(NSString*)identifier title:(NSString*)title image:(NSImage*)image;
- (void)menuItemAction:(id)sender;

- (void)writeToPath:(NSString*)path;
- (void)readFromPath:(NSString*)path andCreate:(BOOL)create;
- (void)readFromNet;

- (void)writeDomain:(NSString*)domain;
- (void)readDomain:(NSString*)domain;

- (void)hideWidgets;
- (void)showWidgets:(BOOL)all;

- (BOOL)isInHypercube;
- (BOOL)isInGallery;

- (void)setPreset:(id)sender;

// called by WidgetController
- (void)loadWidget:(NSString*)identifier;
- (void)closeWidget:(NSString*)identifier;
- (void)removeWidget:(NSString*)identifier;
- (void)forgetWidget:(NSString*)identifier inDomain:(NSString*)domain;

- (NSString*)infoForWidget:(NSString*)identifier key:(NSString*)key;
- (void)setInfoForWidget:(NSString*)identifier key:(NSString*)key object:(id)object;

- (void)addToDashboard:(NSString*)code identifier:(NSString*)identifier dashboard:(NSString*)dashboardID width:(int)width height:(int)height;

- (void)addToDesktop:(NSString*)identifier;
- (void)addToHypercube:(NSString*)identifier;
- (void)removeFromDesktop:(NSString*)identifier;
- (void)removeFromHypercube:(NSString*)identifier;

- (void)openCube;
- (void)closeCube;

- (NSArray*)filteredProviders;

- (void)setupGallery:(int)mode;
- (void)openGallery:(id)sender;
- (void)setupGalleryLibrary;
- (void)galleryLibraryAction:(id)sender;
- (void)setupGalleryCubes;
- (void)galleryCubeAction:(id)sender;
- (void)setupGalleryProviders;
- (void)galleryProviderAction:(id)sender;
- (void)resetProviders;
- (void)closeGallery;
//

//- (NSImage*)getDesktopImage;

- (void)loadLibrary;
- (void)updateLibrary:(id)sender;
- (void)parseLibrary:(NSString*)xml;
- (void)parseWidgets:(NSString*)xml;
- (void)buildDefaultLibrary;
- (int)getWidgetVersion;

- (void)pollImageSessions:(id)sender;

@end
