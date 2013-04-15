//
//  MainController.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/21/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "MainController.h"
#import "StyledWindow.h"
#import "ProviderArrayController.h"
#import "WidgetArrayController.h"
#import "RBSplitView.h"
#import "Provider.h"
#import "Widget.h"
#import "AMRemovableColumnsTableView.h"
#import "MAAttachedWindow.h"


@implementation MainController

- (id)init
{
	if(self = [super init]) {
		NSMutableDictionary* defaultPrefs = [NSMutableDictionary dictionary];
		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SupportFacebook"];
 		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SupportFriendster"];
		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SupportOrkut"];
 		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SupportMySpace"];
 		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SupportHi5"];
		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SupportBebo"];
		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SupportWidgetbox"];  // v0.6
  		
		[defaultPrefs setObject:@"" forKey:@"FacebookUser"];
		[defaultPrefs setObject:@"" forKey:@"FacebookCube"];
		[defaultPrefs setObject:@"" forKey:@"FriendsterUser"];
		[defaultPrefs setObject:@"" forKey:@"FriendsterCube"];
		[defaultPrefs setObject:@"" forKey:@"OrkutUser"];
		[defaultPrefs setObject:@"" forKey:@"OrkutCube"];
		[defaultPrefs setObject:@"" forKey:@"MySpaceUser"];
		[defaultPrefs setObject:@"" forKey:@"MySpaceCube"];
		[defaultPrefs setObject:@"" forKey:@"Hi5User"];
		[defaultPrefs setObject:@"" forKey:@"Hi5Cube"];
		[defaultPrefs setObject:@"" forKey:@"BeboUser"];
		[defaultPrefs setObject:@"" forKey:@"BeboCube"];
				
		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"LaunchRememberWidgets"];
		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"LaunchDisplayMainWindow"];
		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SwitchDisplayMainWindow"];
		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"InstallHypercubeMenu"];
		[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"ShowHelpBalloons"];
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
		[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultPrefs];

		pasteCount = [[NSPasteboard generalPasteboard] changeCount];
		pasteBuffer = nil;
		pasteTimer = nil;
		
		launching = YES;
		creating = NO;
		
		saveColumn = nil;

		browserURLString = nil;
		providerURLString = nil;
		destinationLinkKey = nil;
		providerInfoKey = nil;
		
        providers = [self createProviders];

		WebPreferences* prefs = [webView preferences];
		if([prefs respondsToSelector:@selector(setCacheModel:)])
			[prefs setCacheModel:WebCacheModelPrimaryWebBrowser];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webReady:) name:WebViewProgressFinishedNotification object:webView];
		
		helpWindow = nil;
		
		// updates
		session = nil;
		sessionData = nil;
	}

	return self;
}

- (void)dealloc
{
    [providers release];
    [super dealloc];
}

- (void)setup:(id)sender
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSFileManager* fm = [NSFileManager defaultManager];

	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	if([fm fileExistsAtPath:libraryDirectory] == NO)
		[fm createDirectoryAtPath:libraryDirectory attributes:nil];
	
	NSString* resourceDirectory = [NSString stringWithFormat:@"%@/_Resources", libraryDirectory];
	if([fm fileExistsAtPath:resourceDirectory] == NO)
		[fm createDirectoryAtPath:resourceDirectory attributes:nil];
	
	NSString* adobePath = [NSString stringWithFormat:@"%@/Library/Preferences/Macromedia/Flash Player/#Security", NSHomeDirectory()];
	if([fm fileExistsAtPath:adobePath] == NO)
		[fm createDirectoryAtPath:adobePath attributes:nil];
	
	NSString* flashPath = [NSString stringWithFormat:@"%@/FlashPlayerTrust", adobePath];
	if([fm fileExistsAtPath:flashPath] == NO)
		[fm createDirectoryAtPath:flashPath attributes:nil];
	
	if([fm fileExistsAtPath:flashPath]) {
		NSBundle* securityBundle = [NSBundle mainBundle];
		NSString* securityPath = [NSString stringWithFormat:@"%@/HypercubeClient.app", [securityBundle resourcePath]];
		NSString* securityFile = [NSString stringWithFormat:@"%@/AmnestyHypercube.cfg", flashPath];
		
		if([fm fileExistsAtPath:securityFile] == NO) {
			NSString* securityString = [NSString stringWithFormat:@"%@\n", securityPath];
			[fm createFileAtPath:securityFile contents:[securityString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
		}
	}
	
	extern SInt32 gMacVersion;
	extern BOOL gPrivateWebKit;
	
	if(gMacVersion >= 0x1040 && gMacVersion < 0x1050) {
		NSFileManager* fm = [NSFileManager defaultManager];
		if([fm fileExistsAtPath:@"/System/Library/PrivateFrameworks/WebKitDashboardSupport.framework"]) {
			if([fm fileExistsAtPath:@"/Library/Application Support/Mesa Dynamics"] == NO)
				[fm createDirectoryAtPath:@"/Library/Application Support/Mesa Dynamics" attributes:nil];
			
			if([fm fileExistsAtPath:@"/Library/Application Support/Mesa Dynamics/Frameworks"] == NO) {
				NSString* frameworks = [NSString stringWithFormat:@"%@/Frameworks", [[NSBundle mainBundle] resourcePath]];
				[fm copyPath:frameworks toPath:@"/Library/Application Support/Mesa Dynamics/Frameworks" handler:nil];
			}
			
			gPrivateWebKit = YES;
		}
	}

	[self setupIconForProvider:@"_Facebook" atDomain:@"www.facebook.com"];
	[self setupIconForProvider:@"_Friendster" atDomain:@"www.friendster.com"];
	[self setupIconForProvider:@"_Bebo" atDomain:@"www.bebo.com"];
	[self setupIconForProvider:@"_Orkut" atDomain:@"www.orkut.com"];
	[self setupIconForProvider:@"_MySpace" atDomain:@"www.myspace.com"];
	[self setupIconForProvider:@"_Hi5" atDomain:@"www.hi5.com"];	
	
	[pool release];
}

- (void)setupIconForProvider:(NSString*)key atDomain:(NSString*)domain
{
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	NSString* resourceDirectory = [NSString stringWithFormat:@"%@/_Resources", libraryDirectory];
	NSString* iconPath = [NSString stringWithFormat:@"%@/%@.png", resourceDirectory, key];

	if([[NSFileManager defaultManager] fileExistsAtPath:iconPath] == NO) {
		NSImage* image = [NSImage imageNamed:[NSString stringWithFormat:@"%@.png", key]];
		if(image)
			return;

		NSString* urlString = [NSString stringWithFormat:@"http://%@/favicon.ico", domain];
		NSURL* url = [NSURL URLWithString:urlString];
		image = [[NSImage alloc] initByReferencingURL:url];
		if(image && [image isValid]) {
			[image setScalesWhenResized:YES];
			[image setSize:NSMakeSize(16.0, 16.0)];
			NSSize size = [image size]; 
			[image lockFocus];
			NSBitmapImageRep* bits = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0,0,size.width,size.height)];
			[image unlockFocus];				

			NSData* png = [bits representationUsingType:NSPNGFileType properties:nil];
			[png writeToFile:iconPath atomically:NO];
			
			//NSData* tif = [image TIFFRepresentation];
			//if(tif && [tif length] > 0)
				//[tif writeToFile:iconPath atomically:NO];
			
			[image release];
			
			Provider* provider = [self providerWithKey:key];
			[provider setIcon:[[[NSImage alloc] initWithContentsOfFile:iconPath] autorelease]];
		}
	}
}

