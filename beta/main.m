//
//  main.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/21/07.
//  Copyright Mesa Dynamics, LLC 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>

SInt32 gMacVersion = 0;
BOOL gUndoIsActive = NO;
BOOL gPrivateWebKit = NO;

int main(int argc, char *argv[])
{
	Gestalt(gestaltSystemVersion, &gMacVersion);
    return NSApplicationMain(argc,  (const char **) argv);
}
