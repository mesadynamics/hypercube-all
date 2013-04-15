//
//  WidgetController.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/7/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "WidgetController.h"
#import "WidgetManager.h"
#import "WidgetView.h"
#import "WebView+Amnesty.h"

enum {
	levelFloating = 100,
	levelStandard = 110,
	levelEmbedded = 120,
	levelOverlay = 130
};

enum {
	dragWidget = 200,
	dragControl = 210,
	dragOff = 220
};

enum {
	backgroundClear = 400,
	backgroundWhite = 410,
	backgroundBlack = 420,
	backgroundGlass = 430
};

@implementation WidgetController

- (id)init
{
	if(self = [super init]) {
		widgetCode = nil;
		domain = @"_Desktop";
		
		tracker = 0;
		
		optionLevel = levelFloating;
		optionDrag = dragWidget;
		optionBackground = backgroundClear;
		optionOpacity = 100;
		optionGoOpaque = false;
		
		isReady = NO;
		willBeVisible = YES;
		shouldHideOnReady = NO;
		didSetTitle = NO;
		
		foundOptions = NO;
		foundGlobals = NO;
		allowBrowserSpawning = NO;
		allowSleeping = YES;
		allowPausing = YES;
		allowHosting = YES;

		didPause = NO;
		
		widgetView = nil;
		widgetParentView = nil;
		
		terminateNow = NO;
		readyAfterAdjust = NO;		
		doSyndicate = YES;
		doReduceCPU = YES;
		doExport = NO;
		
		exportDashboard = NO;
		exportYahoo = NO;
		
		dc = nil;
	}
	
	return self;
}

- (void)awakeFromNib
{
	[NSApp setDelegate:self];
	
	WebFrame* mainFrame = [webView mainFrame];
	WebFrameView* mainFrameView = [mainFrame frameView];
	NSView* documentView = [mainFrameView documentView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webBoundsChanged:) name:NSViewBoundsDidChangeNotification object:documentView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webReady:) name:WebViewProgressFinishedNotification object:webView];

	[webView setHostWindow:[self window]];

	if([webView respondsToSelector:@selector(setDrawsBackground:)])
		[webView setDrawsBackground:NO];

	if([WebView respondsToSelector:@selector(_setShouldUseFontSmoothing:)])
		[WebView _setShouldUseFontSmoothing:YES];

	if([webView respondsToSelector:@selector(setProhibitsMainFrameScrolling:)])
		[webView setProhibitsMainFrameScrolling:YES];
		
	if([webView respondsToSelector:@selector(_setDashboardBehavior:to:)]) {
		[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendMouseEventsToAllWindows to:YES];
		[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysAcceptsFirstMouse to:YES];
		[webView _setDashboardBehavior:WebDashboardBehaviorAllowWheelScrolling to:YES];
		[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns to:NO];
	}
		
	[webView setGroupName:@"Unknown"];
	[webView setEditable:NO];

	[mainFrameView setAllowsScrolling:NO];

	WebPreferences* prefs = [webView preferences];
	if([prefs respondsToSelector:@selector(setCacheModel:)])
		[prefs setCacheModel:WebCacheModelPrimaryWebBrowser];
		
	NSDictionary* txtDict = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSFont systemFontOfSize:11.0], NSFontAttributeName,
							 [NSColor colorWithDeviceWhite:.80 alpha:1.0], NSForegroundColorAttributeName,
							 nil];
	
	NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:[goOpaque title] attributes:txtDict];
	[goOpaque setAttributedTitle:attrStr];
	[attrStr release];
}

- (BOOL)loadWidget:(NSString*)identifier
{
	NSString* snippet = nil;
	
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSDictionary* udEntry = [ud persistentDomainForName:@"com.amnestywidgets.HypercubeWidgets"];
	if(udEntry) {
		NSString* code = [udEntry objectForKey:identifier];
		if(code)
			snippet = [NSString stringWithString:code];
	}
	
	if(snippet == nil) {
		NSFileManager* fm = [NSFileManager defaultManager];
		NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
		if([fm fileExistsAtPath:libraryDirectory] == NO)
			return NO;

		NSString* path = [NSString stringWithFormat:@"%@/HypercubeLibrary.plist", libraryDirectory];
		if([fm fileExistsAtPath:path] == NO)
			return NO;
		
		NSPropertyListFormat format;
		NSString* error = nil;
		
		NSData* data = [NSData dataWithContentsOfFile:path];
		NSMutableDictionary* plist = (NSMutableDictionary*) [NSPropertyListSerialization propertyListFromData:data
			mutabilityOption:NSPropertyListMutableContainersAndLeaves
			format:&format
			errorDescription:&error];
			
		if(plist == nil)
			return NO;
		
		NSMutableDictionary* widget = [plist objectForKey:identifier];
		if(widget)
			snippet = [widget objectForKey:@"code"];
	}
	
	if(snippet == nil)
		return NO;
	
	[webView setGroupName:identifier];
	
	return [self loadSnippet:snippet];
}