- (Provider*)setupProvider:(NSString*)key withTitle:(NSString*)title
{
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	NSString* resourceDirectory = [NSString stringWithFormat:@"%@/_Resources", libraryDirectory];
	
	Provider* provider = [[Provider alloc] init];
	
	[provider setTitle:[NSString stringWithFormat:@"%@ ", title]];
	
	NSImage* image = [NSImage imageNamed:[NSString stringWithFormat:@"%@.png", key]];
	if(image)
		[provider setIcon:image];
	else {
		NSString* iconPath = [NSString stringWithFormat:@"%@/%@.png", resourceDirectory, key];
		if([[NSFileManager defaultManager] fileExistsAtPath:iconPath])
			[provider setIcon:[[[NSImage alloc] initWithContentsOfFile:iconPath] autorelease]];
	}
	
	[provider setCanEdit:[NSNumber numberWithBool:NO]];
	[provider setCanLink:[NSNumber numberWithBool:YES]];
	
	[provider setKey:key];
	[provider setStatus:[NSNumber numberWithInt:ProviderStatusNeedsToLoad]];
	
	return [provider autorelease];
}

- (void)awakeFromNib
{
	[NSApp setDelegate:self];

	[about setLevel:NSPopUpMenuWindowLevel+1];
 	[about center];

	StyledWindow* styledWindow = (StyledWindow*)[self window];
	[styledWindow setBackgroundColor:[styledWindow styledBackground]];

	[self setWindowFrameAutosaveName:@"MainWindow"];
	
	[[self window] setMinSize:NSMakeSize(800.0, 600.0)];
	
	BOOL firstLaunch = NO;
	if([[NSUserDefaults standardUserDefaults] stringForKey:@"NSWindow Frame MainWindow"] == nil) {
		[[self window] setFrame:NSMakeRect(0.0, 0.0, 820.0, 640.0) display:NO];
		[[self window] center];

		[preferences center];
		[styledWindow center];
		firstLaunch = YES;
	}
	
	[sourceView setFrameSize:[sourceViewPanel frame].size];
	[sourceViewPanel addSubview:sourceView];

	[mainViewContainer setFrameSize:[mainViewPanel frame].size];	
	[mainViewPanel addSubview:mainViewContainer];

	NSSize tableSize = [mainViewContainerTop frame].size;
	tableSize.width += 2;
	tableSize.height += 1;
	
	[mainViewBrowser setFrameSize:[mainViewContainerTop frame].size];	
	[mainViewList setFrameSize:tableSize];
	[mainViewList setFrameOrigin:NSMakePoint(-1, 0)];
	
	[mainViewContainerTop addSubview:mainViewList];

	[mainViewData setFrameSize:[mainViewContainerBottom frame].size];	
	[mainViewContainerBottom addSubview:mainViewData];
			
	if(firstLaunch) {
		RBSplitSubview* leading = (RBSplitSubview*)mainViewContainerBottom;
		[leading setHidden:YES];
	}	
		
	[[self window] display];
}

