//
//  WidgetController.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/7/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "WidgetController.h"
#import "WidgetView.h"
#import "WidgetManager.h"
#import "BrowserWindow.h"
#import "AppController.h"
#import "NSImage+ScaleReflect.h"
#import "WebView+Amnesty.h"

enum {
	levelFloating = 100,
	levelStandard = 110,
	levelEmbedded = 120
};

enum {
	dragWidget = 200,
	dragControl = 210,
	dragOff = 220
};

enum {
	pushHypercube = 300,
	pushDashboard = 301
};

enum {
	backgroundClear = 400,
	backgroundWhite = 410,
	backgroundBlack = 420
};

enum {
	configButtonLevel = 1000,
	configButtonDrag = 1001,
	configButtonBackground = 1002,
	configButtonOpacity = 1003
};

@implementation WidgetController

- (id)init
{
	if(self = [super init]) {
		widgetCode = nil;
		domain = nil;
		
		macVersion = 0;
		Gestalt(gestaltSystemVersion, &macVersion);

		tracker = 0;
		
		optionLevel = levelFloating;
		optionDrag = dragWidget;
		optionBackground = backgroundClear;
		optionOpacity = 100;

		isInHypercube = NO;
		isInGallery = NO;
		
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
	}
	
	return self;
}

- (void)dealloc
{
	[domain release];
	[widgetCode release];
	[widgetManager release];
	
	[super dealloc];
}

- (void)close
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[[self window] setDelegate:nil];

	[webView setDownloadDelegate:nil];
    [webView setFrameLoadDelegate:nil];
	[webView setPolicyDelegate:nil];
	[webView setResourceLoadDelegate:nil];
    [webView setUIDelegate:nil];
	
	[webView setHidden:YES];
	//[webView removeFromSuperviewWithoutNeedingDisplay];
	[webView setHostWindow:nil];
	//[webView _close];
		
	[super close];
}

- (void)awakeFromNib
{
	WebFrame* mainFrame = [webView mainFrame];
	WebFrameView* mainFrameView = [mainFrame frameView];
	NSView* documentView = [mainFrameView documentView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webBoundsChanged:) name:NSViewBoundsDidChangeNotification object:documentView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webReady:) name:WebViewProgressFinishedNotification object:webView];

	[webView setHostWindow:[self window]];

	if([webView respondsToSelector:@selector(setDrawsBackground:)])
		[webView setDrawsBackground:NO];

	if([WebView respondsToSelector:@selector(_setShouldUseFontSmoothing:)])
		[WebView _setShouldUseFontSmoothing: YES];

	if([webView respondsToSelector:@selector(setProhibitsMainFrameScrolling:)])
		[webView setProhibitsMainFrameScrolling: YES];
		
	if([webView respondsToSelector:@selector(_setDashboardBehavior:to:)]) {
		[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendMouseEventsToAllWindows to:YES];
		[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysAcceptsFirstMouse to:YES];
		[webView _setDashboardBehavior:WebDashboardBehaviorAllowWheelScrolling to:YES];
		[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns to:NO];
	}
		
	[webView setGroupName:@"Unknown"];
	[webView setEditable:NO];

	[mainFrameView setAllowsScrolling:NO];
}

- (WebView*)getWebView
{
	return webView;
}

- (NSString*)getIdentifier
{
	return [webView groupName];
}

- (void)setIdentifier:(NSString*)name
{
	[webView setGroupName:[name copy]];
}

- (NSString*)getDomain
{
	return domain;
}

- (void)setDomain:(NSString*)name
{
	if([configPanel1 isHidden] == NO) {
		[configPanel1 setHidden:YES];
		[self adjustSize:self];
		
		WidgetView* content = (WidgetView*) [[self window] contentView];
		[content hideBadge:NO];
	}
	else if([configPanel2 isHidden] == NO) {
		[configPanel2 setHidden:YES];
		[self adjustSize:self];
		
		WidgetView* content = (WidgetView*) [[self window] contentView];
		[content hideBadge:NO];
	}
	else if([confirmPanel isHidden] == NO) {
		[confirmPanel setHidden:YES];
		[self adjustSize:self];
		
		WidgetView* content = (WidgetView*) [[self window] contentView];
		[content hideBadge:NO];
	}

	[domain release];
	domain = [name copy];
}

- (BOOL)getHypercube
{
	return isInHypercube;
}

