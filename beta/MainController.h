//
//  MainController.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/21/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "WidgetManager.h"
#import "Provider.h"
#import "AMRemovableColumnsTableView.h"


@interface MainController : NSWindowController {
	IBOutlet NSWindow* preferences;
	IBOutlet NSView* sourceViewPanel;
	IBOutlet NSView* mainViewPanel;

	IBOutlet NSView* mainViewContainer;
	IBOutlet NSView* mainViewContainerTop;
	IBOutlet NSView* mainViewContainerBottom;
	
	IBOutlet NSView* sourceView;
	IBOutlet NSView* mainViewBrowser;
	IBOutlet NSView* mainViewList;
	IBOutlet NSView* mainViewData;
	IBOutlet NSView* mainViewStoreData;
	IBOutlet NSView* mainViewDashboardData;
	IBOutlet NSView* mainViewYahooData;

	IBOutlet NSView* dragView;
	IBOutlet WebView* webView;
	IBOutlet NSButton* infoToggle;
	
	IBOutlet NSTextField* help;
	IBOutlet NSView* helpView;
	NSWindow* helpWindow;
	
	IBOutlet NSArrayController* providersArrayController;
	IBOutlet NSArrayController* widgetsArrayController;
	NSMutableArray* providers;
	NSMutableDictionary* selections;

	IBOutlet NSSearchField* search;
	IBOutlet NSPanel* create;
	IBOutlet NSTextField* createName;
	IBOutlet NSTextField* createCode;
	
	IBOutlet NSTextField* counter;
	IBOutlet NSTextField* webTitle;
	IBOutlet NSTextField* providerTitle;

	IBOutlet WidgetManager* manager;
	
	NSString* browserURLString;
	NSString* providerURLString;
	NSString* destinationLinkKey;
	NSString* providerInfoKey;

	int pasteCount;
	NSString* pasteBuffer;
	NSTimer* pasteTimer;
	
	BOOL launching;
	BOOL creating;
	
	NSTableColumn* saveColumn;
	int saveColumnIndex;
	
	int floor;
	
	IBOutlet NSWindow* about;

	// updates
	NSURLConnection* session;
	NSMutableData* sessionData;
}

- (IBAction)handleUpdate:(id)sender;
- (IBAction)handleContact:(id)sender;
- (IBAction)handleLicense:(id)sender;
- (IBAction)handleCredits:(id)sender;
- (IBAction)handleNotes:(id)sender;
- (IBAction)handleHelp:(id)sender;

- (void)setup:(id)sender;
- (void)setupIconForProvider:(NSString*)key atDomain:(NSString*)domain;
- (Provider*)setupProvider:(NSString*)key withTitle:(NSString*)title;

- (NSMutableArray*)createProviders;

- (void)openProvider:(NSString*)urlString;
- (NSString*)providerURLString;
- (void)openBrowser:(NSString*)urlString;
- (void)openBrowser:(NSString*)urlString destination:(NSString*)destination;
- (void)closeBrowser;
- (void)switchInfo:(NSString*)infoKey;

- (void)updateHelp:(id)sender;

- (void)openStore;
- (void)closeStore;

- (NSMutableArray*)providers;
- (void)setProviders:(NSArray*)newProviders;
- (Provider*)providerWithKey:(NSString*)key;

- (IBAction)findWidget:(id)sender;
- (IBAction)homeBrowser:(id)sender;
- (IBAction)toggleContainerBottom:(id)sender;
- (IBAction)handleCreateOpen:(id)sender;
- (IBAction)handleCreateURL:(id)sender;
- (IBAction)handleCreateClose:(id)sender;
- (IBAction)handleUnlink:(id)sender;

- (IBAction)platformRefresh:(id)sender;
- (IBAction)platformReveal:(id)sender;
- (IBAction)platformMoreWidgets:(id)sender;
- (IBAction)destOpen:(id)sender;

- (void)renameProvider:(id)sender;
- (void)deleteProvider:(id)sender;
- (void)deleteWidget:(id)sender;
- (void)deleteWidgetFromLibrary:(id)sender;

- (void)handleIdle:(id)sender;

- (BOOL)findCodeInFrame:(WebFrame*)frame title:(NSString*)title;

- (void)webReady:(id)sender;
- (void)webReadyWithFrame:(WebFrame*)frame;

@end

@interface WebPreferences (Private)
- (void)setCacheModel:(WebCacheModel)cacheModel;
@end
