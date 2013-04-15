//
//  CubeButton.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 6/14/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "CubeButton.h"
#import "AppController.h"

@implementation CubeButton

- (id)initWithFrame:(NSRect)frameRect imageNamed:(NSString*)image inWindow:(NSWindow*)window
{
	if(self = [super initWithFrame:frameRect]) {
		[[window contentView] addSubview:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseExited:) name:NSWindowDidResignKeyNotification object:window];

		[self setFocusRingType:NSFocusRingTypeNone];
		[self setBezelStyle:NSRoundedBezelStyle];
		[self setButtonType:NSMomentaryChangeButton];
		[self setBordered:NO];
		[self setTitle:@""];
		[self setImagePosition:NSImageBelow];

		[self setImage:[NSImage imageNamed:image]];
		[self setAlternateImage:[NSImage imageNamed:[NSString stringWithFormat:@"%@Down", image]]];
		
		NSSound* click = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForSoundResource:@"Click"] byReference:YES];
		[self setSound:click];

		enterSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForSoundResource:@"Enter"] byReference:YES];
		
		overImage = [NSImage imageNamed:[NSString stringWithFormat:@"%@Over", image]];
		[overImage retain];
		
		tracker = 0;
		mouseIn = NO;
		didFlip = NO;
	}
	
	return self; 
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	if(tracker)
		[[[self window] contentView] removeTrackingRect:tracker];

	[enterSound release];
	[overImage release];

	[super dealloc];
}

- (void)resetCursorRects
{
	NSRect frame = [self frame];
	if(tracker)
		[[[self window] contentView] removeTrackingRect:tracker];

	if([self isHidden] == NO) {
		tracker = [[[self window] contentView] addTrackingRect:frame owner:self userData:nil assumeInside:NO];

		frame.origin.x = 0.0;
		frame.origin.y = 0.0;
		[self addCursorRect:frame cursor:[NSCursor pointingHandCursor]];
	}
}

- (void)mouseEntered:(NSEvent*)theEvent
{
	if(mouseIn == NO && [self isEnabled]) {
		AppController* app = (AppController*) [NSApp delegate];
		if([app prefUISound])
			[enterSound play];
		
		NSImage* image = [self image];
		[image retain];
		[self setImage:overImage];
		[overImage release];
		overImage = image;
		[self setNeedsDisplay:YES];

		mouseIn = YES;
	}
}

- (void)mouseExited:(NSEvent*)theEvent
{
	if(mouseIn == YES) {
		NSImage* image = [self image];
		[image retain];
		[self setImage:overImage];
		[overImage release];
		overImage = image;
		[self setNeedsDisplay:YES];

		mouseIn = NO;
	}
}

- (void)setHidden:(BOOL)flag
{
	if(flag) {
		if(mouseIn == YES) {
			NSImage* image = [self image];
			[image retain];
			[self setImage:overImage];
			[overImage release];
			overImage = image;
			[self setNeedsDisplay:YES];

			mouseIn = NO;
		}
	}

	[super setHidden:flag];
}

- (void)setEnabled:(BOOL)flag
{
	if(flag == NO) {
		if(mouseIn == YES) {
			NSImage* image = [self image];
			[image retain];
			[self setImage:overImage];
			[overImage release];
			overImage = image;
			[self setNeedsDisplay:YES];

			mouseIn = NO;
		}
	}

	if(flag == NO) {
		if(didFlip == NO) {
			NSImage* image = [self image];
			[image retain];
			[self setImage:[self alternateImage]];
			[self setAlternateImage:image];
			[image release];
			didFlip = YES;
		}
	}
	else {
		if(didFlip) {
			NSImage* image = [self image];
			[image retain];
			[self setImage:[self alternateImage]];
			[self setAlternateImage:image];
			[image release];
			didFlip = NO;
		}
	}
	
	[super setEnabled:flag];
}

@end