- (BOOL)loadSnippet:(NSString*)snippet
{
	NSString* identifier = [webView groupName];
	NSString* codeIdentifier = [WidgetManager identifierFromCode:snippet];
	if([identifier isEqualToString:@"Unknown"])
		[webView setGroupName:codeIdentifier];
	else if([identifier isEqualToString:codeIdentifier] == NO)
		return NO;
	
	[self readOptions];
	
	BOOL foundSyndication = NO;

	if(doSyndicate) {
		NSRange googleCheck = [snippet rangeOfString:@"gmodules.com"];
		if(googleCheck.location != NSNotFound) {
			NSRange syndicationCheck = [snippet rangeOfString:@"synd=open"];
			if(syndicationCheck.location != NSNotFound) {
				NSMutableString* syndicationCode = [snippet mutableCopy];
				if(syndicationCode) {
					[syndicationCode replaceOccurrencesOfString:@"synd=open" withString:@"synd=amnesty" options:0 range:NSMakeRange(0, [syndicationCode length])];
					widgetCode = syndicationCode;
					foundSyndication = YES;
				}
			}
		}
	}
	
	if(foundSyndication == NO)
		widgetCode = [snippet copy];	
		
	if(foundOptions) {
		if(doExport) {
			[self ready];
			return YES;
		}
	}

	isIPhoneApp = NO;
	hasFlash = NO;
			
	if([snippet hasPrefix:@"<iphone src=\""] && [snippet hasSuffix:@"\" />"]) {
		isIPhoneApp = YES;
		[webView setPolicyDelegate:nil];

		/*NSRect frame = [webView frame];
		frame.origin.x += 20.0;
		frame.origin.y += 20.0;
		frame.size.width -= 40.0;
		frame.size.height -= 40.0;
		[webView setFrame:frame];*/
		
		if([webView respondsToSelector:@selector(setProhibitsMainFrameScrolling:)])
			[webView setProhibitsMainFrameScrolling:NO];

		WebFrame* mainFrame = [webView mainFrame];
		WebFrameView* mainFrameView = [mainFrame frameView];
		[mainFrameView setAllowsScrolling:YES];

		[webView setCustomUserAgent:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"];
	}	
	else {
		[webView setCustomUserAgent:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_2; en-us) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.1 Safari/525.18"];
	}
	
	dc = [[DownCloud alloc] initWithWebView:webView cacheName:identifier];
	
	[self handleReload:self];
	
	return YES;
}

- (BOOL)loadRequest:(NSURLRequest*)request
{
	WebFrame* mainFrame = [webView mainFrame];
	[mainFrame loadRequest:request];
	
	return YES;
}

- (void)ready
{
	if(doExport) {
		if(exportDashboard) {
			NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
			
			NSMutableString* name = [[ud stringForKey:@"widgetName"] mutableCopy];
			[name replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, [name length])];
			[name replaceOccurrencesOfString:@":" withString:@"_" options:0 range:NSMakeRange(0, [name length])];
			[name replaceOccurrencesOfString:@"/" withString:@"_" options:0 range:NSMakeRange(0, [name length])];
			[name replaceOccurrencesOfString:@"." withString:@"_" options:0 range:NSMakeRange(0, [name length])];

			NSString* identifier = [webView groupName];

			NSImage* image = nil;
			NSDictionary* udEntry = [ud persistentDomainForName:@"com.amnestywidgets.HypercubeImages"];
			if(udEntry) {
				NSData* imageData = [udEntry objectForKey:identifier];
				if(imageData)
					image = [[[NSImage alloc] initWithData:imageData] autorelease];
			}
			
			NSString* dashboardID = [NSString stringWithFormat:@"com.amnestywidgets.widget.%@.%d", name, [WidgetManager markerFromCode:identifier]];

			int width = 320;
			int height = 240;
			
			if(foundOptions) {
				width = (int) optionSize.width;
				height = (int) optionSize.height;
			}
			else {
				NSRect frame = [[self window] frame];
				width = (int) frame.size.width;
				height = (int) frame.size.height;
			}
			
			width -= 20;
			
			[WidgetManager exportToDashboard:widgetCode title:name image:image identifier:dashboardID dashboard:nil width:width height:height];
		}
		else if(exportYahoo) {
		}
		
		terminateNow = YES;
	}
}

- (void)show
{
	if(didPause == YES) {
		if(widgetView && widgetParentView) {
			[widgetParentView addSubview:widgetView];
			[widgetView release];
			[webView setHostWindow:[self window]];
			
			widgetView = nil;
			widgetParentView = nil;
		}
			
		didPause = NO;
	}
	
	[self redraw];

	if(willBeVisible)
		shouldHideOnReady = NO;
	else
		[[self window] orderFront:self];
}