- (NSMutableArray*)createProviders
{
	id defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];

	BOOL facebookSupport = [[defaults valueForKey:@"SupportFacebook"] boolValue];
	BOOL friendsterSupport =  [[defaults valueForKey:@"SupportFriendster"] boolValue];
	BOOL orkutSupport =  [[defaults valueForKey:@"SupportOrkut"] boolValue];
	BOOL myspaceSupport =  [[defaults valueForKey:@"SupportMySpace"] boolValue];
	BOOL hi5Support =  [[defaults valueForKey:@"SupportHi5"] boolValue];
	BOOL beboSupport =  [[defaults valueForKey:@"SupportBebo"] boolValue];
	//BOOL widgetboxSupport =  [[defaults valueForKey:@"SupportWidgetbox"] boolValue];
	
	BOOL dashboardInstalled = NO;
	BOOL yahooInstalled = NO;
	
	NSFileManager* fm = [NSFileManager defaultManager];
	
	// Check for Dashboard installation
	extern SInt32 gMacVersion;
	if(gMacVersion >= 0x1040) {
		if([fm fileExistsAtPath:@"/Library/Widgets"])
			dashboardInstalled = YES;
	}

	// Check for Yahoo! installation
	NSString* yahooDirectory = [NSString stringWithFormat:@"%@/Documents/Widgets", NSHomeDirectory()];
	if([fm fileExistsAtPath:yahooDirectory])
		yahooInstalled = YES;

	NSString* publisherType = NSLocalizedString(@"Publishers", @"");
	
	Provider* widgetsHeader = [[[Provider alloc] init] autorelease];
	[widgetsHeader setTitle:[NSString stringWithFormat:@"%@\r", NSLocalizedString(@"TitleLibrary", @"")]];
	[widgetsHeader setIcon:[NSImage imageNamed:@"NoImage"]];
	[widgetsHeader setCanEdit:[NSNumber numberWithBool:NO]];
	[widgetsHeader setCanSelect:[NSNumber numberWithBool:NO]];
	[widgetsHeader setCanDrop:[NSNumber numberWithBool:NO]];
	[widgetsHeader setType:@"noop"];
	
	Provider* web = [[[Provider alloc] init] autorelease];
	[web setTitle:[NSString stringWithFormat:@"%@ ", NSLocalizedString(@"TitleLibraryHypercube", @"")]];
	[web setIcon:[NSImage imageNamed:@"IconWeb"]];
	[web setCanEdit:[NSNumber numberWithBool:NO]];
	[web setCanDrop:[NSNumber numberWithBool:NO]];
	[web setKey:@"_Web"];
	
	Provider* platformHeader = nil;
	if(dashboardInstalled || yahooInstalled) {
		platformHeader = [[[Provider alloc] init] autorelease];
		[platformHeader setTitle:[NSString stringWithFormat:@"%@\r", NSLocalizedString(@"TitlePlatform", @"")]];
		[platformHeader setIcon:[NSImage imageNamed:@"NoImage"]];
		[platformHeader setCanEdit:[NSNumber numberWithBool:NO]];
		[platformHeader setCanSelect:[NSNumber numberWithBool:NO]];
		[platformHeader setCanDrop:[NSNumber numberWithBool:NO]];
		[platformHeader setType:@"noop"];
	}
	
	Provider* dashboard = nil;
	if(dashboardInstalled) {
		dashboard = [[[Provider alloc] init] autorelease];
		[dashboard setTitle:@"Dashboard "];
		NSImage* dashboardIcon = [[NSWorkspace sharedWorkspace] iconForFileType:@"wdgt"];
		[dashboardIcon setSize:NSMakeSize(16, 16)];
		[dashboard setIcon:dashboardIcon];
		[dashboard setCanEdit:[NSNumber numberWithBool:NO]];
		[dashboard setKey:@"_Dashboard"];
	}
	
	Provider* yahoo = nil;
	if(yahooInstalled) {
		yahoo = [[[Provider alloc] init] autorelease];
		[yahoo setTitle:@"Yahoo! Widget Engine "];
		NSImage* yahooIcon = [[NSWorkspace sharedWorkspace] iconForFileType:@"widget"];
		[yahooIcon setSize:NSMakeSize(16, 16)];
		[yahoo setIcon:yahooIcon];
		[yahoo setCanEdit:[NSNumber numberWithBool:NO]];
		[yahoo setKey:@"_Yahoo"];
	}
	
	Provider* storeHeader = [[[Provider alloc] init] autorelease];
	[storeHeader setTitle:[NSString stringWithFormat:@"%@\r", NSLocalizedString(@"TitleDiscovery", @"")]];
	[storeHeader setIcon:[NSImage imageNamed:@"NoImage"]];
	[storeHeader setCanEdit:[NSNumber numberWithBool:NO]];
	[storeHeader setCanSelect:[NSNumber numberWithBool:NO]];
	[storeHeader setCanDrop:[NSNumber numberWithBool:NO]];
	[storeHeader setType:@"noop"];

	Provider* store1 = [[[Provider alloc] init] autorelease];
	[store1 setTitle:[NSString stringWithFormat:@"%@ ", NSLocalizedString(@"TitleDiscoveryStore", @"")]];
	[store1 setIcon:[NSImage imageNamed:@"IconWorld"]];
	[store1 setCanEdit:[NSNumber numberWithBool:NO]];
	[store1 setCanDrop:[NSNumber numberWithBool:NO]];
	[store1 setKey:@"_Store"];
	[store1 setType:publisherType];

	Provider* store2 = [[[Provider alloc] init] autorelease];
	[store2 setTitle:[NSString stringWithFormat:@"%@ ", NSLocalizedString(@"TitleDiscoveryFeatured", @"")]];
	[store2 setIcon:[NSImage imageNamed:@"IconStar"]];
	[store2 setCanEdit:[NSNumber numberWithBool:NO]];
	[store2 setCanDrop:[NSNumber numberWithBool:NO]];
	[store2 setKey:@"_Showcase"];
	
	Provider* store3 = [[[Provider alloc] init] autorelease];
	[store3 setTitle:@"Widgetbox"];
	[store3 setIcon:[NSImage imageNamed:@"_Widgetbox"]];
	[store3 setCanEdit:[NSNumber numberWithBool:NO]];
	[store3 setCanDrop:[NSNumber numberWithBool:NO]];
	[store3 setKey:@"_Widgetbox"];
	
	Provider* dstHeader = nil;
	
	if(facebookSupport || friendsterSupport || orkutSupport) {
		dstHeader = [[[Provider alloc] init] autorelease];
		[dstHeader setTitle:[NSString stringWithFormat:@"%@\r", NSLocalizedString(@"TitleDestination", @"")]];
		[dstHeader setIcon:[NSImage imageNamed:@"NoImage"]];
		[dstHeader setCanEdit:[NSNumber numberWithBool:NO]];
		[dstHeader setCanSelect:[NSNumber numberWithBool:NO]];
		[dstHeader setCanDrop:[NSNumber numberWithBool:NO]];
		[dstHeader setType:@"noop"];
	}
	
	Provider* facebook = nil;
	if(facebookSupport)
		facebook = [self setupProvider:@"_Facebook" withTitle:@"Facebook"];
	
	Provider* friendster = nil;
	if(friendsterSupport)
		friendster = [self setupProvider:@"_Friendster" withTitle:@"Friendster"];
	
	Provider* orkut = nil;
	if(orkutSupport)
		orkut = [self setupProvider:@"_Orkut" withTitle:@"Orkut"];
		
	Provider* myspace = nil;
	if(myspaceSupport)
		myspace = [self setupProvider:@"_MySpace" withTitle:@"MySpace"];

	Provider* hi5 = nil;
	if(hi5Support)
		hi5 = [self setupProvider:@"_Hi5" withTitle:@"hi5"];
	
	Provider* bebo = nil;
	if(beboSupport)
		bebo = [self setupProvider:@"_Bebo" withTitle:@"Bebo"];
		
	Provider* cubeHeader = [[[Provider alloc] init] autorelease];
	[cubeHeader setTitle:[NSString stringWithFormat:@"%@\r", NSLocalizedString(@"TitleCollection", @"")]];
	[cubeHeader setIcon:[NSImage imageNamed:@"NoImage"]];
	[cubeHeader setCanEdit:[NSNumber numberWithBool:NO]];
	[cubeHeader setCanSelect:[NSNumber numberWithBool:NO]];
	[cubeHeader setCanDrop:[NSNumber numberWithBool:NO]];
	[cubeHeader setType:@"noop"];

	NSArray* libraries = [NSArray arrayWithObjects:widgetsHeader, web, storeHeader, store3, store2, store1, nil];
	NSMutableArray* platforms = [NSMutableArray array];
	NSMutableArray* destinations = [NSMutableArray array];
	NSMutableArray* cubes = [NSMutableArray array];
	
	if(platformHeader) {
		[platforms addObject:platformHeader];

		if(dashboard)
			[platforms addObject:dashboard];
		if(yahoo)
			[platforms addObject:yahoo];
	}
		
	if(dstHeader) {
		[destinations addObject:dstHeader];
		
		if(myspace)
			[destinations addObject:myspace];
		if(facebook)
			[destinations addObject:facebook];
		if(bebo)
			[destinations addObject:bebo];
		if(hi5)
			[destinations addObject:hi5];
		if(friendster)
			[destinations addObject:friendster];
		if(orkut)
			[destinations addObject:orkut];
	}
	
	[cubes addObject:cubeHeader];		

	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	if([fm fileExistsAtPath:libraryDirectory]) {
		NSArray* prefs = [fm directoryContentsAtPath:libraryDirectory];
		NSEnumerator* enumerator = [prefs objectEnumerator];
		NSString* directory;
			
		while((directory = [enumerator nextObject])) {
			if([directory hasSuffix:@".cube"] && [directory isEqualToString:@"_Desktop.cube"] == NO) {
				Provider* cube = [[[Provider alloc] init] autorelease];
				
				NSString* key = [directory substringToIndex:[directory length] - 5];
				if([key hasPrefix:@"_"]) {
					NSMutableString* title = [[key substringFromIndex:1] mutableCopy];
					if([title isEqualToString:@"Cube1"] || [title isEqualToString:@"Cube2"] || [title isEqualToString:@"Cube3"])
						[title replaceOccurrencesOfString:@"Cube" withString:@"Cube " options:0 range:NSMakeRange(0, [title length])];
					
					if([title isEqualToString:@"Preloaded"])
						[cube setTitle:NSLocalizedString(@"TitleCollectionPreloaded", @"")];
					else
						[cube setTitle:title];
				}
				else if([key hasSuffix:@"]"]) {
					NSRange unique = [key rangeOfString:@"["];
					NSString* title = [key substringToIndex:unique.location];
					[cube setTitle:title];
				}
				else
					[cube setTitle:key];
				
				[cube setKey:key];
				
				[cubes addObject:cube];
			}
		}
	}

	
	NSString* widgetPath = [NSString stringWithFormat:@"%@/HypercubeLibrary.plist", libraryDirectory];
	if([fm fileExistsAtPath:widgetPath] == NO) {
		Provider* cube = [[[Provider alloc] init] autorelease];
		[cube setTitle:NSLocalizedString(@"TitleCollectionPreloaded", @"")];
		[cube setKey:@"_Preloaded"];
		[cubes addObject:cube];
	}

	int count = [libraries count] + [platforms count] + [destinations count] + [cubes count];
	NSMutableArray* newProviders = [[NSMutableArray alloc] initWithCapacity:count];
	[newProviders addObjectsFromArray:libraries];
	[newProviders addObjectsFromArray:platforms];
	[newProviders addObjectsFromArray:destinations];
	[newProviders addObjectsFromArray:cubes];
	
	floor = count - [cubes count];

	return newProviders;
}

- (void)openProvider:(NSString*)urlString
{
	[providerURLString release];
	providerURLString = [urlString retain];
	
	[self openBrowser:urlString];
}

- (NSString*)providerURLString
{
	return providerURLString;
}

