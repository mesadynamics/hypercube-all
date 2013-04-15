//
//  GalleryController.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/21/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "GalleryController.h"
#import "GalleryView.h"
#import "GalleryCell.h"
#import "CubeButton.h"
#import "WidgetManager.h"
#import "WebView+Amnesty.h"

@implementation GalleryController

- (void)awakeFromNib
{
	widgetManager = nil;

	homeButton = nil;
	backButton = nil;
	forwardButton = nil;
	scrollUpButton = nil;
	scrollDownButton = nil;
	
	home = nil;

	tracker = 0;
	isSilent = NO;

	[box setPostsFrameChangedNotifications:YES];

	WebFrame* mainFrame = [webView mainFrame];
	WebFrameView* mainFrameView = [mainFrame frameView];
	NSView* documentView = [mainFrameView documentView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webBoundsChanged:) name:NSViewBoundsDidChangeNotification object:documentView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webReady:) name:WebViewProgressFinishedNotification object:webView];

	[webView setHostWindow:[self window]];

#if defined(TransparentGallery)
	if([webView respondsToSelector:@selector(setDrawsBackground:)])
		[webView setDrawsBackground:NO];

	domObject = nil;
	hasFlash = NO;
	hasTransparentFlash = NO;
#endif

	if([webView respondsToSelector:@selector(_setDashboardBehavior:to:)]) {
		[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendMouseEventsToAllWindows to:YES];
		[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysAcceptsFirstMouse to:YES];
		[webView _setDashboardBehavior:WebDashboardBehaviorAllowWheelScrolling to:YES];
		[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns to:NO];
	}

	[webView setEditable:NO];
	[webView setCustomUserAgent:@"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.4 (KHTML, like Gecko) Hypercube/0.2a"];
	isSpoofing = NO;	

	[[self window] makeFirstResponder:grid];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

#if defined(TransparentGallery)
	[domObject release];
#endif

	if(tracker) {
		GalleryView* content = (GalleryView*) [[self window] contentView];
		[content removeTrackingRect:tracker];
		tracker = 0;
	}

	[[self window] setDelegate:nil];
	
	[webView setUIDelegate:nil];
	
	[webView setHidden:YES];
	//[webView removeFromSuperviewWithoutNeedingDisplay];
	[webView setHostWindow:nil];
	//[webView _close];
	
	[home release];
	
	[widgetManager release];
	
	[super dealloc];
}

- (WebView*)webView
{
	return webView;
}

- (GalleryGrid*)grid
{
	return grid;
}

- (void)setGalleryTitle:(NSString*)string
{
	[title setStringValue:string];
}

- (void)setWidgetManager:(id)object
{
	widgetManager = [object retain];
}

