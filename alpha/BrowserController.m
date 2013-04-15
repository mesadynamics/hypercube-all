//
//  BrowserController.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/19/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "BrowserController.h"
#import "BrowserView.h"
#import "AppController.h"
#import "WebView+Amnesty.h"


@implementation BrowserController

- (id)init
{
	provisionalParent = nil;
	
	if(self = [super init]) {
		revealWindow = NO;
	}
	
	return self;
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ready:) name:WebViewProgressFinishedNotification object:webView];

	[webView setHidden:YES];
	[webView setEditable:NO];
	[webView setGroupName:@"Unknown"];
	[webView setCustomUserAgent:@"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.4 (KHTML, like Gecko) Safari/125.9"];	

	[[self window] cascadeTopLeftFromPoint:NSMakePoint(10.0, 10.0)];
}

- (WebView*)getWebView
{
	return webView;
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

- (void)ready:(id)sender
{
	if(revealWindow) {
		[webView setHidden:NO];
		
		if(provisionalParent)
			[provisionalParent addChildWindow:[self window] ordered:NSWindowAbove];
		else
			[[self window] orderFront:self];
	}
}

- (void)setProvisionalParent:(NSWindow*)window
{
	provisionalParent = window;
}

// WebFrameLoad delegate
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if(frame == [sender mainFrame]) {
		[[self window] setTitle:title];
		[[self window] display];
    }
}

// WebPolicy delegate
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
	NSURL* url = [request URL];
	NSString* urlString = [url absoluteString];

	//NSLog(@"open in browser %@ frame %@: %@", sender, frame, url);
		
	// don't display auto-closed status windows (e.g. authorization from Google Talk)	
	if([urlString hasPrefix:@"https://www.google.com/accounts/ServiceLogin?"] || [urlString hasPrefix:@"http://talkgadget.google.com/talkgadget/auth?"])
		;
	else
		revealWindow = YES;
		
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
	LSOpenCFURLRef((CFURLRef) url, NULL);
	
	[listener ignore];
}

// WebResource delegate
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
		LSOpenCFURLRef((CFURLRef) url, NULL);
		
	return webView;
}

- (void)webViewShow:(WebView *)sender
{
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
	NSEnumerator* enumerator = [defaultMenuItems objectEnumerator];
	NSMenuItem* menuItem;
	long index = 0;
   
	while(menuItem = [enumerator nextObject]) {
		if([menuItem tag] == WebMenuItemTagDownloadLinkToDisk) {
			NSMutableArray* newMenuItems = [[NSArray arrayWithArray:defaultMenuItems] mutableCopy];
			[newMenuItems removeObjectAtIndex:index];
			return newMenuItems;
		}
		else if([menuItem tag] == WebMenuItemTagDownloadImageToDisk) {
			NSMutableArray* newMenuItems = [[NSArray arrayWithArray:defaultMenuItems] mutableCopy];
			[newMenuItems removeObjectAtIndex:index];
			return newMenuItems;
		}
		
		index++;
	}
	
	return defaultMenuItems;
}

@end