- (void)openBrowser:(NSString*)urlString
{
	[self openBrowser:urlString destination:nil];
}

- (void)openBrowser:(NSString*)urlString destination:(NSString*)destination
{
	[destinationLinkKey release];
	destinationLinkKey = nil;

	if(destination)
		destinationLinkKey = [destination retain];
	
	if([webView isHidden]) {
		[counter setHidden:YES];
		[infoToggle setEnabled:NO];

		[webView setHostWindow:[self window]];
		[webView setHidden:NO];
		
		[mainViewBrowser setFrameSize:[mainViewPanel frame].size];
		[mainViewPanel replaceSubview:mainViewContainer with:mainViewBrowser];
	}
	
	if(urlString) {
		if(browserURLString && [browserURLString isEqualToString:urlString]) {
			return;
		}
		
		[browserURLString release];
		browserURLString = [urlString retain];
		
		[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	}
	else {
		[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:browserURLString]]];
	}
}

- (void)closeBrowser
{
	if([webView isHidden] == NO) {
		[counter setHidden:NO];
		[infoToggle setEnabled:YES];
		
		[webView setHidden:YES];
		[webView setHostWindow:nil];
		
		[mainViewContainer setFrameSize:[mainViewPanel frame].size];	
		[mainViewPanel replaceSubview:mainViewBrowser with:mainViewContainer];
	}
}

- (void)switchInfo:(NSString*)infoKey
{
	if(providerInfoKey && [providerInfoKey isEqualToString:infoKey])
		return;

	[providerInfoKey release];
	providerInfoKey = [infoKey retain];
	
	NSView* oldView = [[mainViewContainerBottom subviews] objectAtIndex:0];
	NSView* newView = mainViewData;
	
	if([providerInfoKey isEqualToString:@"_Dashboard"])
		newView = mainViewDashboardData;
	else if([providerInfoKey isEqualToString:@"_Yahoo"])
		newView = mainViewYahooData;
	else if([providerInfoKey isEqualToString:@"_Store"])
		newView = mainViewStoreData;
		
	if([oldView isEqualTo:newView] == NO) {
		[newView setFrameSize:[mainViewContainerBottom frame].size];	
		[mainViewContainerBottom replaceSubview:oldView with:newView];
	}
}

- (void)updateHelp:(id)sender
{
	id defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];		
	BOOL showHelp = [[defaults valueForKey:@"ShowHelpBalloons"] boolValue];
	
	if(showHelp) {
		if(helpWindow == nil) {
			NSPoint buttonPoint = NSMakePoint(0.0, [[self window] frame].size.height - 150.0);
			helpWindow = [[MAAttachedWindow alloc] initWithView:helpView
												attachedToPoint:buttonPoint 
													   inWindow:[self window] 
														 onSide:MAPositionLeft
													 atDistance:8.0];
			
			[(MAAttachedWindow*)helpWindow setBackgroundColor:[NSColor blackColor]];
			
			[[self window] addChildWindow:helpWindow ordered:NSWindowAbove];
		}
		else if([helpWindow parentWindow] == nil) {
			[(MAAttachedWindow*)helpWindow updateGeometry];
			[[self window] addChildWindow:helpWindow ordered:NSWindowAbove];
		}
	}
	else {
		if(helpWindow) {
			[[self window] removeChildWindow:helpWindow];
			[helpWindow orderOut:self];
		}
	}

	NSString* provider = [providerTitle stringValue];

	if([provider isEqualToString:@"_Web"])
		[help setStringValue:NSLocalizedString(@"WebHelp", @"")];
	else if([provider isEqualToString:@"_Store"])
		[help setStringValue:NSLocalizedString(@"StoreHelp", @"")];
	else if([provider isEqualToString:@"_Showcase"])
		[help setStringValue:NSLocalizedString(@"ShowcaseHelp", @"")];
	else if([provider isEqualToString:@"_Widgetbox"])
		[help setStringValue:[NSString stringWithFormat:NSLocalizedString(@"PartnerHelp", @""), @"Widgetbox", @"Widgetbox"]];
	else if([provider isEqualToString:@"_Dashboard"])
		[help setStringValue:NSLocalizedString(@"DashboardHelp", @"")];
	else if([provider isEqualToString:@"_Yahoo"])
		[help setStringValue:NSLocalizedString(@"YahooHelp", @"")];
	else if(
		[provider isEqualToString:@"_Facebook"] ||
		[provider isEqualToString:@"_Friendster"] ||
		[provider isEqualToString:@"_Orkut"] ||
		[provider isEqualToString:@"_MySpace"] ||
		[provider isEqualToString:@"_Hi5"] ||
		[provider isEqualToString:@"_Bebo"]
	) {
		NSString* destination = [provider substringFromIndex:1];
		NSString* formatted = [NSString stringWithFormat:NSLocalizedString(@"DestinationHelp", @""), destination, destination];
		[help setStringValue:formatted];
	}
	else
		[help setStringValue:NSLocalizedString(@"CollectionHelp", @"")];
}

- (void)openStore
{
	if(saveColumn == nil) {
		AMRemovableColumnsTableView* tv = (AMRemovableColumnsTableView*)[(WidgetArrayController*)widgetsArrayController tableView];
		saveColumn = [[tv tableColumnWithIdentifier:@"providerColumn"] retain];
		saveColumnIndex = [tv columnWithIdentifier:@"providerColumn"];
		[tv hideTableColumn:saveColumn];
	}
}

- (void)closeStore
{
	if(saveColumn) {
		AMRemovableColumnsTableView* tv = (AMRemovableColumnsTableView*)[(WidgetArrayController*)widgetsArrayController tableView];
		[tv showTableColumn:saveColumn];
		int index = [tv columnWithIdentifier:@"providerColumn"];
		[tv moveColumn:index toColumn:saveColumnIndex];
		
		[saveColumn release];
		saveColumn = nil;
	}
}

- (NSMutableArray*)providers
{
    return providers;
}

- (void)setProviders:(NSArray*)newProviders
{
	if (providers != newProviders) {
		[providers autorelease];
		providers = [[NSMutableArray alloc] initWithArray:newProviders];
	}
}

- (Provider*)providerWithKey:(NSString*)key
{
	NSEnumerator* enumerator = [providers objectEnumerator];

	Provider* item;
	while(item = [enumerator nextObject]) {
		if([key isEqualToString:[item key]])
			return item;
	}
	
	return nil;
}

- (void)renameProvider:(id)sender
{
	int providerIndex = [providersArrayController selectionIndex];
	if(providerIndex != NSNotFound) {
		Provider* provider = [[providersArrayController arrangedObjects] objectAtIndex:providerIndex];
		
		NSString* oldPath = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube/%@.cube", NSHomeDirectory(), [provider key]];
		NSString* key = [NSString stringWithFormat:@"%@[%qx]", [provider title], (unsigned long long)[NSDate timeIntervalSinceReferenceDate]];
		[provider setKey:key];
		NSString* newPath = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube/%@.cube", NSHomeDirectory(), key];
		
		NSFileManager* fm = [NSFileManager defaultManager];
		[fm movePath:oldPath toPath:newPath handler:nil];
	}
}

- (void)deleteProvider:(id)sender
{
	int providerIndex = [providersArrayController selectionIndex];
	if(providerIndex != NSNotFound) {
		Provider* provider = [[providersArrayController arrangedObjects] objectAtIndex:providerIndex];
		
		NSString* path = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube/%@.cube", NSHomeDirectory(), [provider key]];
		NSFileManager* fm = [NSFileManager defaultManager];
		[fm removeFileAtPath:path handler:nil];
	}

	[(ProviderArrayController*)providersArrayController userDelete:sender];
}

