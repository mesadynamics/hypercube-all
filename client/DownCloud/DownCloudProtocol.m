//
//  DownCloudProtocol.m
//  DownCloud
//
//  Created by Danny Espinoza on 6/23/08.
//  Copyright 2008 Mesa Dynamics, LLC. All rights reserved.
//

#import "DownCloudProtocol.h"


@implementation DownCloudProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)theRequest
{
    return ([[[theRequest URL] scheme] caseInsensitiveCompare:@"downcloud"] == NSOrderedSame);
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    id<NSURLProtocolClient> client = [self client];
    NSURLRequest* request = [self request];
	NSURL* url = [request URL];
    NSData* data = nil;

	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Application Support/DownCloud", NSHomeDirectory()];
	NSString* cacheLocation = [[url absoluteString] substringFromIndex:11];
	NSString* cachePath = [NSString stringWithFormat:@"%@%@", libraryDirectory, cacheLocation];
	
	data = [NSData dataWithContentsOfFile:cachePath];
	
    if(data) {
        NSURLResponse* response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:@"" expectedContentLength:-1 textEncodingName:nil];
        [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocol:self didLoadData:data];
        [client URLProtocolDidFinishLoading:self];
        [response release];
    }
	else {
        int resultCode = NSURLErrorResourceUnavailable;
        [client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:resultCode userInfo:nil]];
    }
}

- (void)stopLoading
{
}

@end