- (void)createButtons:(id)target
{
	NSWindow* window = [self window];
	NSRect frame = [window frame];
	
	NSRect borderFrame = NSInsetRect(frame, 100.0, 100.0);
	if(borderFrame.size.width > borderFrame.size.height)
		borderFrame.size.width = (borderFrame.size.width + borderFrame.size.height) / 2.0;
	else
		borderFrame.size.height = (borderFrame.size.width + borderFrame.size.height) / 2.0;
		
	if(borderFrame.size.width < 832.0)
		borderFrame.size.width = 832.0;
		
	borderFrame.origin.x = (frame.size.width - borderFrame.size.width) * .5;
	borderFrame.origin.y = (frame.size.height - borderFrame.size.height) * .5;

	NSRect buttonFrame = NSMakeRect(borderFrame.origin.x + borderFrame.size.width - 58.0, borderFrame.origin.y + borderFrame.size.height - 58.0, 48.0, 48.0);
	CubeButton* button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"Close" inWindow:window];
    [button setTarget:target];
    [button setAction:@selector(closeGallery)];
	[button setAutoresizingMask:( NSViewMinYMargin + NSViewMinXMargin )]; 
	[button setToolTip:NSLocalizedString(@"TipClose", @"")];
 	[button release];

	buttonFrame = NSMakeRect(borderFrame.origin.x + 10.0, borderFrame.origin.y + borderFrame.size.height - 58.0, 48.0, 48.0);
	button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"Providers" inWindow:window];
    [button setTarget:target];
    [button setAction:@selector(resetProviders)];
	[button setAutoresizingMask:( NSViewMinYMargin )]; 
	[button setToolTip:NSLocalizedString(@"TipReturn", @"")];
	[button setHidden:YES];
 	[button release];
	homeButton = button;

	buttonFrame = NSMakeRect(borderFrame.origin.x + 63.0, borderFrame.origin.y + borderFrame.size.height - 58.0, 48.0, 48.0);
	button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"Back" inWindow:window];
    [button setTarget:webView];
    [button setAction:@selector(goBack)];
	[button setAutoresizingMask:( NSViewMinYMargin )]; 
	[button setToolTip:NSLocalizedString(@"TipPrevious", @"")];
	[button setHidden:YES];
 	[button release];
	backButton = button;
	
	buttonFrame = NSMakeRect(borderFrame.origin.x + 116.0, borderFrame.origin.y + borderFrame.size.height - 58.0, 48.0, 48.0);
	button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"Forward" inWindow:window];
	[button setTarget:webView];
    [button setAction:@selector(goForward)];
	[button setAutoresizingMask:( NSViewMinYMargin )]; 
	[button setToolTip:NSLocalizedString(@"TipNext", @"")];
	[button setHidden:YES];
 	[button release];
	forwardButton = button;

	buttonFrame = NSMakeRect(borderFrame.origin.x + borderFrame.size.width - 58.0, borderFrame.origin.y + 10.0, 48.0, 48.0);
	button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"Down" inWindow:window];
    [button setTarget:self];
    [button setAction:@selector(scrollDown)];
	[button setAutoresizingMask:( NSViewMinYMargin + NSViewMinXMargin )]; 
	[button setToolTip:NSLocalizedString(@"TipDown", @"")];
 	[button setContinuous:YES];
 	[button release];
	scrollDownButton = button;

	buttonFrame = NSMakeRect(borderFrame.origin.x + borderFrame.size.width - 111.0, borderFrame.origin.y + 10.0, 48.0, 48.0);
	button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"Up" inWindow:window];
    [button setTarget:self];
    [button setAction:@selector(scrollUp)];
	[button setAutoresizingMask:( NSViewMinYMargin + NSViewMinXMargin )]; 
	[button setToolTip:NSLocalizedString(@"TipUp", @"")];
 	[button setContinuous:YES];
 	[button release];
	scrollUpButton = button;
	
	int i;
	for(i = 0; i < 7; i++) {
		buttonFrame = NSMakeRect(borderFrame.origin.x + 10.0 + (53.0 * i), borderFrame.origin.y + borderFrame.size.height - 58.0, 48.0, 48.0);
		
		switch(i) {
			case 0:
				button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"PreAll" inWindow:window];
				[button setToolTip:NSLocalizedString(@"TipPresetAll", @"")];
				break;
				
			case 1:
				button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"PreDirectory" inWindow:window];
				[button setToolTip:NSLocalizedString(@"TipPresetLibraries", @"")];
				break;
				
			case 2:
				button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"PreGames" inWindow:window];
				[button setToolTip:NSLocalizedString(@"TipPresetGames", @"")];
				break;
				
			case 3:
				button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"PreVideo" inWindow:window];
				[button setToolTip:NSLocalizedString(@"TipPresetVideo", @"")];
				break;
				
			case 4:
				button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"PrePhotos" inWindow:window];
				[button setToolTip:NSLocalizedString(@"TipPresetPhotos", @"")];
				break;
				
			case 5:
				button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"PreMusic" inWindow:window];
				[button setToolTip:NSLocalizedString(@"TipPresetMusic", @"")];
				break;
				
			case 6:
				button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"PreOther" inWindow:window];
				[button setToolTip:NSLocalizedString(@"TipPresetOther", @"")];
				break;
		}

		[button setTag:1000+i];
		//[button setButtonType:NSToggleButton];
		[button setTarget:target];
		[button setAction:@selector(setPreset:)];
		[button setAutoresizingMask:( NSViewMinYMargin )]; 
		
		[button release];
		presets[i] = button;
		
		if(i == 0) {
			[button setState:NSOnState];
			[button setEnabled:NO];
		}
	}

	gridFrame = [grid frame];
	boxFrame = [box frame];
}

- (void)adjustGridForCount:(int)count
{
	NSRect frame = gridFrame;
	[grid setFrame:gridFrame];
	
	NSSize cellSize = [grid cellSize];
	NSSize spaceSize = [grid intercellSpacing];
	
	int width = frame.size.width;
	int space = (cellSize.width + spaceSize.width);
	int padding = (width % space);
	int cols = 0;
	if(padding == 0)
		cols = width / space;
	else
		cols =  (width - padding) / space;
		
	int rows = 0;
	if(cols) {
		int rec = count % cols;
		if(rec == 0)
			rows = count / cols;
		else
			rows = (count + (cols - rec)) / cols;
	}
	
	if(count && rows == 0)
		rows = 1;
		
	[grid renewRows:rows columns:cols];
	[grid sizeToCells];
	
	frame = [grid frame];
	frame.size.height = (rows * (cellSize.height + spaceSize.height));
	[grid setFrame:frame];
}

