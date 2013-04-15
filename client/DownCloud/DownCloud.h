//
//  DownCloud.h
//  DownCloud
//
//  Created by Danny Espinoza on 6/23/08.
//  Copyright 2008 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSString.h>
#import <WebKit/WebKit.h>


@interface DownCloud : NSObject {
	id delegate;
	
	WebView* _webView;
	NSString* _cacheName;
	
	NSMutableDictionary* _fileCache;
	NSMutableDictionary* _dataCache;
	NSMutableDictionary* _sessionData;
	NSMutableDictionary* _sessionID;
}

- (id)initWithWebView:(WebView*)webView cacheName:(NSString*)cacheName;
- (void)deinit;
- (void)terminate:(NSNotification*)aNotification;

- (void)readFileCache;
- (void)writeDataCache;
- (void)cacheResource:(WebResource*)resource;
- (void)cacheData:(NSData*)data withIdentifier:(NSString*)identifier;

@end


@interface NSString (DownCloud)
- (int)hashDownCloud;
@end


@interface WebView (DownCloud)
+ (void)registerURLSchemeAsLocal:(NSString*)scheme;
@end


