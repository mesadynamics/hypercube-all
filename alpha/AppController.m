//
//  AppController.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 2/21/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "AppController.h"
#import "WidgetController.h"

#include <sys/time.h>
#include <sys/resource.h>


@implementation AppController

- (void)awakeFromNib 
{
	[NSApp setDelegate:self];

	[theAbout setLevel:NSStatusWindowLevel+1];
 	[theAbout center];
	
	[thePreferences setLevel:NSStatusWindowLevel+1];
 	[thePreferences center];
	
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:mainMenu];
	[statusItem setEnabled:YES];

	NSImage* image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"]];
	[statusItem setImage:image];
	[image release];
	
	pasteCount = [[NSPasteboard generalPasteboard] changeCount];
	pasteBuffer = nil;
	pasteTimer = nil;

	NSScreen* screen = [NSScreen mainScreen];	
	float x = [screen visibleFrame].size.width - 400.0;
	float y = [screen visibleFrame].origin.y + [screen visibleFrame].size.height - 220.0;
	[creator setFrameOrigin:NSMakePoint(x, y)];
	//[creator setAlphaValue:.95];
	//[creator setLevel:NSFloatingWindowLevel+1];
	
	hypercubeVersion = 0;
	prefLaunchHidden = NO;
	prefNoClickImport = NO;
	prefReduceCPU = YES;
	prefUISound = YES;
	prefCreateSound = YES;
	
	createSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForSoundResource:@"Create"] byReference:YES];
}

- (void)handleIdle:(id)sender
{
	NSPasteboard* pb = [NSPasteboard generalPasteboard];
	int count = [pb changeCount];
	
	if(count > pasteCount) {		
		pasteCount = count;
			
		NSData* pasteData = [pb dataForType:NSStringPboardType];
		if(pasteData && [pasteData length]) {
			NSString* pasteString = [[NSString alloc] initWithData:pasteData encoding:NSUTF8StringEncoding];			
			if(pasteString && (pasteBuffer == nil ||  [pasteString isEqualToString:pasteBuffer] == NO)) {
				if((prefNoClickImport == YES && [creator isVisible] == NO) || ([NSApp isActive] && [widgetManager isInGallery])) {
					if(prefCreateSound)
						[createSound play];

					[widgetManager installWidgetWithCode:pasteString create:YES force:NO];
				}
				else if([widgetManager testWidgetWithCode:pasteString]) 
					[code setStringValue:pasteString];
				
				[pasteBuffer release];
				pasteBuffer = pasteString;
			}
		}
	}
}

- (void)readPrefs
{
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	
	if([ud objectForKey:@"HypercubeVersion"])
		hypercubeVersion = [ud integerForKey:@"HypercubeVersion"];
		
	if([ud objectForKey:@"PrefLaunchHidden"])
		prefLaunchHidden = [ud boolForKey:@"PrefLaunchHidden"];
		
	if([ud objectForKey:@"PrefNoClickImport"])
		prefNoClickImport = [ud boolForKey:@"PrefNoClickImport"];
		
	if([ud objectForKey:@"PrefReduceCPU"])
		prefReduceCPU = [ud boolForKey:@"PrefReduceCPU"];
		
	if([ud objectForKey:@"PrefUISound"])
		prefUISound = [ud boolForKey:@"PrefUISound"];
		
	if([ud objectForKey:@"prefCreateSound"])
		prefCreateSound = [ud boolForKey:@"PrefCreateSound"];
}

- (void)writePrefs
{
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	
	hypercubeVersion = 10;
	[ud setInteger:hypercubeVersion forKey:@"HypercubeVersion"];
	
	[ud setBool:prefLaunchHidden forKey:@"PrefLaunchHidden"];
	[ud setBool:prefNoClickImport forKey:@"PrefNoClickImport"];
	[ud setBool:prefReduceCPU forKey:@"PrefReduceCPU"];
	[ud setBool:prefUISound forKey:@"PrefUISound"];
	[ud setBool:prefCreateSound forKey:@"PrefCreateSound"];
	
	[ud synchronize];
}

- (BOOL)prefUISound
{
	return prefUISound;
}

// self delegate
- (IBAction)handleHypercube:(id)sender
{
	[widgetManager openCube];
}

- (IBAction)handleGallery:(id)sender
{
	[widgetManager openGallery:sender];
}

- (IBAction)handleCreateWidget:(id)sender
{
	if([widgetManager installWidgetWithCode:[code stringValue] create:YES force:YES])
		[code setStringValue:@""];
}

- (IBAction)handleGetWidgets:(id)sender
{
	[widgetManager openGallery:sender];
}