- (void)deleteWidget:(id)sender
{
	[(WidgetArrayController*)widgetsArrayController userDelete:sender];
}

- (void)deleteWidgetFromLibrary:(id)sender
{
	Widget* widget = (Widget*)sender;
	NSString* widgetID = [widget identifier];
	NSString* widgetType = NSLocalizedString(@"Widgets", @"");

	NSEnumerator* enumerator = [providers reverseObjectEnumerator];

	Provider* item;
	while(item = [enumerator nextObject]) {
		NSString* type = [item type];
		
		if([type isEqualToString:widgetType])
			[[item widgets] removeObject:sender];
	}
	
	[[manager library] removeObjectForKey:widgetID];

	NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:widgetID host:nil];
	if(proxy)
		[proxy handleClose:nil];
}

- (IBAction)findWidget:(id)sender
{
	[[self window] makeFirstResponder:search];
}

- (IBAction)toggleContainerBottom:(id)sender
{
	/*RBSplitSubview* leading = (RBSplitSubview*)mainViewContainerBottom;
	
	if ([leading isCollapsed])
		[leading expandWithAnimation:YES withResize:YES];
	else
		[leading collapseWithAnimation:YES withResize:YES];
	
	[leading setNeedsDisplay:YES];*/

	[mainViewContainerBottom setHidden:![mainViewContainerBottom isHidden]];
}

- (IBAction)homeBrowser:(id)sender
{
	NSString* provider = [providerTitle stringValue];

	if([provider isEqualToString:@"_Showcase"]) {
		[browserURLString release];
		browserURLString = nil;
		
		[self openBrowser:@"http://www.amnestywidgets.com/hypercube/machost/fidget.php"];
		return;
	}
	else if([provider isEqualToString:@"_Widgetbox"]) {
		[browserURLString release];
		browserURLString = nil;
		
		[self openBrowser:@"http://www.widgetbox.com/cgallery/hypercube/home"];
		return;
	}

	[providerURLString release];
	providerURLString = nil;
		
	[[self window] makeFirstResponder:[(WidgetArrayController*)widgetsArrayController tableView]];
	
	[self closeBrowser];
	
}

- (IBAction)handleUpdate:(id)sender
{
	if(session == nil) {
		NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.amnestywidgets.com/updates/hypercube.xml"]
												 cachePolicy:NSURLRequestReloadIgnoringCacheData
											 timeoutInterval:60.0];
		
		session = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		if(session) 
			sessionData = nil;
		else {
			NSBeep();
		}
	}
}

- (IBAction)handleContact:(id)sender
{
	NSURL* target = [NSURL URLWithString:@"mailto:support@mesadynamics.com?subject=Hypercube%20OS%20X"];
	[[NSWorkspace sharedWorkspace] openURL:target];
}

- (IBAction)handleLicense:(id)sender
{
	NSURL* target = [NSURL URLWithString:@"http://www.amnestywidgets.com/doc/hypercube_license.htm"];
	[[NSWorkspace sharedWorkspace] openURL:target];
}

- (IBAction)handleCredits:(id)sender
{
	NSURL* target = [NSURL URLWithString:@"http://www.amnestywidgets.com/doc/hypercube_credits.htm"];
	[[NSWorkspace sharedWorkspace] openURL:target];
}

- (IBAction)handleNotes:(id)sender
{
	NSURL* target = [NSURL URLWithString:@"http://www.amnestywidgets.com/doc/hypercube_releasenotes.htm"];
	[[NSWorkspace sharedWorkspace] openURL:target];
}

- (IBAction)handleHelp:(id)sender
{
	[self performSelectorOnMainThread:@selector(updateHelp:) withObject:self waitUntilDone:NO];
}

- (IBAction)showContainerBottom:(id)sender
{
	if([mainViewContainerBottom isHidden])
		[mainViewContainerBottom setHidden:NO];
}

- (IBAction)handleCreateOpen:(id)sender
{
	if(creating == NO) {
		creating = YES;
		
		[create makeFirstResponder:createName];

		[NSApp beginSheet:create
			modalForWindow:[self window]
			modalDelegate:nil
			didEndSelector:nil 
			contextInfo:nil];
			
		[NSApp runModalForWindow:create];
		
		[NSApp endSheet:create];
		[create orderOut:self];

		[createName setStringValue:@""];
		[createCode setStringValue:@""];

		creating = NO;
	}
}

- (IBAction)handleCreateURL:(id)sender
{
}

- (IBAction)handleCreateClose:(id)sender
{
	if(creating == NO)
		return;
	
	if([sender tag] == 0) {
		if([[createName stringValue] length] == 0) {
			[create makeFirstResponder:createName];
			NSBeep();
			return;
		}
		
		if([[createCode stringValue] length] == 0) {
			[create makeFirstResponder:createCode];
			NSBeep();
			return;
		}

		[providersArrayController setSelectionIndex:1];
		[[self window] makeFirstResponder:[(WidgetArrayController*)widgetsArrayController tableView]];
		
		NSString* title = [NSString stringWithString:[createName stringValue]];
		NSString* code = [NSString stringWithString:[createCode stringValue]];
		NSString* provider = [manager providerForCode:code];

		[NSApp stopModal];

		NSString* trimmedCode = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSMutableString* cleanedCode = [trimmedCode mutableCopy];
		[cleanedCode replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [cleanedCode length])];

		NSString* identifier = [WidgetManager identifierFromCode:cleanedCode];

		Widget* widget = [[manager library] objectForKey:identifier];
		if(widget == nil) {
			widget = [[[Widget alloc] init] autorelease];
			[widget setTitle:title];
			[widget setCode:cleanedCode];
			[widget setIdentifier:identifier];

			if(provider)
				[widget setProvider:provider];
			
			[[manager library] setObject:widget forKey:identifier];
			[widgetsArrayController addObject:widget];
		}
		else
			[widgetsArrayController setSelectedObjects:[NSArray arrayWithObject:widget]];
			
		NSTableView* widgetTable = (NSTableView*)[(WidgetArrayController*)widgetsArrayController tableView];
		[widgetTable scrollRowToVisible:[widgetTable selectedRow]];
		
		[(WidgetArrayController*) widgetsArrayController toggleWidget:self];
	}
	else
		[NSApp stopModal];
}

- (IBAction)handleUnlink:(id)sender
{
	NSString* destination = [[providerTitle stringValue] substringFromIndex:1];

	NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedString(@"UnlinkTitle", @"")
									 defaultButton:NSLocalizedString(@"UnlinkOK", @"")
								   alternateButton:NSLocalizedString(@"UnlinkCancel", @"")
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"UnlinkMessage", @""), destination];
	
	if([alert runModal] == 0)
		return;

	NSString* userKey = [NSString stringWithFormat:@"%@User", destination];	
	NSString* cubeKey = [NSString stringWithFormat:@"%@Cube", destination];
	
	id defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];
	[defaults setValue:@"" forKey:userKey];
	[defaults setValue:@"" forKey:cubeKey];
}