- (void)startBrowser:(BOOL)forInfo
{
	if([webView isHidden]) {
		if(forInfo) {
			[homeButton setHidden:YES];
			[backButton setHidden:YES];
			[forwardButton setHidden:YES];
			
			[webView setPolicyDelegate:self];
		}
		else {
			[homeButton setHidden:NO];
			[backButton setHidden:NO];
			[forwardButton setHidden:NO];

			[webView setPolicyDelegate:nil];
		}
		
		[scrollUpButton setHidden:YES];
		[scrollDownButton setHidden:YES];

		if(isSilent) {
			[box addSubview:webView];
			[webView release];
			[webView setHostWindow:[self window]];
			isSilent = NO;
		}
	}
}

- (void)stopBrowser
{
	if([webView isHidden] == NO) {
		[homeButton setHidden:YES];
		[backButton setHidden:YES];
		[forwardButton setHidden:YES];
		[scrollUpButton setHidden:YES];
		[scrollDownButton setHidden:YES];

		[webView stopLoading:self];
		[webView setHidden:YES];

		if(isSilent == NO) {
			[webView retain];
			[webView removeFromSuperviewWithoutNeedingDisplay];
			[webView setHostWindow:nil];
			isSilent = YES;
		}
	}
}

- (void)setHome:(NSString*)homeURL spoof:(BOOL)spoof
{
	[home release];
	home = [homeURL retain];
	
	if(spoof && isSpoofing == NO) {
		[webView setCustomUserAgent:@"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.4 (KHTML, like Gecko) Safari/125.9"];
		isSpoofing = YES;
	}
	else if(spoof == NO && isSpoofing) {
		[webView setCustomUserAgent:@"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.4 (KHTML, like Gecko) Hypercube/0.2a"];
		isSpoofing = NO;
	}
}

- (void)goHome
{
	WebFrame* mainFrame = [webView mainFrame];
	NSURL* target = [NSURL URLWithString:home];
	[mainFrame loadRequest:[NSURLRequest requestWithURL:target]];
}

- (void)checkScrollers
{
	NSScrollView* scrollView = (NSScrollView*) [grid superview];
	NSRect scrollFrame = [scrollView frame];
	NSPoint p = [grid convertPoint:NSMakePoint(0.0, scrollFrame.origin.y) fromView:nil];

	NSRect frame = [grid cellFrameAtRow:[grid numberOfRows] column:0];		
	if(frame.origin.y + 280.0 > p.y) {
		[scrollUpButton setHidden:NO];
		[scrollDownButton setHidden:NO];
	}
	else {
		[scrollUpButton setHidden:YES];
		[scrollDownButton setHidden:YES];
	}
}

- (void)scrollDown
{
	NSScrollView* scrollView = (NSScrollView*) [grid superview];
	NSRect scrollFrame = [scrollView frame];
	
	NSPoint p = [grid convertPoint:NSMakePoint(0.0, scrollFrame.origin.y) fromView:nil];
	
	int rows = [grid numberOfRows];
	int i;
	for(i = 0; i < rows; i++) {
		NSRect frame = [grid cellFrameAtRow:i column:0];		
		if(frame.origin.y + 280.0 > p.y) {
			//NSLog(@"scroll to row %d", i);
			frame.origin.y += 40.0;
			[grid scrollRectToVisible:frame];
			return;
		}
	}

}

- (void)scrollUp
{
	NSScrollView* scrollView = (NSScrollView*) [grid superview];
	NSRect scrollFrame = [scrollView frame];
	
	NSPoint p = [grid convertPoint:NSMakePoint(0.0, scrollFrame.origin.y) fromView:nil];
	
	int rows = [grid numberOfRows];
	int i;
	for(i = rows - 1; i >= 0; i--) {
		NSRect frame = [grid cellFrameAtRow:i column:0];
		if((frame.origin.y + scrollFrame.size.height + 168.0) - p.y < 0.0) {
			//NSLog(@"scroll to row %d", i);
			[grid scrollRectToVisible:frame];
			return;
		}
	}
}

