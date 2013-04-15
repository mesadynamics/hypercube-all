//
//  DownCloud.m
//  DownCloud
//
//  Created by Danny Espinoza on 6/23/08.
//  Copyright 2008 Mesa Dynamics, LLC. All rights reserved.
//

#import "DownCloud.h"
#import "DownCloudProtocol.h"
#import <SystemConfiguration/SCNetwork.h>

static BOOL protocolIsRegistered = NO;

@implementation DownCloud

- (id)initWithWebView:(WebView*)webView cacheName:(NSString*)cacheName
{
	if(self = [super init]) {
		_webView = [webView retain];
		_cacheName = [cacheName retain];
		
		_fileCache = nil;
		_dataCache = nil;
		_sessionData = nil;
		_sessionID = nil;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(terminate:) name:NSApplicationWillTerminateNotification object:NSApp];

		BOOL canConnect = NO;
		
		SCNetworkConnectionFlags flags;
		if(SCNetworkCheckReachabilityByName("downcloud.com", &flags)) {
			if((flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired)) {
				canConnect = YES;
			}
		}
		
		delegate = [webView resourceLoadDelegate];
		[webView setResourceLoadDelegate:self];

		if(protocolIsRegistered == NO) {
			protocolIsRegistered = YES;
			
			[NSURLProtocol registerClass:[DownCloudProtocol class]];
			
			if([WebView respondsToSelector:@selector(registerURLSchemeAsLocal:)])
				[WebView registerURLSchemeAsLocal:@"downcloud"];
		}
		
		if(canConnect) {
			_dataCache = [[NSMutableDictionary alloc] init];
			_sessionData = [[NSMutableDictionary alloc] init];
			_sessionID = [[NSMutableDictionary alloc] init];
		}
		else {
			[self readFileCache];
		}
	}
	
	return self;
}

- (void)dealloc
{
	[self deinit];
	
	if(_fileCache) {
		[_fileCache removeAllObjects];
		[_fileCache release];
	}
	
	if(_dataCache) {
		[_dataCache removeAllObjects];
		[_dataCache release];
	}
	
	[_cacheName release];
	[_webView release];
	
	[super dealloc];
}

- (void)deinit
{
	if(_sessionID) {
		[[_sessionID allValues] makeObjectsPerformSelector:@selector(cancel)];
		[_sessionID release];
		
		_sessionID = nil;
	}
	
	if(_sessionData) {
		[_sessionData release];
	
		_sessionData = nil;
	}
	
	[self writeDataCache];
}

- (void)terminate:(NSNotification*)aNotification
{
	[self deinit];
}

- (void)readFileCache
{
	if(_fileCache == nil)
		_fileCache = [[NSMutableDictionary alloc] init];
	
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* bundleName = [[NSBundle mainBundle] bundleIdentifier];
	
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Application Support/DownCloud", NSHomeDirectory()];
	NSString* cacheDirectory = [NSString stringWithFormat:@"%@/%@", libraryDirectory, bundleName];
	NSString* widgetCacheDirectory = [NSString stringWithFormat:@"%@/%@", cacheDirectory, _cacheName];
	
	if([fm fileExistsAtPath:widgetCacheDirectory]) {
		NSArray* cacheFiles = [fm directoryContentsAtPath:widgetCacheDirectory];
		NSEnumerator* enumerator = [cacheFiles objectEnumerator];
		NSString* cacheFileName;
		
		while((cacheFileName = [enumerator nextObject])) {
			NSString* cacheFilePath = [NSString stringWithFormat:@"downcloud://%@/%@/%@", bundleName, _cacheName, cacheFileName];
			NSURL* cacheFileURL = [NSURL URLWithString:cacheFilePath];
			[_fileCache setObject:cacheFileURL forKey:cacheFileName];
		}
	}
}

