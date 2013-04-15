//
//  BrowserView.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/19/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "BrowserView.h"


@implementation BrowserView

- (void)awakeFromNib
{
	mouseIn = NO;
	switchProcess = NO;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (void)mouseEntered:(NSEvent*)theEvent
{
	switchProcess = NO;

	if([[self window] level] == NSFloatingWindowLevel) {
		GetFrontProcess(&lastFrontProcess);
		
		ProcessSerialNumber currentProcess;
		GetCurrentProcess(&currentProcess);
		
		Boolean result;
		SameProcess(&lastFrontProcess, &currentProcess, &result);
		if(result == false) {
			[NSApp activateIgnoringOtherApps:YES];
			switchProcess = YES;
		}
	}
	
	[[self window] makeKeyWindow];
	
	mouseIn = YES;
}
	
- (void)mouseExited:(NSEvent*)theEvent
{
	mouseIn = NO;

	if(switchProcess) {		
		ProcessSerialNumber frontProcess;
		GetFrontProcess(&frontProcess);
		
		ProcessSerialNumber currentProcess;
		GetCurrentProcess(&currentProcess);
		
		Boolean result;
		SameProcess(&frontProcess, &currentProcess, &result);
		
		if(result)
			SetFrontProcessWithOptions(&lastFrontProcess, kSetFrontProcessFrontWindowOnly);
	}
}

@end