- (void)hide
{
	WidgetView* content = (WidgetView*) [[self window] contentView];
	[content zeroBadge];

	if(allowPausing && didPause == NO) {
		widgetView = [[webView mainFrame] frameView];
		widgetParentView = [widgetView superview];
		
		[widgetView retain];
		[widgetView removeFromSuperviewWithoutNeedingDisplay];
		[webView setHostWindow:nil];
		
		didPause = YES;
	}
	
	if(willBeVisible)
		shouldHideOnReady = YES;
	else
		[[self window] orderOut:self];
}

- (BOOL)isReady
{
	if(willBeVisible)
		return NO;
		
	return isReady;
}

- (BOOL)isOrWillBeVisible
{
	return (willBeVisible || [[self window] isVisible]);
}

- (BOOL)adjustReady:(id)sender
{
	BOOL returnValue = [self adjustSize:sender];
	
	if(readyAfterAdjust) {
		readyAfterAdjust = NO;
		[self ready];
	}
	
	return returnValue;
}

- (BOOL)adjustSize:(id)sender
{
	BOOL didAdjust = NO;
	
	NSRect widgetFrame = [[self window] frame];
	
	NSRect smallFrame = widgetFrame;
	smallFrame.size = NSMakeSize(72.0, 72.0);
	
	WebFrame* mainFrame = [webView mainFrame];
	WebFrameView* mainFrameView = [mainFrame frameView];
	
	[mainFrameView setFrame:smallFrame];

	NSView* documentView = [mainFrameView documentView];
	
	NSSize widgetSize = [documentView frame].size;
	
	if(widgetSize.width == NSZeroSize.width && widgetSize.height == NSZeroSize.height)
		return didAdjust;
		
	if(isIPhoneApp) {
		if(widgetSize.height > 396.0)
			widgetSize.width = 336.0;
		else
			widgetSize.width = 320.0;
			
		widgetSize.height = 396.0;
	}
		
	NSPoint topLeft = widgetFrame.origin;
	topLeft.y += widgetFrame.size.height;

	widgetFrame.size = widgetSize;

	float pushX = 20.0;
	float pushY = 0.0;

	widgetFrame.size.width += pushX;
	widgetFrame.size.height += pushY;
			
	if(NSEqualSizes(widgetFrame.size, widgetSize) == NO)
	{		
		[[self window] setFrame:widgetFrame display:NO animate:NO];
		
		/*if(isIPhoneApp) {
			NSWindow* window = [self window];
			[window setBackgroundColor:[BrowserWindow backgroundImageForFrame:widgetFrame withTitle:[window title]]];
		}*/

		widgetFrame.size.width -= pushX;
		widgetFrame.size.width -= pushY;
	
		// kludge: make sure the main frame's view metrics are in sync with the document
		widgetFrame.origin.x = 0.0;
		widgetFrame.origin.y = 0.0;
		[mainFrameView setFrame:widgetFrame];
		
		int ix = (int) topLeft.x;
		int iy = (int) topLeft.y;
		if(ix == 8192 && iy == 8192)
			[[self window] center];
		else
			[[self window] setFrameTopLeftPoint:topLeft];
			
		didAdjust = YES;
	}
	
	return didAdjust;
}

- (void)checkForFlash:(BOOL)force
{
	WidgetView* content = (WidgetView*) [[self window] contentView];	
	[content setMaxRefresh:NO];
	
	hasFlash = NO;

	if(force == YES || [webView containsFlash]) {
        SInt32 macVersion = 0;
        Gestalt(gestaltSystemVersion, &macVersion);
                
		if(macVersion == 0x1049) {
			NSString* version = [[NSProcessInfo processInfo] operatingSystemVersionString];
			if([version hasPrefix:@"Version 10.4.9"] == NO) {
				[content setRefreshRect:[webView frame]];
				[content setMaxRefresh:YES];
			}	
		}
		
		hasFlash = YES;
	}
}

- (IBAction)handleHide:(id)sender
{
	NSArray* children = [[self window] childWindows];
	NSEnumerator* enumerator = [children objectEnumerator];
	NSWindow* anObject;
	
	while((anObject = [enumerator nextObject]))
		[anObject close];
	
	[self hide];

	if(doExport == NO) {
		NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"HypercubeServer" host:nil];
		if(proxy) {
			NSString* identifier = [webView groupName];
			[proxy widgetIsHiding:identifier];
		}
	}
}

- (IBAction)handleShow:(id)sender
{
	[self show];

	if(doExport == NO) {
		NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"HypercubeServer" host:nil];
		if(proxy) {
			NSString* identifier = [webView groupName];
			[proxy widgetIsShowing:identifier];
		}
	}
}

- (IBAction)handleClose:(id)sender
{
	[self hide];
	
	terminateNow = YES;
}