- (IBAction)platformRefresh:(id)sender
{
	NSString* provider = [providerTitle stringValue];
	
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	NSString* tagDirectory = [NSString stringWithFormat:@"%@/_Tags", libraryDirectory];

	if([provider isEqualToString:@"_Dashboard"]) {
		Provider* dashboard = [self providerWithKey:@"_Dashboard"];
		if(dashboard) {
			[manager exportTags:tagDirectory name:@"_Dashboard" array:[dashboard widgets]];
			
			[manager importFromDashboard];
			[dashboard setWidgets:[[manager dashboardLibrary] allValues]];
		}
	}
	else if([provider isEqualToString:@"_Yahoo"]) {
		Provider* yahoo = [self providerWithKey:@"_Yahoo"];
		if(yahoo) {
			[manager exportTags:tagDirectory name:@"_Yahoo" array:[yahoo widgets]];
			
			[manager importFromYahoo];
			[yahoo setWidgets:[[manager yahooLibrary] allValues]];
		}
	}
}

- (IBAction)platformReveal:(id)sender
{
	NSString* provider = [providerTitle stringValue];

	if([provider isEqualToString:@"_Dashboard"]) {
		NSString* userLibrary = [NSString stringWithFormat:@"%@/Library/Widgets", NSHomeDirectory()];
		[[NSWorkspace sharedWorkspace] selectFile:userLibrary inFileViewerRootedAtPath:@""];
	}
	else if([provider isEqualToString:@"_Yahoo"]) {
		NSString* userLibrary = [NSString stringWithFormat:@"%@/Documents/Widgets", NSHomeDirectory()];
		[[NSWorkspace sharedWorkspace] selectFile:userLibrary inFileViewerRootedAtPath:@""];
	}
}

- (IBAction)platformMoreWidgets:(id)sender
{
	NSString* provider = [providerTitle stringValue];

	NSString* url = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/deskhost/more%@.php", provider];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (IBAction)destOpen:(id)sender
{
	NSString* provider = [providerTitle stringValue];

	NSString* url = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/deskhost/open%@.php", provider];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

// NSApplication delgate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSThread detachNewThreadSelector:@selector(setup:) toTarget:self withObject:nil];
	
	NSConnection* serverConnection = [NSConnection defaultConnection];
	[serverConnection setRootObject:manager];
	[serverConnection registerName:@"HypercubeServer"];

	BOOL newLibrary = NO;
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	NSFileManager* fm = [NSFileManager defaultManager];
	if([fm fileExistsAtPath:libraryDirectory] == NO) {
		[fm createDirectoryAtPath:libraryDirectory attributes:nil];
		newLibrary = YES;
	}
	
	NSString* providerPath = [NSString stringWithFormat:@"%@/Providers.plist", [[NSBundle mainBundle] resourcePath]];
	[manager importProvidersFromPath:providerPath];
	Provider* store = [self providerWithKey:@"_Store"];
	[store setWidgets:[manager visibleProviders]];
	
	BOOL upgradeFromAlpha = NO;
	
	NSString* widgetPath = [NSString stringWithFormat:@"%@/HypercubeLibrary.plist", libraryDirectory];
	if([fm fileExistsAtPath:widgetPath])
		[manager import:widgetPath passBack:nil releaseLibrary:YES];
	else {
		BOOL loadSampleWidgets = YES;
		
		if(newLibrary == NO) {
			widgetPath = [NSString stringWithFormat:@"%@/WidgetLibrary.plist", libraryDirectory];
			if([fm fileExistsAtPath:widgetPath]) {
				[manager importFromAlpha:widgetPath];
				
				if([[manager library] count]) {
					upgradeFromAlpha = YES;
				}	
			}	
		}
		
		if(loadSampleWidgets) {
			NSMutableArray* samples = [[NSMutableArray alloc] init];
			NSString* samplePath = [NSString stringWithFormat:@"%@/HypercubeLibrary.plist", [[NSBundle mainBundle] resourcePath]];
			[manager import:samplePath passBack:samples releaseLibrary:NO];

			Provider* preloaded = [self providerWithKey:@"_Preloaded"];
			[preloaded setWidgets:samples];
		}
	}
		
	Provider* web = [self providerWithKey:@"_Web"];
	[web setWidgets:[[manager library] allValues]];

	Provider* dashboard = [self providerWithKey:@"_Dashboard"];
	if(dashboard) {
		[manager importFromDashboard];
		[dashboard setWidgets:[[manager dashboardLibrary] allValues]];
	}
		
	Provider* yahoo = [self providerWithKey:@"_Yahoo"];
	if(yahoo) {
		[manager importFromYahoo];
		[yahoo setWidgets:[[manager yahooLibrary] allValues]];
	}

	Provider* facebook = [self providerWithKey:@"_Facebook"];
	if(facebook)
		[manager importFromDestinationProvider:facebook];

	Provider* friendster = [self providerWithKey:@"_Friendster"];
	if(friendster)
		[manager importFromDestinationProvider:friendster];

	Provider* orkut = [self providerWithKey:@"_Orkut"];
	if(orkut)
		[manager importFromDestinationProvider:orkut];

	Provider* myspace = [self providerWithKey:@"_MySpace"];
	if(myspace)
		[manager importFromDestinationProvider:myspace];
	
	Provider* hi5 = [self providerWithKey:@"_Hi5"];
	if(hi5)
		[manager importFromDestinationProvider:hi5];
	
	Provider* bebo = [self providerWithKey:@"_Bebo"];
	if(bebo)
		[manager importFromDestinationProvider:bebo];
	
	NSEnumerator* enumerator = [providers reverseObjectEnumerator];

	Provider* item;
	while(item = [enumerator nextObject]) {
		if([[item type] isEqualToString:@"noop"])
			break;
		
		if(upgradeFromAlpha) {
			NSArray* widgets = [manager importFromCube:[item key]];
			
			if(widgets)	
				[item setWidgets:widgets];
		}
		else {
			NSArray* widgets = [manager importCollection:[item key]];
						
			if(widgets)	
				[item setWidgets:widgets];
		}
	}
		
	selections = [[NSMutableDictionary alloc] init];
	id providerTable = [(ProviderArrayController*)providersArrayController tableView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewSelectionIsChanging:) name:NSTableViewSelectionIsChangingNotification object:providerTable];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewSelectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:providerTable];

	[(ProviderArrayController*)providersArrayController setFloor:floor];
	
	extern BOOL gUndoIsActive;
	gUndoIsActive = YES;

	pasteTimer = [NSTimer
		scheduledTimerWithTimeInterval:(double) 0.25
		target:self
		selector:@selector(handleIdle:)
		userInfo:nil
		repeats:YES];

	id defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];			
	if([[defaults valueForKey:@"LaunchRememberWidgets"] boolValue]) {
		NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
		
		NSMutableArray* openClients = [ud objectForKey:@"OpenWidgets"];
		if(openClients && [openClients count]) {
			NSEnumerator* enumerator = [openClients objectEnumerator];
			NSString* widgetID;
			while(widgetID = [enumerator nextObject]) {
				Widget* widget = [manager widgetWithIdentifier:widgetID];
				if(widget) {
					NSString* code = [widget code];
					[manager launchWidgetWithCode:code];
				}
			}
		}
	}
	
	if(upgradeFromAlpha) {
		NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedString(@"AlphaTitle", @"")
										 defaultButton:NSLocalizedString(@"OK", @"")
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"AlphaMessage", @""), destinationLinkKey];
		
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
	}

	[self updateHelp:self];
	
	if(newLibrary) {
		[NSApp activateIgnoringOtherApps:YES];
		[[self window] makeKeyAndOrderFront:self];
	}
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[manager closeAll:self];
	
	NSMutableArray* openClients = [manager openClients];
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	if(openClients && [openClients count])
		[ud setObject:openClients forKey:@"OpenWidgets"];
	else
		[ud removeObjectForKey:@"OpenWidgets"];

	[[self window] orderOut:self];
	[self closeStore];

	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	if([fm fileExistsAtPath:libraryDirectory] == NO) {
		[fm createDirectoryAtPath:libraryDirectory attributes:nil];
	}
	
	NSString* widgetPath = [NSString stringWithFormat:@"%@/HypercubeLibrary.plist", libraryDirectory];
	[manager export:widgetPath];

	NSString* tagDirectory = [NSString stringWithFormat:@"%@/_Tags", libraryDirectory];
	if([fm fileExistsAtPath:tagDirectory] == NO) {
		[fm createDirectoryAtPath:tagDirectory attributes:nil];
	}

	NSEnumerator* enumerator = [providers objectEnumerator];
	Provider* provider;
	
	while(provider = [enumerator nextObject]) {
		NSString* key = [provider key];
		
		if([[provider canEdit] boolValue] == YES) {
			if([key length] == 0)
				key = [NSString stringWithFormat:@"%@[%qx]", [provider title], (unsigned long long)[NSDate timeIntervalSinceReferenceDate]];
			
			[manager exportCollection:key array:[provider widgets]];
		}	
		else if(
			[key isEqualToString:@"_Dashboard"] ||
			[key isEqualToString:@"_Yahoo"] ||
			[key isEqualToString:@"_Facebook"] ||
			[key isEqualToString:@"_Friendster"] ||
			[key isEqualToString:@"_Orkut"] ||
			[key isEqualToString:@"_MySpace"] ||
			[key isEqualToString:@"_Hi5"] ||
			[key isEqualToString:@"_Bebo"]
		)
			[manager exportTags:tagDirectory name:key array:[provider widgets]];
	}
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	if([[self window] isVisible] == NO) {
		id defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];			

		if(launching) {
			launching = NO;
			
			if([[defaults valueForKey:@"LaunchDisplayMainWindow"] boolValue] == NO)
				return;
		}
		else {
			if([[defaults valueForKey:@"SwitchDisplayMainWindow"] boolValue] == NO)
				return;
		}
		
		[[self window] makeKeyAndOrderFront:self];
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
	if([[self window] isVisible]) {
		if([aMenuItem action] == @selector(toggleContainerBottom:))
			return [infoToggle isEnabled];

		if([aMenuItem action] == @selector(findWidget:))
			return YES;
	}
	else {
		if([aMenuItem action] == @selector(showWindow:))
			return YES;
 	 }
	 	
	if([aMenuItem action] == @selector(handleCreateOpen:))
   		return YES;
		
	if([aMenuItem action] == @selector(handleCreateURL:))
   		return NO;
				
	if([aMenuItem action] == @selector(destOpen:))
   		return YES;

	if([aMenuItem action] == @selector(handleUpdate:))
   		return YES;
	
	if([aMenuItem action] == @selector(handleContact:))
   		return YES;
	
	if([aMenuItem action] == @selector(handleLicense:))
   		return YES;
	
	if([aMenuItem action] == @selector(handleCredits:))
   		return YES;
	
	if([aMenuItem action] == @selector(handleNotes:))
   		return YES;
	
    return NO;
}

