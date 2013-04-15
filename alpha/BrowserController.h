//
//  BrowserController.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/19/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface BrowserController : NSWindowController {
	IBOutlet WebView* webView;

	NSWindow* provisionalParent;

	BOOL revealWindow;
}

- (WebView*)getWebView;

- (void)ready:(id)sender;
- (void)setProvisionalParent:(NSWindow*)window;

@end