- (IBAction)handleReload:(id)sender
{
	if(isIPhoneApp) {
		NSString* urlString = [widgetCode substringWithRange:NSMakeRange(13, [widgetCode length] - 17)];

		NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
			cachePolicy:NSURLRequestUseProtocolCachePolicy
			timeoutInterval:20.0];
		
		[self loadRequest:request];
		return;
	}
	
	BOOL hostRemotely = (allowHosting ? NO : YES);
		
	if(hostRemotely) {
		NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.amnestywidgets.com/hypercube/machost/widget.php"]
			cachePolicy:NSURLRequestReloadIgnoringCacheData
			timeoutInterval:20.0];
			
		NSString* identifier = [webView groupName];
					
		CFStringRef code = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) widgetCode, CFSTR(""), CFSTR("&\"="), kCFStringEncodingUTF8);
		if(code) {	
			NSString* postData = [NSString stringWithFormat:@"id=%@&version=%d&code=%@",
				identifier,
				[WidgetManager markerFromCode:identifier],
				(NSString*) code
			];

			[request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
			[request addValue:[NSString stringWithFormat:@"%d", (unsigned int)[postData length]] forHTTPHeaderField:@"Content-Length"];
			[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];
			[request setHTTPMethod:@"POST"];
				
			[self loadRequest:request];
			
			CFRelease(code);
			return;
		}
		else
			hostRemotely = NO;
	}
	
	if(hostRemotely == NO) {
		NSString* path = [NSString stringWithFormat:@"%@/Widget.html", [[NSBundle mainBundle] resourcePath]];
		NSString* form = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

		NSMutableString* htmlPage = [form mutableCopy];
		[htmlPage replaceOccurrencesOfString:@"^snippet" withString:widgetCode options:0 range:NSMakeRange(0, [htmlPage length])];

		NSURL* baseURL = [NSURL fileURLWithPath:path];

		WebFrame* mainFrame = [webView mainFrame];
		NSData* htmlData = [htmlPage dataUsingEncoding:NSUTF8StringEncoding];
		if(htmlData)
			[mainFrame loadData:htmlData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:baseURL];
		else
			[mainFrame loadHTMLString:htmlPage baseURL:baseURL];
								
		[htmlPage release];
	}
}

- (IBAction)handleRedraw:(id)sender
{
	[self adjustSize:self];
	[self redraw];
}