- (void)setHypercube:(BOOL)hypercube
{
	if(isInHypercube != hypercube) {
		isInHypercube = hypercube;
		
		WidgetView* content = (WidgetView*) [[self window] contentView];
		if(isInHypercube)
			[content setPopupMenu:[webView menu]];
		else
			[content setPopupMenu:nil];
	}
}

- (BOOL)getGallery
{
	return isInGallery;
}

- (void)setGallery:(BOOL)gallery
{
	if(isInGallery != gallery) {
		isInGallery = gallery;
	}
}

- (void)setWidgetManager:(id)object
{
	widgetManager = [object retain];
}

- (void)loadSnippet:(NSString*)snippet syndicate:(BOOL)syndicate
{
	BOOL foundSyndication = NO;

	if(syndicate) {
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
		
		WebFrame* mainFrame = [webView mainFrame];
		WebFrameView* mainFrameView = [mainFrame frameView];
		[mainFrameView setAllowsScrolling:YES];

		[webView setCustomUserAgent:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"];
	}	
	else {
		[webView setCustomUserAgent:@"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.4 (KHTML, like Gecko) Safari/125.9"];
	}
	
	[self handleReload:self];
}

- (void)loadRequest:(NSURLRequest*)request
{
	WebFrame* mainFrame = [webView mainFrame];
	[mainFrame loadRequest:request];
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

- (void)focus
{
	if(isInHypercube == NO && isInGallery == NO) {
		switch(optionLevel) {
			case levelStandard:
				[NSApp activateIgnoringOtherApps:YES];	
				[[self window] orderFront:self];
			break;
			
			case levelEmbedded:
				/*if(macVersion >= 0x1040) {
					CGEnableEventStateCombining(false);
					CGPostKeyboardEvent(0, 0x67, true);
					CGPostKeyboardEvent(0, 0x67, false);
					CGEnableEventStateCombining(true);
				}*/
			break;
		}
	}
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
	
	if([configPanel1 isHidden] == NO || [configPanel2 isHidden] == NO || [confirmPanel isHidden] == NO) {
		pushX = 250.0;
		
		if(widgetFrame.size.height < 175.0)
			pushY = 175.0 - widgetFrame.size.height;
	}
	
	widgetFrame.size.width += pushX;
	widgetFrame.size.height += pushY;
		
	if(NSEqualSizes(widgetFrame.size, widgetSize) == NO)
	{
		//NSLog(@"%.2f, %.2f", widgetFrame.size.width, widgetFrame.size.height);
		
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
		if(ix >= 8192 || iy >= 8192)
			[[self window] center];
		else
			[[self window] setFrameTopLeftPoint:topLeft];
			
		didAdjust = YES;
	}
	
	if(sender == nil && hasFlash == NO) {
		NSData* imageData = (NSData*) [widgetManager infoForWidget:[webView groupName] key:@"image"];
		if([imageData length] == 0) {
			[self handleScreenshot:nil];
		}
	}

	return didAdjust;
}

- (void)checkForFlash:(BOOL)force
{
	WidgetView* content = (WidgetView*) [[self window] contentView];	
	[content setMaxRefresh:NO];
	
	hasFlash = NO;

	if(force == YES || [webView containsFlash]) {
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
	
	BOOL delayScreenshot = NO;
	
	if((int) frame.size.width <= 72) {
		frame.size.width = 320.0;
		[[self window] setFrame:frame display:NO animate:NO];
		
		[self performSelectorOnMainThread:@selector(adjustSize:) withObject:nil waitUntilDone:NO];
		
		delayScreenshot = YES;
	}
	
	WidgetView* content = (WidgetView*) [[self window] contentView];
	[content loadBadge];

	//NSString* title = [widgetManager infoForWidget:[webView groupName] key:@"title"];
	//[content setToolTip:title];	
		
	if(shouldHideOnReady == NO) {
		[[self window] orderFront:self];
	}
	
	[webView setHidden:NO];
		
	if(shouldHideOnReady == NO) {
		[self redraw];

		if(delayScreenshot == NO && hasFlash == NO) {
			NSData* imageData = (NSData*) [widgetManager infoForWidget:[webView groupName] key:@"image"];
			if([imageData length] == 0) {
				[self handleScreenshot:nil];
			}
		}
		
		if(isIPhoneApp && didSetTitle) {
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
		}
	}
	
	willBeVisible = NO;
}

- (void)broadcastRemove:(id)sender
{
	[[self window] orderOut:self];

	[widgetManager removeWidget:[webView groupName]];		
}

- (IBAction)handleHide:(id)sender
{
	NSArray* children = [[self window] childWindows];
	NSEnumerator* enumerator = [children objectEnumerator];
	NSWindow* anObject;
	
	while((anObject = [enumerator nextObject]))
		[anObject close];
	
	[self hide];
	[self writeOptions];
}

- (IBAction)handleClose:(id)sender
{
	isInHypercube = NO;
	isInGallery = NO;
	
	{
		NSArray* children = [[self window] childWindows];
		NSEnumerator* enumerator = [children objectEnumerator];
		NSWindow* anObject;
		
		while((anObject = [enumerator nextObject]))
			[anObject close];
		
		[self hide];
	}
	
	[widgetManager forgetWidget:[webView groupName] inDomain:domain];		
}

- (IBAction)handleDashboard:(id)sender
{
	if(isInHypercube == NO)
		[self hide];
	
	NSRect frame = [[self window] frame];
	
	NSString* dashboardID = nil;
	NSRange springRange1 = [widgetCode rangeOfString:@"springwidgets.com"];
	NSRange springRange2 = [widgetCode rangeOfString:@"thespringbox.com"];
	if(springRange1.location != NSNotFound || springRange2.location != NSNotFound)
		dashboardID = @"com.springwidgets.widget";
	else {
		NSRange googleTalk = [widgetCode rangeOfString:@"googletalk.xml"];
		if(googleTalk.location != NSNotFound)
			dashboardID = @"com.google.widget.googletalk";
	}
	
	[widgetManager addToDashboard:widgetCode identifier:[webView groupName] dashboard:dashboardID width:frame.size.width - 20.0 height:frame.size.height];		
}

- (IBAction)handleDesktop:(id)sender
{
}

- (IBAction)handleHypercube:(id)sender
{
}

- (IBAction)handleUninstall:(id)sender
{
	WidgetView* content = (WidgetView*) [[self window] contentView];
	[content hideBadge:YES];

	int saveOpacity = optionOpacity;
	[self setOptionOpacity:100];
	optionOpacity = saveOpacity;

	[confirmPanel setHidden:NO];
	[self adjustSize:self];

	[self focus];
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

- (IBAction)handleLevel:(id)sender
{	
	NSPopUpButton* choice = (NSPopUpButton*) sender;
	configLevel = [[choice selectedItem] tag];
}

- (IBAction)handleDrag:(id)sender
{
	NSPopUpButton* choice = (NSPopUpButton*) sender;
	configDrag = [[choice selectedItem] tag];
}

- (IBAction)handleRename:(id)sender
{
}

- (IBAction)handleInfo:(id)sender
{
	NSString* code = [widgetManager infoForWidget:[webView groupName] key:@"code"];	
	NSData* data = [NSData dataWithData:[code dataUsingEncoding:NSUTF8StringEncoding]];
	
	[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
	[[NSPasteboard generalPasteboard] setData:data forType:NSStringPboardType];
}

- (IBAction)handleOpacity:(id)sender
{
	if([configPanel1 isHidden] == NO) {
		NSSlider* slider = (NSSlider*)sender;
		[self setOptionOpacity:[slider intValue]];
	}
}

- (IBAction)handleBackground:(id)sender
{
	if([configPanel1 isHidden] == NO) {
		NSPopUpButton* choice = (NSPopUpButton*) sender;
		[self setOptionBackground:[[choice selectedItem] tag]];
	}
}

- (IBAction)handleConfigure1:(id)sender
{
	WidgetView* content = (WidgetView*) [[self window] contentView];
	[content hideBadge:YES];

	configLevel = optionLevel;
	configDrag = optionDrag;
	
	NSPopUpButton* button = (NSPopUpButton*) [configPanel1 viewWithTag:configButtonLevel];
	[button selectItemWithTag:configLevel];
	if(isInHypercube) {
		[button setEnabled:NO];
		[configLevelTitle setEnabled:NO];
	}
	else {
		[button setEnabled:YES];
		[configLevelTitle setEnabled:YES];
	}	
	
	button = (NSPopUpButton*) [configPanel1 viewWithTag:configButtonDrag];
	[button selectItemWithTag:configDrag];
	button = (NSPopUpButton*) [configPanel1 viewWithTag:configButtonBackground];
	[button selectItemWithTag:optionBackground];
	NSSlider* slider = (NSSlider*) [configPanel1 viewWithTag:configButtonOpacity];
	[slider setIntValue:optionOpacity];
	
	[configPanel1 setHidden:NO];
	[self adjustSize:self];
	
	[self focus];
}

- (IBAction)handleConfigure2:(id)sender
{
	WidgetView* content = (WidgetView*) [[self window] contentView];
	[content hideBadge:YES];
	
	NSString* title = [widgetManager infoForWidget:[webView groupName] key:@"title"];	
	[configName setStringValue:[NSString stringWithString:title]];
	
	[configSleep setIntValue:allowSleeping];
	[configPause setIntValue:allowPausing];
	[configHost setIntValue:allowHosting];

	[configPanel2 setHidden:NO];
	[self adjustSize:self];

	[self focus];
}

- (IBAction)handleSettings:(id)sender
{
	if([configPanel1 isHidden] == NO) {
		[configPanel1 setHidden:YES];
		
		[self setOptionLevel:configLevel];
		[self setOptionDrag:configDrag];
		
		[self writeOptions];
	}
	else {
		[configPanel2 setHidden:YES];

		NSString* title = [widgetManager infoForWidget:[webView groupName] key:@"title"];	
		NSString* newTitle = [NSString stringWithString:[configName stringValue]];
		if([title isEqualToString:newTitle] == NO)
			[widgetManager setInfoForWidget:[webView groupName] key:@"title" object:newTitle];
			
		BOOL sleep = ([configSleep intValue] ? YES : NO);
		if(sleep != allowSleeping) {
			allowSleeping = sleep;
			
			if([webView respondsToSelector:@selector(_setDashboardBehavior:to:)]) 
				[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns to:!allowSleeping];
		}
			
		BOOL pause = ([configPause intValue] ? YES : NO);
		if(pause != allowPausing) {
			allowPausing = pause;
		}
			
		BOOL host = ([configHost intValue] ? YES : NO);
		if(host != allowHosting) {
			allowHosting = host;
		}
	}
	
	[self adjustSize:self];

	WidgetView* content = (WidgetView*) [[self window] contentView];
	[content hideBadge:NO];
}

- (IBAction)handleConfirmNo:(id)sender
{
	int saveOpacity = optionOpacity;
	optionOpacity = 0;
	[self setOptionOpacity:saveOpacity];

	[confirmPanel setHidden:YES];
	
	[self adjustSize:self];
	
	WidgetView* content = (WidgetView*) [[self window] contentView];
	[content hideBadge:NO];

	[self focus];
}

- (IBAction)handleConfirmYes:(id)sender
{
	[self handleConfirmNo:sender];
	[self performSelectorOnMainThread:@selector(broadcastRemove:) withObject:self waitUntilDone:NO];
}

- (IBAction)handleScreenshot:(id)sender
{
	// this won't work for Flash
	NSImage* image = nil;
	NSBitmapImageRep* bitmap = nil;

	if(macVersion < 0x1040) {
		[webView lockFocus];
		bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[webView bounds]];
		[webView unlockFocus];
	}
	else {
		bitmap = [webView bitmapImageRepForCachingDisplayInRect:[webView bounds]];
		[webView cacheDisplayInRect:[webView bounds] toBitmapImageRep:bitmap];
	}
	
	if(bitmap) {
		image = [[NSImage alloc] init];
		[image addRepresentation:bitmap];
	}

	if(image) {
		[widgetManager setInfoForWidget:[webView groupName] key:@"image" object:image];
		[image release];
	}
}

- (void)resetOptionLevel
{
	int saveOptionLevel = optionLevel;
	optionLevel = 0;
	[self setOptionLevel:saveOptionLevel];
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
			case levelFloating:
				[[self window] setLevel:NSFloatingWindowLevel];
			break;
			
			case levelStandard:
				[[self window] setLevel:NSNormalWindowLevel];
			break;
			
			case levelEmbedded:
				[[self window] setLevel:kCGDesktopWindowLevel];
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
		NSNumber* level = [udEntry objectForKey:@"Level"];
		if(level)
			[self setOptionLevel:[level intValue]];
			
		NSNumber* drag = [udEntry objectForKey:@"Drag"];
		if(drag)
			[self setOptionDrag:[drag intValue]];
	
		NSNumber* background = [udEntry objectForKey:@"Background"];
		if(background)
			[self setOptionBackground:[background intValue]];
	
		NSNumber* opacity = [udEntry objectForKey:@"Opacity"];
		if(opacity)
			[self setOptionOpacity:[opacity intValue]];
	
		NSNumber* originX = [udEntry objectForKey:@"OriginX"];
		NSNumber* originY = [udEntry objectForKey:@"OriginY"];
		if(originX && originY) {
			optionLocation.x = [originX floatValue];
			optionLocation.y = [originY floatValue];
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

	[widgetManager loadWidget:[webView groupName]];		
}

- (void)writeOptions
{	
	if(isReady == NO)
		return;
		
	NSString* identifier = [webView groupName];
	if([identifier isEqualToString:@"Unknown"])
		return;
		
	NSMutableDictionary* udEntry = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[udEntry setObject:[NSNumber numberWithInt:optionLevel] forKey:@"Level"];
	[udEntry setObject:[NSNumber numberWithInt:optionDrag] forKey:@"Drag"];
	[udEntry setObject:[NSNumber numberWithInt:optionBackground] forKey:@"Background"];
	[udEntry setObject:[NSNumber numberWithInt:optionOpacity] forKey:@"Opacity"];
	
	NSRect frame = [[self window] frame];
	[udEntry setObject:[NSNumber numberWithFloat:frame.origin.x] forKey:@"OriginX"];
	[udEntry setObject:[NSNumber numberWithFloat:frame.origin.y + frame.size.height] forKey:@"OriginY"];
	
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	[ud setPersistentDomain:udEntry forName:[NSString stringWithFormat:@"Amnesty Hypercube/%@.cube/%@", domain, identifier]];
	[udEntry release];

	NSMutableDictionary* udEntry2 = [[NSMutableDictionary alloc] initWithCapacity:0];
	[udEntry2 setObject:[NSNumber numberWithInt:allowSleeping] forKey:@"AllowSleeping"];
	[udEntry2 setObject:[NSNumber numberWithInt:allowPausing] forKey:@"AllowSuspending"];
	[udEntry2 setObject:[NSNumber numberWithInt:allowHosting] forKey:@"AllowHosting"];
	[ud setPersistentDomain:udEntry2 forName:[NSString stringWithFormat:@"Amnesty Hypercube/_Globals/%@", identifier]];
	[udEntry2 release];

	[ud synchronize];
}

- (void)launchURL:(NSURL*)url
{
	if(isInGallery) {
		NSBeep();
		return;
	}
	
	if(isInHypercube)
		[widgetManager closeCube];
		
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

- (void)redrawFlash:(id)sender
{
	if([[self window] isVisible]) {
		WidgetView* content = (WidgetView*) [[self window] contentView];
		[content setNeedsDisplay:YES];
	}
}

// NSMenuValidation protocol
- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	int tag = [item tag];
	
	switch(tag) {
#if 0
		case levelFloating:
		case levelStandard:
		case levelEmbedded:
			if(optionLevel == tag)
				[item setState:NSOnState];
			else
				[item setState:NSOffState];
				
			if(isInHypercube)
				return NO;
		break;
		
		case dragWidget:
		case dragControl:
		case dragOff:
			if(optionDrag == tag)
				[item setState:NSOnState];
			else
				[item setState:NSOffState];
		break;
		
		case pushHypercube:
			if(isInHypercube)
				[item setTitle:NSLocalizedString(@"PushDesktop", @"")];
			else
				[item setTitle:NSLocalizedString(@"PushHypercube", @"")];
		break;
#endif
		
		case pushDashboard:
			if(isInGallery)
				return NO;

			if(macVersion < 0x1040 || isIPhoneApp)
				return NO;
		break;
	}
			
	return YES;
}

// Notificaitons
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
	[self redraw];
}

- (void)windowDidResignKey:(NSNotification *)aNotification
{
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

// WebResourceLoad delegate
-(void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
	if(isReady)
		[self adjustSize:self];
}

- (void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource
{
	//NSLog(@"error: %@", [error localizedDescription]);
}

- (void)webView:(WebView *)sender plugInFailedWithError:(NSError *)error dataSource:(WebDataSource *)dataSource
{
	//NSLog(@"error: %@", [error localizedDescription]);
}

-(void)webView:(WebView *)sender resource:(id)identifier didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge fromDataSource:(WebDataSource *)dataSource
{
	//NSLog(@"authorization request");
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
		// asking to open _blank, only allow for known widgets (e.g. Google Talk)
		BrowserController* controller = [widgetManager createBrowserController];	
		[controller setProvisionalParent:[self window]];
		
		WebView* result = [controller getWebView];
		[result setGroupName:[sender groupName]];
		
		return result;
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

@end