- (IBAction)handleHide:(id)sender
{
	[widgetManager hideWidgets];
}

- (IBAction)handleShow:(id)sender
{
	[widgetManager showWidgets:NO];
}

- (IBAction)handleShowAll:(id)sender
{
	[widgetManager showWidgets:YES];
}

- (IBAction)handleAbout:(id)sender
{
	[theAbout display];
	[theAbout makeKeyAndOrderFront:sender];	
}

- (IBAction)handleUpdate:(id)sender
{
}

- (IBAction)handleBeta:(id)sender
{
}

- (IBAction)handleOnline:(id)sender
{
}

- (IBAction)handleContact:(id)sender
{
}

// NSMenuValidation protocol
/*- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	int tag = [item tag];
	
	switch(tag) {
	}
	
	return NO;
}*/

// NSApplication delegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{	
	[self readPrefs];
	
	if(prefReduceCPU)
		setpriority(PRIO_PROCESS, 0, 20);

	NSString* cubeDomain = @"_Cube1";

	BOOL newLibrary = NO;
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	if([fm fileExistsAtPath:libraryDirectory] == NO) {
		[fm createDirectoryAtPath:libraryDirectory attributes:nil];
		newLibrary = YES;
	}
	
	NSString* directory = [NSString stringWithFormat:@"%@/_Desktop.cube", libraryDirectory];
	if([fm fileExistsAtPath:directory] == NO)
		[fm createDirectoryAtPath:directory attributes:nil];
				
	if(newLibrary) {
		directory = [NSString stringWithFormat:@"%@/_Cube1.cube", libraryDirectory];
		if([fm fileExistsAtPath:directory] == NO)
			[fm createDirectoryAtPath:directory attributes:nil];
			
		directory = [NSString stringWithFormat:@"%@/_Cube2.cube", libraryDirectory];
		if([fm fileExistsAtPath:directory] == NO)
			[fm createDirectoryAtPath:directory attributes:nil];
			
		directory = [NSString stringWithFormat:@"%@/_Cube3.cube", libraryDirectory];
		if([fm fileExistsAtPath:directory] == NO)
			[fm createDirectoryAtPath:directory attributes:nil];
	}			
	else {
		NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];

		NSString* defaultCube = [ud stringForKey:@"DefaultCube"];
		if(defaultCube)
			cubeDomain = [NSString stringWithString:defaultCube];

		directory = [NSString stringWithFormat:@"%@/%@.cube", libraryDirectory, cubeDomain];
		if([fm fileExistsAtPath:directory] == NO)
			[fm createDirectoryAtPath:directory attributes:nil];
	}

	directory = [NSString stringWithFormat:@"%@/_Globals", libraryDirectory];
	if([fm fileExistsAtPath:directory] == NO)
		[fm createDirectoryAtPath:directory attributes:nil];
		
	//directory = [NSString stringWithFormat:@"%@/_Thumbnails", libraryDirectory];
	//if([fm fileExistsAtPath:directory] == NO)
	//	[fm createDirectoryAtPath:directory attributes:nil];
		
	widgetManager = [[WidgetManager alloc] initWithMenu:widgetMenu inCube:cubeDomain];
	[mainMenu setDelegate:(id)widgetManager];
	
	BOOL loadNetWidgets = NO;
	
	NSString* path = [NSString stringWithFormat:@"%@/WidgetLibrary.plist", libraryDirectory];
	if([fm fileExistsAtPath:path])
		[widgetManager readFromPath:path andCreate:(prefLaunchHidden == YES ? NO : YES)];
	else
		loadNetWidgets = YES;

	if(hypercubeVersion < 10) {
		[widgetManager openCube];		
		[widgetManager openGallery:nil];
	}
	
	if(loadNetWidgets)
		[widgetManager readFromNet];
	
	[widgetManager loadLibrary];

	pasteTimer = [NSTimer
		scheduledTimerWithTimeInterval:(double) 0.25
		target:self
		selector:@selector(handleIdle:)
		userInfo:nil
		repeats:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self writePrefs];

	[mainMenu setDelegate:nil];
	[statusItem release];
	
	[pasteTimer invalidate];
	[pasteBuffer release];
	[createSound release];
	[widgetManager release];
	
	NSString* path = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube/WidgetLibrary.plist", NSHomeDirectory()];
	[widgetManager writeToPath:path];

	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	[ud synchronize];

	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	NSString* directory = [NSString stringWithFormat:@"%@/_DashboardTemp", libraryDirectory];
	if([fm fileExistsAtPath:directory])
		[fm removeFileAtPath:directory handler:nil];
}

@end