- (IBAction)handleOpenConfigure:(id)sender
{
	[level selectItemWithTag:optionLevel];
	[drag selectItemWithTag:optionDrag];
	[background selectItemWithTag:optionBackground];
	[opacity setIntValue:optionOpacity];
	[goOpaque setIntValue:optionGoOpaque];

	if(optionOpacity == 100) {
		if([goOpaque isEnabled])
			[goOpaque setEnabled:NO];
	}
	else if([goOpaque isEnabled] == NO)
		[goOpaque setEnabled:YES];
	
	[NSApp beginSheet:configure modalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
		
	[NSApp runModalForWindow:configure];
	
	[NSApp endSheet:configure];
	[configure orderOut:self];
}

- (IBAction)handleCloseConfigure:(id)sender
{
	[NSApp stopModal];

	[self setOptionLevel:[[level selectedItem] tag]];
	[self setOptionDrag:[[drag selectedItem] tag]];
	[self setOptionBackground:[[background selectedItem] tag]];

	int opacityValue = [opacity intValue];
	optionOpacity = 0;
	[self setOptionOpacity:opacityValue];

	optionGoOpaque = [goOpaque intValue];

	if(optionOpacity != 100 && optionGoOpaque)
		[[self window] setAlphaValue:1.0];

	[self writeOptions];
}

- (IBAction)handleOpacity:(id)sender
{
	NSSlider* slider = (NSSlider*)sender;
	int opacityValue = [slider intValue];
	[self setOptionOpacity:opacityValue];
	
	if(opacityValue == 100) {
		if([goOpaque isEnabled])
			[goOpaque setEnabled:NO];
	}
	else if([goOpaque isEnabled] == NO)
		[goOpaque setEnabled:YES];
}

- (void)setOptionLevel:(int)value
{
	if(optionLevel != value) {
		optionLevel = value;
		
		if(isInGallery) {
			[[self window] setLevel:NSPopUpMenuWindowLevel - 2];				
			
			return;
		}
		
		if(isInHypercube) {
			[[self window] setLevel:NSPopUpMenuWindowLevel - 4];
			
			return;
		}
		
		switch(optionLevel) {
			case levelOverlay:
				[[self window] setLevel:NSPopUpMenuWindowLevel];
			break;
			
			case levelFloating:
				[[self window] setLevel:NSFloatingWindowLevel];
				break;
			
			case levelStandard:
				[[self window] setLevel:NSNormalWindowLevel];
			break;
			
			case levelEmbedded:
				[[self window] setLevel:kCGDesktopIconWindowLevel-1];
			break;
		}
	}
}

- (void)setOptionDrag:(int)value
{
	if(optionDrag != value) {
		optionDrag = value;
		
		switch(optionDrag) {
			case dragWidget:
				[[self window] setMovableByWindowBackground:YES];
				[[self window] setAcceptsMouseMovedEvents:YES];
			break;
				
			case dragControl:
				[[self window] setMovableByWindowBackground:NO];
				[[self window] setAcceptsMouseMovedEvents:YES];
			break;
				
			case dragOff:
				[[self window] setMovableByWindowBackground:NO];
				[[self window] setAcceptsMouseMovedEvents:NO];
			break;
		}
	}
}

- (void)setOptionBackground:(int)value
{
	if(optionBackground != value) {
		optionBackground = value;
		
		WidgetView* content = (WidgetView*) [[self window] contentView];
	
		switch(value) {
			case backgroundClear:
				[content setFillColor:nil];
				break;
				
			case backgroundWhite:
				[content setFillColor:[NSColor whiteColor]];
				break;
				
			case backgroundBlack:
				[content setFillColor:[NSColor blackColor]];
				break;
				
			case backgroundGlass:
				[content setFillColor:[NSColor colorWithCalibratedWhite:0.0 alpha:.10]];
				break;
		}
		
		[self redraw];
	}
}

- (void)setOptionOpacity:(int)value
{
	if(optionOpacity != value) {
		optionOpacity = value;
		
		if(optionOpacity == 100)
			[[self window] setAlphaValue:1.0];
		else
			[[self window] setAlphaValue:(float)optionOpacity * .01];
	}
}

- (void)readOptions
{	
	NSString* identifier = [webView groupName];
	if([identifier isEqualToString:@"Unknown"])
		return;

	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSDictionary* udEntry = [ud persistentDomainForName:[NSString stringWithFormat:@"Amnesty Hypercube/%@.cube/%@", domain, identifier]];
	if(udEntry) {
		NSNumber* levelOption = [udEntry objectForKey:@"Level"];
		if(level)
			[self setOptionLevel:[levelOption intValue]];
			
		NSNumber* dragOption = [udEntry objectForKey:@"Drag"];
		if(drag)
			[self setOptionDrag:[dragOption intValue]];
	
		NSNumber* backgroundOption = [udEntry objectForKey:@"Background"];
		if(background)
			[self setOptionBackground:[backgroundOption intValue]];
	
		NSNumber* opacityOption = [udEntry objectForKey:@"Opacity"];
		if(opacity)
			[self setOptionOpacity:[opacityOption intValue]];
	
		NSNumber* originX = [udEntry objectForKey:@"OriginX"];
		NSNumber* originY = [udEntry objectForKey:@"OriginY"];
		if(originX && originY) {
			optionLocation.x = [originX floatValue];
			optionLocation.y = [originY floatValue];
		}
		
		NSNumber* sizeX = [udEntry objectForKey:@"SizeX"];
		NSNumber* sizeY = [udEntry objectForKey:@"SizeY"];
		if(sizeX && sizeY) {
			optionSize.width = [sizeX floatValue];
			optionSize.height = [sizeY floatValue];
		}
		
		if(isReady) {
			int ix = (int) optionLocation.x;
			int iy = (int) optionLocation.y;
			if(ix >= 8192 || iy >= 8192) {
				optionLocation = NSZeroPoint;
				ix = 0;
				iy = 0;
			}
			
			if(ix == 0 && iy == 0)
				[[self window] center];
			else
				[[self window] setFrameTopLeftPoint:optionLocation];
		}

		NSNumber* goOpaqueValue = [udEntry objectForKey:@"GoOpaque"];
		if(goOpaqueValue)
			optionGoOpaque = ([goOpaqueValue intValue] ? YES : NO);
		
		foundOptions = YES;
	}
	else if(isReady) {
		if(optionLevel != levelFloating) {
			optionLevel = 0;
			[self setOptionLevel:levelFloating];
		}
		
		if(optionDrag != dragWidget) {
			optionDrag = 0;
			[self setOptionDrag:dragWidget];
		}
		
		if(optionBackground != backgroundClear) {
			optionBackground = 0;
			[self setOptionBackground:backgroundClear];
		}
		
		if(optionOpacity != 100) {
			optionOpacity = 0;
			[self setOptionOpacity:100];
		}
		
		optionGoOpaque = NO;
		
		[[self window] center];
				
		foundOptions = NO;
	}

	NSDictionary* udEntry2 = [ud persistentDomainForName:[NSString stringWithFormat:@"Amnesty Hypercube/_Globals/%@", identifier]];
	if(udEntry2) {
		NSNumber* sleep = [udEntry2 objectForKey:@"AllowSleeping"];
		if(sleep) {
			if(allowSleeping != [sleep intValue]) {
				allowSleeping = ([sleep intValue] ? YES : NO);
				
				if([webView respondsToSelector:@selector(_setDashboardBehavior:to:)]) 
					[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns to:!allowSleeping];
			}
		}
		
		NSNumber* suspend = [udEntry2 objectForKey:@"AllowSuspending"];
		if(suspend)
			allowPausing = ([suspend intValue] ? YES : NO);
			
		NSNumber* host = [udEntry2 objectForKey:@"AllowHosting"];
		if(host)
			allowHosting = ([host intValue] ? YES : NO);
			
		foundGlobals = YES;
	}
	else
		foundGlobals = NO;
}

- (void)writeOptions
{	
	if(isReady == NO)
		return;
		
	NSString* identifier = [webView groupName];
	if([identifier isEqualToString:@"Unknown"])
		return;
		
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSString* domainName = [NSString stringWithFormat:@"Amnesty Hypercube/%@.cube/%@", domain, identifier];	
	NSDictionary* originalUdEntry = [ud persistentDomainForName:domainName];

	NSMutableDictionary* udEntry;
	
	if(originalUdEntry) {
		udEntry =  [[NSMutableDictionary alloc] initWithCapacity:[originalUdEntry count]];
		[udEntry addEntriesFromDictionary:originalUdEntry];
	}
	else
		udEntry = [[NSMutableDictionary alloc] initWithCapacity:4];

#if 0
	[udEntry setObject:[NSNumber numberWithInt:optionLevel] forKey:@"Level"];
	[udEntry setObject:[NSNumber numberWithInt:optionDrag] forKey:@"Drag"];
	[udEntry setObject:[NSNumber numberWithInt:optionBackground] forKey:@"Background"];
	[udEntry setObject:[NSNumber numberWithInt:optionOpacity] forKey:@"Opacity"];
	
	NSRect frame = [[self window] frame];
	[udEntry setObject:[NSNumber numberWithFloat:frame.origin.x] forKey:@"OriginX"];
	[udEntry setObject:[NSNumber numberWithFloat:frame.origin.y + frame.size.height] forKey:@"OriginY"];
	
	[ud setPersistentDomain:udEntry forName:[NSString stringWithFormat:@"Amnesty Hypercube/%@.cube/%@", domain, identifier]];
	[udEntry release];

	NSMutableDictionary* udEntry2 = [[NSMutableDictionary alloc] initWithCapacity:0];
	[udEntry2 setObject:[NSNumber numberWithInt:allowSleeping] forKey:@"AllowSleeping"];
	[udEntry2 setObject:[NSNumber numberWithInt:allowPausing] forKey:@"AllowSuspending"];
	[udEntry2 setObject:[NSNumber numberWithInt:allowHosting] forKey:@"AllowHosting"];
	[ud setPersistentDomain:udEntry2 forName:[NSString stringWithFormat:@"Amnesty Hypercube/_Globals/%@", identifier]];
	[udEntry2 release];
#else	
	[udEntry setObject:[NSNumber numberWithInt:optionLevel] forKey:@"Level"];
	[udEntry setObject:[NSNumber numberWithInt:optionDrag] forKey:@"Drag"];
	[udEntry setObject:[NSNumber numberWithInt:optionBackground] forKey:@"Background"];
	[udEntry setObject:[NSNumber numberWithInt:optionOpacity] forKey:@"Opacity"];
	
	NSRect frame = [[self window] frame];
	[udEntry setObject:[NSNumber numberWithFloat:frame.origin.x] forKey:@"OriginX"];
	[udEntry setObject:[NSNumber numberWithFloat:frame.origin.y + frame.size.height] forKey:@"OriginY"];
	[udEntry setObject:[NSNumber numberWithFloat:frame.size.width] forKey:@"SizeX"];
	[udEntry setObject:[NSNumber numberWithFloat:frame.size.height] forKey:@"SizeY"];

	int goOpaqueValue = optionGoOpaque;
	[udEntry setObject:[NSNumber numberWithInt:goOpaqueValue] forKey:@"GoOpaque"];

	[ud setPersistentDomain:udEntry forName:domainName];
	[udEntry release];
#endif

	[ud synchronize];
}

- (void)launchURL:(NSURL*)url
{
    LSOpenCFURLRef((CFURLRef) url, NULL);
}

- (void)redraw
{
	NSView* content = [[self window] contentView];
	[content setNeedsDisplayInRect:[content frame]];

	/*if(hasFlash)
		[NSTimer
			scheduledTimerWithTimeInterval:(double) 1.0
			target:self
			selector:@selector(redrawFlash:)
			userInfo:nil
			repeats:NO];*/
}

/*- (void)redrawFlash:(id)sender
{
	if([[self window] isVisible]) {
		WidgetView* content = (WidgetView*) [[self window] contentView];
		[content setNeedsDisplay:YES];
	}
}*/

- (void)broadcastAdd:(id)sender
{
	NSRect frame = [[self window] frame];

	if([self adjustSize:self]) {
		if(foundOptions) {
			int ix = (int) optionLocation.x;
			int iy = (int) optionLocation.y;
			if(ix >= 8192 || iy >= 8192) {
				optionLocation = NSZeroPoint;
				ix = 0;
				iy = 0;
			}
			
			if(ix == 0 && iy == 0)
				[[self window] center];
			else
				[[self window] setFrameTopLeftPoint:optionLocation];
		}
		else
			[[self window] center];
	}
			
	if((int) frame.size.width <= 72) {
		frame.size.width = 320.0;
		[[self window] setFrame:frame display:NO animate:NO];
		
		readyAfterAdjust = YES;
		[self performSelectorOnMainThread:@selector(adjustReady:) withObject:nil waitUntilDone:NO];
	}

	WidgetView* content = (WidgetView*) [[self window] contentView];
	[content loadBadge];

	//NSString* title = [widgetManager infoForWidget:[webView groupName] key:@"title"];
	//[content setToolTip:title];	
		
	if(shouldHideOnReady == NO && doExport == NO) {
		NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"HypercubeServer" host:nil];
		if(proxy) {
			NSString* identifier = [webView groupName];
			[proxy widgetIsShowing:identifier];
		}
		
		[[self window] orderFront:self];
	}
	else {
		NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"HypercubeServer" host:nil];
		if(proxy) {
			NSString* identifier = [webView groupName];
			[proxy widgetIsHiding:identifier];
		}
	}
	
	if(hasFlash) {
		//if([webView respondsToSelector:@selector(setDrawsBackground:)])
		//	[webView setDrawsBackground:YES];
	}
	
	[webView setHidden:NO];

	if(shouldHideOnReady == NO) {
		[self redraw];

		if(isIPhoneApp && didSetTitle) {
#if 0		
			NSString* title = [widgetManager infoForWidget:[webView groupName] key:@"title"];
			if([title isEqualToString:NSLocalizedString(@"IPhoneApp", @"")]) {
				NSString* newTitle = [NSString stringWithString:[[self window] title]];
				
				NSRange dash0 = [newTitle rangeOfString:@"-"];
				NSRange dash1 = [newTitle rangeOfString:@"&ndash;"];
				NSRange dash2 = [newTitle rangeOfString:@"&mdash;"];
				
				if(dash0.location != NSNotFound)
					newTitle = [newTitle substringToIndex:dash0.location];
				else if(dash1.location != NSNotFound)
					newTitle = [newTitle substringToIndex:dash1.location];
				else if(dash2.location != NSNotFound)
					newTitle = [newTitle substringToIndex:dash2.location];
					
				newTitle = [newTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					
				[widgetManager setInfoForWidget:[webView groupName] key:@"title" object:newTitle];
			}
#endif
		}
	}
	
	willBeVisible = NO;	
	
	if(readyAfterAdjust == NO)
		[self ready];
}