// NSWindow delegate
- (BOOL)windowShouldClose:(id)sender
{
	[[self window] orderOut:self];
	return NO;
}

// Notifications
- (void)tableViewSelectionIsChanging:(id)sender
{
	[search setStringValue:@""];
	[(WidgetArrayController*) widgetsArrayController setSearchString:@""];
	
	int providerIndex = [providersArrayController selectionIndex];
	if(providerIndex != NSNotFound) {
		id provider = [[providersArrayController arrangedObjects] objectAtIndex:providerIndex];
		
		NSIndexSet* selectedWidgets = [widgetsArrayController selectionIndexes];
		[selections setObject:selectedWidgets forKey:[provider description]];
	}
}

- (void)tableViewSelectionDidChange:(id)sender
{
	int providerIndex = [providersArrayController selectionIndex];
	if(providerIndex != NSNotFound) {
		id provider = [[providersArrayController arrangedObjects] objectAtIndex:providerIndex];

		NSIndexSet* selectedWidgets = [selections objectForKey:[provider description]];
		if(selectedWidgets)
			[widgetsArrayController setSelectionIndexes:selectedWidgets];
	}
	
	[self updateHelp:self];
}

// RBSplitView delegate
- (void)splitView:(RBSplitView*)sender wasResizedFrom:(float)oldDimension to:(float)newDimension
{
	if([[sender identifier] isEqualToString:@"Main"])
		[sender adjustSubviewsExcepting:(RBSplitSubview*)sourceViewPanel];
}

- (unsigned int)splitView:(RBSplitView*)sender dividerForPoint:(NSPoint)point inSubview:(RBSplitSubview*)subview
{
	if([[sender identifier] isEqualToString:@"Main"]) {
		if([dragView mouse:[dragView convertPoint:point fromView:sender] inRect:[dragView bounds]])
			return 0;
	}

	return NSNotFound;
}

- (NSRect)splitView:(RBSplitView*)sender cursorRect:(NSRect)rect forDivider:(unsigned int)divider
{
	if([[sender identifier] isEqualToString:@"Main"])
		[sender addCursorRect:[dragView convertRect:[dragView bounds] toView:sender] cursor:[RBSplitView cursor:RBSVVerticalCursor]];

	return rect;
}

//- (void)webView:(WebView *)sender didReceiveIcon:(NSImage *)image forFrame:(WebFrame *)frame
//{
//	NSLog(@"%@ for frame %@", image, frame);
//}

// WebPolicy delegate
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
	NSURL* url = [request URL];
	NSString* urlString = [url absoluteString];
	
	if([urlString hasPrefix:@"code:"]) {
		NSString* codeTitle = [urlString substringFromIndex:5];
		
		WebFrame* frame = [webView mainFrame];
		[self findCodeInFrame:frame title:codeTitle];
	}
	
	[listener use];
}

- (BOOL)findCodeInFrame:(WebFrame*)frame title:(NSString*)title
{
	WebDataSource* dataSource = [frame dataSource];
	NSData* data = [dataSource data];

	if(data) {
		NSString* dataString = [[[NSString alloc] initWithData:[dataSource data] encoding:NSUTF8StringEncoding] autorelease];
		NSString* marker = [NSString stringWithFormat:@"<code name=\"%@\" style=\"display:none\">", title];
		NSRange start = [dataString rangeOfString:marker];
		if(start.location != NSNotFound) {
			NSRange stop = [dataString rangeOfString:@"</code>"];
			if(stop.location != NSNotFound && stop.location > start.location) {
				start.location += [marker length];
				start.length = stop.location - start.location;
				
				NSString* pasteString = [dataString substringWithRange:start];
				if(pasteString) {
					NSString* trimmedCode = [pasteString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					NSMutableString* cleanedCode = [trimmedCode mutableCopy];
					[cleanedCode replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0, [cleanedCode length])];
					[cleanedCode replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0, [cleanedCode length])];
			
					if([title length] == 0) {
						NSString* provider = [manager providerForCode:cleanedCode];
						if(provider == nil)
							[createName setStringValue:NSLocalizedString(@"UntitledWidget", @"")];
						else
							[createName setStringValue:[NSString stringWithFormat:@"%@ Widget", provider]];
					}
					else
						[createName setStringValue:[title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
						
					[createCode setStringValue:cleanedCode];
					
					[self handleCreateOpen:self];
					
					return YES;
				}
			}
		}
	}
	
	NSArray* childFrames = [frame childFrames];
	NSEnumerator* enumerator = [childFrames objectEnumerator];
	id childFrame;
	
	while(destinationLinkKey && (childFrame = [enumerator nextObject])) {
		if([self findCodeInFrame:childFrame title:title] == YES)
			break;
	}
	
	return NO;
}

// WebUI delegate
- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
	return nil;
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
	NSMutableArray* items = [NSMutableArray arrayWithCapacity:[defaultMenuItems count]];
	NSEnumerator* enumerator = [defaultMenuItems objectEnumerator];
	NSMenuItem* menu;
		
	while((menu = [enumerator nextObject])) {
		switch([menu tag]) {
			case WebMenuItemTagOpenLinkInNewWindow:
			case WebMenuItemTagDownloadLinkToDisk:
			case WebMenuItemTagOpenImageInNewWindow:
			case WebMenuItemTagDownloadImageToDisk:
			case WebMenuItemTagOpenFrameInNewWindow:
				break;
				
			default:
				[items addObject:menu];
		}
	}
			
	return items;
}