- (void)writeDataCache
{
	if(_dataCache == nil)
		return;
	
	NSFileManager* fm = [NSFileManager defaultManager];
	
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Application Support/DownCloud", NSHomeDirectory()];
	if([fm fileExistsAtPath:libraryDirectory] == NO)
		[fm createDirectoryAtPath:libraryDirectory attributes:nil];
	
	NSString* cacheDirectory = [NSString stringWithFormat:@"%@/%@", libraryDirectory, [[NSBundle mainBundle] bundleIdentifier]];
	if([fm fileExistsAtPath:cacheDirectory] == NO)
		[fm createDirectoryAtPath:cacheDirectory attributes:nil];
		
	NSString* widgetCacheDirectory = [NSString stringWithFormat:@"%@/%@", cacheDirectory, _cacheName];
	if([fm fileExistsAtPath:widgetCacheDirectory] == NO)
		[fm createDirectoryAtPath:widgetCacheDirectory attributes:nil];
	
	NSEnumerator* enumerator = [[_dataCache allKeys] objectEnumerator];
	NSString* identifier;
	
	while(identifier = [enumerator nextObject]) {
		NSData* data = [_dataCache objectForKey:identifier];
		
		NSString* resourceCachePath = [NSString stringWithFormat:@"%@/%@", widgetCacheDirectory, identifier];
		[fm createFileAtPath:resourceCachePath contents:data attributes:nil];
	}
}

- (void)cacheResource:(WebResource*)resource
{
	NSURL* url = [resource URL];
	NSString* urlString = [url absoluteString];
	NSString* dci = [NSString stringWithFormat:@"%x", [urlString hashDownCloud]];
	
	[self cacheData:[resource data] withIdentifier:dci];
}

- (void)cacheData:(NSData*)data withIdentifier:(NSString*)identifier
{
	if(data)
		[_dataCache setObject:data forKey:identifier];
}

// NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[_sessionData removeObjectForKey:[connection description]];
	[_sessionID removeObjectForKey:[connection description]];	
	[connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSMutableData* connectionData = [_sessionData objectForKey:[connection description]];
	if(connectionData == nil) {
		connectionData = [[NSMutableData alloc] initWithCapacity:[data length]];
		[_sessionData setObject:connectionData forKey:[connection description]];
		[connectionData release];
	}
	
	[connectionData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSMutableData* connectionData = [_sessionData objectForKey:[connection description]];
	NSString* connectionID = [_sessionID objectForKey:[connection description]];
	
 	if(connectionData && connectionID)
		[self cacheData:connectionData withIdentifier:connectionID];
	
	[_sessionData removeObjectForKey:[connection description]];
	[_sessionID removeObjectForKey:[connection description]];	
	[connection release];
}

// WebResourceLoad delegate
- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource
{
	return [request URL];
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
	if(_fileCache) {
		NSString* urlString = [identifier absoluteString];		
		NSString* dci = [NSString stringWithFormat:@"%x", [urlString hashDownCloud]];
		
		NSURL* cacheFileURL = [_fileCache objectForKey:dci];
		if(cacheFileURL)
			return [NSURLRequest requestWithURL:cacheFileURL];
	}
		
	return request;
}

-(void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{	
	if(_dataCache) {
		WebResource* resource = [dataSource subresourceForURL:identifier];
		if(resource)
			[self cacheResource:resource];
		else {
			NSString* urlString = [identifier absoluteString];
			if([urlString hasPrefix:@"http://"] ||[ urlString hasPrefix:@"https://"]) {
				NSURLRequest* request = [NSURLRequest requestWithURL:identifier cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
				
				NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
				NSString* dci = [NSString stringWithFormat:@"%x", [urlString hashDownCloud]];

				[_sessionID setObject:dci forKey:[connection description]];
			}
		}
	}
	
	[delegate webView:sender resource:identifier didFinishLoadingFromDataSource:dataSource];
}

@end


@implementation NSString (DownCloud)

- (int)hashDownCloud
{	
  	int base1 = 0;
	int base2 = 0;
	int base3 = 0;
	int base4 = 0;
	
	char* element = (char*) [self UTF8String];
	
	while(*element) {
		int h = (int) (*element);
		
		base1 += h;
		element++;
		
		if(*element) {
			h = (int) (*element);
			
			base1 += h;
			base2 += h;
			element++;
		}
		
		if(*element) {
			h = (int) (*element);
			
			base1 += h;
			base3 += h;
			element++;
		}
		
		if(*element) {
			h = (int) (*element);
			
			base1 += h;
			base2 += h;
			element++;
		}
		
		if(*element) {
			h = (int) (*element);
			
			base1 += h;
			base4 += h;
			element++;
		}
		
		if(*element) {
			h = (int) (*element);
			
			base1 += h;
			base2 += h;
			base3 += h;
			element++;
		}
	}
	
	return (base1 + (base2 << 8) + (base3 << 16) + (base4 << 24));
}

@end