// Notifications
- (void)webBoundsChanged:(NSNotification*)aNotification
{
	if(hasFlash) {
		WidgetView* content = (WidgetView*) [[self window] contentView];
		[content setNeedsDisplay:YES];
	}
}

- (void)webReady:(NSNotification*)aNotification
{	
	if(isReady == NO) {
		[self checkForFlash:NO];

		[self performSelectorOnMainThread:@selector(broadcastAdd:) withObject:self waitUntilDone:NO];
		
		isReady = YES;
	}
}

// NSWindow delegate
- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
	if(optionOpacity != 100 && optionGoOpaque)
		[[self window] setAlphaValue:1.0];
	
	[self redraw];
}

- (void)windowDidResignKey:(NSNotification *)aNotification
{
	if(optionOpacity != 100 && optionGoOpaque)
		[[self window] setAlphaValue:(float)optionOpacity * .01];
	
	[self redraw];
}

- (void)windowDidResize:(NSNotification*)aNotification  
{
	NSRect frame = [[self window] frame];

	if(tracker) {
		[webView removeTrackingRect:tracker];
		tracker = 0;
	}
	
	frame.origin.x = 0.0;
	frame.origin.y = 0.0;	
	WidgetView* content = (WidgetView*) [[self window] contentView];
	tracker = [webView addTrackingRect:frame owner:content userData:nil assumeInside:NO];

	[self redraw];
}