- (void)webReady:(id)sender
{
	if(destinationLinkKey) {
		WebFrame* frame = [webView mainFrame];
		[self webReadyWithFrame:frame];
	}
}

- (void)webReadyWithFrame:(WebFrame*)frame
{
	WebDataSource* dataSource = [frame dataSource];
	NSData* data = [dataSource data];
	
	if(data) {
		NSString* destinationString = [NSString stringWithFormat:@"%@.com", [destinationLinkKey lowercaseString]];
		NSString* marker = [NSString stringWithFormat:@"/hypercube/deskhost/link.php?destination=%@&", destinationString];
		NSString* dataString = [[[NSString alloc] initWithData:[dataSource data] encoding:NSUTF8StringEncoding] autorelease];	
		NSRange start = [dataString rangeOfString:marker];
		if(start.location != NSNotFound) {
			NSRange stop = [dataString rangeOfString:@"&source=Hypercube"];
			if(stop.location != NSNotFound && stop.location > start.location) {
				NSRange userStart = [dataString rangeOfString:@"&user=" options:0 range:NSMakeRange(start.location, stop.location - start.location)];
				NSRange cubeStart = [dataString rangeOfString:@"&cube=" options:0 range:NSMakeRange(start.location, stop.location - start.location)];
				
				if(userStart.location != NSNotFound && cubeStart.location != NSNotFound) {
					userStart.location += 6;
					NSString* userString = [dataString substringWithRange:NSMakeRange(userStart.location, cubeStart.location - userStart.location)];
					cubeStart.location += 6;
					NSString* cubeString = [dataString substringWithRange:NSMakeRange(cubeStart.location, stop.location - cubeStart.location)];

					NSString* userKey = [NSString stringWithFormat:@"%@User", destinationLinkKey];	
					NSString* cubeKey = [NSString stringWithFormat:@"%@Cube", destinationLinkKey];	

					id defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];
					[defaults setValue:userString forKey:userKey];
					[defaults setValue:cubeString forKey:cubeKey];

					NSString* key = [NSString stringWithFormat:@"_%@", destinationLinkKey];
					Provider* provider = [self providerWithKey:key];
					if(provider) {
						NSNumber* status = [provider status];
						if([status intValue] == ProviderStatusNeedsToLoad) {
							[provider setStatus:[NSNumber numberWithInt:ProviderStatusLoading]];
							[manager importFromDestination:key user:userString cube:cubeString];
						}
					}
					
					NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedString(@"LinkTitle", @"")
						defaultButton:NSLocalizedString(@"OK", @"")
						alternateButton:nil
						otherButton:nil
						informativeTextWithFormat:NSLocalizedString(@"LinkMessage", @""), destinationLinkKey];

					[alert setAlertStyle:NSInformationalAlertStyle];
					[alert runModal];
					
					if([[providerTitle stringValue] isEqualToString:key])
						[self closeBrowser];
				}
			}

			[destinationLinkKey release];
			destinationLinkKey = nil;
		}
	}
	
	NSArray* childFrames = [frame childFrames];
	NSEnumerator* enumerator = [childFrames objectEnumerator];
	id childFrame;
	
	while(destinationLinkKey && (childFrame = [enumerator nextObject]))
		[self webReadyWithFrame:childFrame];
}

// NSTimers
- (void)handleIdle:(id)sender
{
	NSPasteboard* pb = [NSPasteboard generalPasteboard];
	int count = [pb changeCount];
	
	if(count > pasteCount) {		
		pasteCount = count;
			
		NSArray* pasteTypes = [pb types];
		if([pasteTypes containsObject:NSStringPboardType] == NO)
			return;
		
		NSData* pasteData = [pb dataForType:NSStringPboardType];
		if(pasteData && [pasteData length]) {
			NSString* pasteString = [[NSString alloc] initWithData:pasteData encoding:NSUTF8StringEncoding];			
			if(pasteString && (pasteBuffer == nil || [pasteString isEqualToString:pasteBuffer] == NO)) {
				NSString* trimmedCode = [pasteString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
				if([NSApp isActive] && [webView isHidden] == NO && [trimmedCode hasPrefix:@"<"] && [trimmedCode hasSuffix:@">"]) {
					NSString* provider = [manager providerForCode:trimmedCode];
					if(provider == nil)
						[createName setStringValue:NSLocalizedString(@"UntitledWidget", @"")];
					else
						[createName setStringValue:[NSString stringWithFormat:@"%@ Widget", provider]];
						
					[createCode setStringValue:trimmedCode];
					
					[self handleCreateOpen:self];
					NSLog(@"found widget code");
				}
				
				[pasteBuffer release];
				pasteBuffer = pasteString;
			}
		}
	}
}

// NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[sessionData release];
	sessionData = nil;
	
	[session release];
	session = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(sessionData == nil)
		sessionData = [[NSMutableData alloc] initWithCapacity:[data length]];
	
	if(sessionData)
		[sessionData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
 	if(sessionData) {
		NSString* xml = [[NSString alloc] initWithData:[sessionData copy] encoding:NSUTF8StringEncoding];
		
		if(xml) {
			NSString* version = nil;
			NSRange start = [xml rangeOfString:@"<version>"];
			
			if(start.location != NSNotFound) {
				start.location += 9;
				NSRange end = [[xml substringFromIndex:start.location] rangeOfString:@"</version>"];
				start.length = end.location;
				
				version = [xml substringWithRange:start];
			}
			
			if(version && [version length]) {
				int saveLevel = [[self window] level];
				if(saveLevel > NSNormalWindowLevel)
					[[self window] setLevel:NSNormalWindowLevel];
				
				if([version intValue] > 50) {
					int value = NSRunAlertPanel(NSLocalizedString(@"UpdateCheck", @""), NSLocalizedString(@"UpdateYes", @""), NSLocalizedString(@"OK", @""),  nil, NSLocalizedString(@"UpdateDownload", @""));
					if(value == -1) {
						NSURL* target = [NSURL URLWithString:@"http://www.amnestywidgets.com/updates/hypercube.htm"];
						if(target)
							LSOpenCFURLRef((CFURLRef) target, NULL);
					}
				}
				else
					NSRunAlertPanel(NSLocalizedString(@"UpdateCheck", @""), NSLocalizedString(@"UpdateNo", @""), NSLocalizedString(@"OK", @""), nil, nil);
				
				if(saveLevel > NSNormalWindowLevel)
					[[self window] setLevel:saveLevel];
			}
		}
		
		[sessionData release];
		sessionData = nil;
	}
	
	[session release];
	session = nil;
}



@end