- (void)showPresets:(BOOL)value
{
	int i;
	for(i = 0; i < 7; i++)
		[presets[i] setHidden:(value == YES ? NO : YES)];
}

- (void)setPresetButton:(int)tag
{
	int i;
	for(i = 0; i < 7; i++) {
		if(1000 + i == tag)
			[presets[i] setEnabled:NO];
		else {
			[presets[i] setState:NSOffState];
			[presets[i] setEnabled:YES];
		}
	}
}

// Notifications
- (void)webBoundsChanged:(NSNotification*)aNotification
{
#if defined(TransparentGallery)
	if(hasFlash) {
		GalleryView* content = (GalleryView*) [[self window] contentView];
		[content setNeedsDisplay:YES];
	}
#endif
}

- (void)webReady:(NSNotification*)aNotification
{
	GalleryView* content = (GalleryView*) [[self window] contentView];	
	[content setMaxRefresh:NO];

#if defined(TransparentGallery)
	hasFlash = NO;
	hasTransparentFlash = NO;

	SInt32 macVersion = 0;
	Gestalt(gestaltSystemVersion, &macVersion);
	
	BOOL checkTransparency = NO;
	if(macVersion == 0x1049) {
		NSString* version = [[NSProcessInfo processInfo] operatingSystemVersionString];
		if([version hasPrefix:@"Version 10.4.9"] == NO)
			checkTransparency = YES;
	}

	FlashIdentifier flashValue = [webView containsFlashWithTransparency:checkTransparency];
	
	if(flashValue != flashNone) {
		if(checkTransparency && flashValue == flashTransparent) {
			[content setRefreshRect:[webView frame]];
			[content setMaxRefresh:YES];

			hasTransparentFlash = YES;
		}
		
		hasFlash = YES;
	}
#endif
			
	[webView setHidden:NO];
}

// NSWindow delegate
- (void)windowDidResize:(NSNotification*)aNotification  
{
	GalleryView* content = (GalleryView*) [[self window] contentView];

	if(tracker) {
		[content removeTrackingRect:tracker];
		tracker = 0;
	}
	
	tracker = [content addTrackingRect:[grid frame] owner:grid userData:nil assumeInside:NO];
	
	NSRect frame = [[self window] frame];
	NSRect borderFrame = NSInsetRect(frame, 100.0, 100.0);
	if(borderFrame.size.width > borderFrame.size.height)
		borderFrame.size.width = (borderFrame.size.width + borderFrame.size.height) / 2.0;
	else
		borderFrame.size.height = (borderFrame.size.width + borderFrame.size.height) / 2.0;
		
	if(borderFrame.size.width < 832.0)
		borderFrame.size.width = 832.0;

	borderFrame.origin.x = (frame.size.width - borderFrame.size.width) * .5;
	borderFrame.origin.y = (frame.size.height - borderFrame.size.height) * .5;
		
	[box setFrame:borderFrame];
	[box setNeedsDisplay:YES];

	NSRect titleFrame = borderFrame;
	titleFrame.origin.y += 10.0;
	titleFrame.origin.x += 10.0;
	titleFrame.size.height = 22.0;
	[title setFrame:titleFrame];
	[title setNeedsDisplay:YES];
}

// WebPolicy delegate
- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener
{
	[widgetManager closeGallery];
	[widgetManager closeCube];
		
	NSURL* url = [request URL];
	LSOpenCFURLRef((CFURLRef) url, NULL);
}

// WebUI delegate
- (void)webView:(WebView *)sender mouseDidMoveOverElement:(NSDictionary *)elementInformation modifierFlags:(unsigned int)modifierFlags
{
#if defined(TransparentGallery)
	if(hasTransparentFlash == NO && hasFlash == YES && elementInformation) {
		DOMElement* object = [elementInformation objectForKey:WebElementDOMNodeKey]; 
		NSString* objectID = [object description];
		
		if(objectID && (domObject == nil || [domObject isEqualTo:objectID] == NO)) {
			//NSLog(objectID);
			
			if(
				[objectID hasPrefix:@"<DOMHTMLElement [EMBED]"] ||
				[objectID hasPrefix:@"<DOMHTMLEmbedElement [EMBED]"]
			) {
				GalleryView* content = (GalleryView*) [[self window] contentView];
				[content setNeedsDisplay:YES];
			}
			
			[domObject release];
			domObject = [objectID copy];
		}
	}
#endif	
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
	return nil;
}

@end