- (void)windowDidMove:(NSNotification*)aNotification
{
	[self redraw];
}

// WebFrameLoad delegate
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	if(isReady)
		[self adjustSize:self];
}
 
 - (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if(frame == [sender mainFrame] && [title length] > 0) {
		didSetTitle = YES;
		[[self window] setTitle:title];
    }
}

// WebPolicy delegate
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
	NSURL* url = [request URL];

	// support authorization attempts in subframes for Google
	NSString* urlString = [url absoluteString];
				
	if([urlString hasPrefix:@"http://talkgadget.google.com/talkgadget/"]) {
		[self checkForFlash:YES];

		allowBrowserSpawning = YES;
		
		if(foundGlobals == NO) {
			allowPausing = NO;
		}	
	}
	
	NSRange googleRelay = [urlString rangeOfString:@"google.com/ig/ifpc_relay"];
	if(googleRelay.location != NSNotFound) {
		[listener use];
		return;
	}
	
	if([urlString hasPrefix:@"http://www.amnestywidgets.com/hypercube/machost/"]) {
		[listener use];
		return;
	}
	
	if([frame isEqual:[webView mainFrame]]) {
		NSString* scheme = [url scheme];
		if([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
		
			[self launchURL:url];
			
			[listener ignore];
			return;
		}
	}
	
	[listener use];
}

