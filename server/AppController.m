//
//  AppController.m
//  HypercubeServer
//
//  Created by Danny Espinoza on 12/10/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "AppController.h"


@implementation AppController

- (void)awakeFromNib
{
	[NSApp setDelegate:self];
	
    NSConnection*serverConnection = [NSConnection defaultConnection];
    [serverConnection setRootObject:self];
    [serverConnection registerName:@"HypercubeServer"];

}

- (NSString *)request:(NSString *)request
{
    id reply = [NSString stringWithFormat:@"server has received request: %@", request];
    NSLog(@"%@", reply);
	
    return reply;
}

@end