- (void)webView:(WebView *)sender decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
	[listener use];
}

- (void)webView:(WebView *)sender unableToImplementPolicyWithError:(NSError *)error frame:(WebFrame *)frame
{
	//NSLog(@"error: %@", [error localizedDescription]);
}

- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener
{
	NSURL* url = [request URL];
	[self launchURL:url];
	
	[listener ignore];
}

// WebResourceLoad delegate (via DownCloud)
- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{	
	if(isReady)
		[self adjustSize:self];
}

// WebUI delegate
- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
	NSURL* url = [request URL];
	if(url == nil)
		url = [request mainDocumentURL];
						
	if(url)
		[self launchURL:url];
	else if(allowBrowserSpawning) {
#if 0
		// asking to open _blank, only allow for known widgets (e.g. Google Talk)
		BrowserController* controller = [widgetManager createBrowserController];	
		[controller setProvisionalParent:[self window]];
		
		WebView* result = [controller getWebView];
		[result setGroupName:[sender groupName]];
		
		return result;
#endif
	}
		
	return webView;
}

- (void)webViewShow:(WebView *)sender
{
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
	return nil;
}

// NSApplication delgate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSTimer
		scheduledTimerWithTimeInterval:(double) 2.0
		target:self
		selector:@selector(checkServer:)
		userInfo:nil
		repeats:YES];

	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSString* identifier = [ud stringForKey:@"widgetID"];
	NSString* key = [ud stringForKey:@"widgetKey"];
	NSString* export = [ud stringForKey:@"widgetExport"];
	
	//identifier = @"(www.google.com)F7D5-8769-842C-CF83";

	if(identifier == nil || key == nil) {
		terminateNow = YES;
		return;
	}
	
	NSString* verifyKey = [NSString stringWithFormat:@"%X", [WidgetManager markerFromCode:identifier]];
	if([key isEqualToString:verifyKey] == NO) {
		NSLog(@"%@", verifyKey);
		terminateNow = YES;
		return;
	}
		
	NSDictionary* udEntry = [ud persistentDomainForName:@"com.amnestywidgets.Hypercube"];
	if(udEntry) {
		if([ud objectForKey:@"Syndicate"])
			doSyndicate = [ud boolForKey:@"Syndicate"];
	}
			
	NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:identifier host:nil];
	if(proxy) {
		terminateNow = YES;
		return;
	}
	
	if(export) {
		doExport = YES;
		
		if([export isEqualToString:@"Dashboard"])
			exportDashboard = YES;
		else if([export isEqualToString:@"Yahoo"])
			exportYahoo = YES;
		else {
			terminateNow = YES;
			return;
		}
	}		
	
	if([self loadWidget:identifier]) {
		if(doExport == NO) {
			WidgetManager* manager = [[WidgetManager alloc] initWithController:self];
			
			NSConnection* serverConnection = [NSConnection defaultConnection];
			[serverConnection setRootObject:manager];
			[serverConnection registerName:identifier];
			
			NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"HypercubeServer" host:nil];
			if(proxy)
				[proxy widgetIsLoading:identifier];
			
			if([ud objectForKey:@"PrefReduceCPU"])
				doReduceCPU = [ud boolForKey:@"PrefReduceCPU"];
				
			if(doReduceCPU)
				setpriority(PRIO_PROCESS, 0, 20);
		} 
	}
	else
		terminateNow = YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	if(isReady) {
		[self writeOptions];

		if(doExport == NO) {
			NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"HypercubeServer" host:nil];
			if(proxy) {
				NSString* identifier = [webView groupName];
				[proxy widgetIsClosing:identifier];
			}
		}
	}
}

- (void)checkServer:(id)sender
{
	NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"HypercubeServer" host:nil];
	if(proxy == nil || terminateNow) {
		[sender invalidate];
		[NSApp terminate:self];
	}
}

@end
