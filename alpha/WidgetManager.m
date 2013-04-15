//
//  WidgetManager.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 3/13/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "WidgetManager.h"
#import "GalleryWindow.h"
#import "GalleryView.h"
#import "GalleryCell.h"
#import "CubeButton.h"
#import "AppController.h"
#import "NSImage+ScaleReflect.h"

#import <SystemConfiguration/SCNetwork.h>

enum {
	galleryLibrary = 10,
	galleryCubes = 20,
	galleryProviders = 30,
	galleryBrowser = 40,
	galleryHelp = 50,
	galleryWelcome = 60
};

enum {
	menuHide = 1,
	menuShow = 2,
	menuWidget = 100
};

enum {
	presetAll = 1000,
	presetLibraries = 1001,
	presetGames = 1002,
	presetVideo = 1003,
	presetPhotos = 1004,
	presetMusic = 1005,
	presetOther = 1006
};

@implementation WidgetManager

+ (NSDictionary*)widgetWithCode:(id)code title:(id)title image:(id)image
{
	NSArray* objects = nil;
	
	if(image)
		objects = [NSArray arrayWithObjects:code, title, [[image TIFFRepresentation] copy], nil];
	else
		objects = [NSArray arrayWithObjects:code, title, [[NSData alloc] init], nil];
	
	NSArray* keys = [NSArray arrayWithObjects:@"code", @"title", @"image", nil]; 
	
	return [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
}

+ (int)markerFromCode:(NSString*)code // hash
{	
  	int base1 = 0;
	int base2 = 0;
	int base3 = 0;
	int base4 = 0;
			
	char* element = (char*) [code UTF8String];
		
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

+ (NSString*)domainFromCode:(NSString*)code
{
	NSString* domain = nil;

	NSRange start = [code rangeOfString:@"http://"];
	
	while(start.location != NSNotFound) {
		start.location += 7;
		
		NSRange end = [[code substringFromIndex:start.location] rangeOfString:@".com"];
		if(end.location == NSNotFound)
			end = [[code substringFromIndex:start.location] rangeOfString:@".net"];
		if(end.location == NSNotFound)
			end = [[code substringFromIndex:start.location] rangeOfString:@".org"];
			
		if(end.location == NSNotFound) {
			NSRange slashEnd = [[code substringFromIndex:start.location] rangeOfString:@"/"];
			NSRange ampEnd = [[code substringFromIndex:start.location] rangeOfString:@"&"];
			NSRange equalEnd = [[code substringFromIndex:start.location] rangeOfString:@"="];
			NSRange closeEnd = [[code substringFromIndex:start.location] rangeOfString:@">"];
			NSRange dquoEnd = [[code substringFromIndex:start.location] rangeOfString:@"\""];
			NSRange squoEnd = [[code substringFromIndex:start.location] rangeOfString:@"'"];
			
			int min = slashEnd.location;
			if(min != NSNotFound) {
				if(ampEnd.location != NSNotFound && ampEnd.location < min)
					min = ampEnd.location;
				if(equalEnd.location != NSNotFound && equalEnd.location < min)
					min = equalEnd.location;
				if(closeEnd.location != NSNotFound && closeEnd.location < min)
					min = closeEnd.location;
				if(dquoEnd.location != NSNotFound && dquoEnd.location < min)
					min = dquoEnd.location;
				if(squoEnd.location != NSNotFound && squoEnd.location < min)
					min = squoEnd.location;
			
				end.location = min;
			}
		}
		else
			end.location += 4;
		
		if(end.location != NSNotFound) {
			start.length = end.location;
			
			NSString* extracted = [code substringWithRange:start];
			if(extracted && [extracted length]) {
				NSRange ignore1 = [extracted rangeOfString:@"macromedia.com"];
				NSRange ignore2 = [extracted rangeOfString:@"adobe.com"];
				NSRange ignore3 = [extracted rangeOfString:@"gmodules.com"];
				
				if(ignore1.location == NSNotFound && ignore2.location == NSNotFound && ignore3.location == NSNotFound) {
					if(domain == nil || ([domain hasPrefix:@"www."] == NO && [extracted hasPrefix:@"www."] == YES))
						domain = extracted;
				}
			}
		}
		
		start.location += start.length;
		start.length = [code length] - start.location;
		start = [code rangeOfString:@"http://" options:0 range:start];
	}
		
	if(domain)
		return [[[NSString alloc] initWithString:domain] autorelease];
		
	return nil;
}

+ (NSString*)identifierFromCode:(NSString*)code
{
	NSString* domain = [WidgetManager domainFromCode:code];
	int marker = [WidgetManager markerFromCode:code];
	
	NSString* identifier = nil;
	
	int hash = [code hash];

	NSString* v0 = [NSString stringWithFormat:@"%8x", marker];
	NSString* v1 = [NSString stringWithFormat:@"%8x", hash];
	
	NSString* s0 = [NSString stringWithFormat:@"%@%@", v0, v1];
	NSString* s1 = [s0 substringWithRange:NSMakeRange(0, 4)];
	NSString* s2 = [s0 substringWithRange:NSMakeRange(4, 4)];
	NSString* s3 = [s0 substringWithRange:NSMakeRange(8, 4)];
	NSString* s4 = [s0 substringWithRange:NSMakeRange(12, 4)];			
	NSString* sN = [NSString stringWithFormat:@"%@-%@-%@-%@", s1, s2, s3, s4];
	
	NSMutableString* temp = [sN mutableCopy];
	[temp replaceOccurrencesOfString:@" " withString:@"0" options:0 range:NSMakeRange(0, [temp length])];
	NSString* serial = [temp uppercaseString];
	[temp release];
	
	if(domain)
		identifier = [[[NSString alloc] initWithFormat:@"%@-%@", domain, serial] autorelease];
	else
		identifier = [[[NSString alloc] initWithFormat:@"localhost-%@", serial] autorelease];
														
	return identifier;
}

- (id)initWithMenu:(NSMenu*)menu inCube:(NSString*)domain
{
	[super init];
	
	if(self) {
		cubeDomain = [[NSString stringWithString:domain] retain];
		switchSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForSoundResource:@"Switch"] byReference:YES];
		clickSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForSoundResource:@"Click"] byReference:YES];
		welcomeSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForSoundResource:@"Welcome"] byReference:YES];
		
		providers = nil;
		coders = nil;
		tags = nil;
		
		usingDefaultLibrary = NO;
		updateDay = 0;
		updateHash = 0;
		isUpdating = NO;
		syndicate = YES;
		preset = presetAll;
		
		providersFeatured = [[NSMutableArray alloc] initWithCapacity:0];
		providersHidden = [[NSMutableArray alloc] initWithCapacity:0];
		providersSpoofed = [[NSMutableArray alloc] initWithCapacity:0];

		widgets = [[NSMutableDictionary alloc] initWithCapacity:0];
		instances = [[NSMutableDictionary alloc] initWithCapacity:0];
		menus = [[NSMutableDictionary alloc] initWithCapacity:0];
		desktop = [[NSMutableArray alloc] initWithCapacity:0];
		hypercube = [[NSMutableArray alloc] initWithCapacity:0];
		hidden = nil;
		
		images = [[NSMutableDictionary alloc] initWithCapacity:0];
		
		isInHypercube = NO;
		isInGallery = NO;
		
		widgetMenu = [menu retain];
		
		createTitle = nil;
		createTitleCustom = NO;
		createThumbnail = nil;
		createThumbnailCustom = NO;

		cubeTitle = nil;
		cube = nil;
		cubeWindows = nil;
		gallery = nil;
		galleryWindows = nil;
		
		imageSessionCount = 0;
		imageSessionTimer = nil;
		imageSessions = [[NSMutableDictionary alloc] initWithCapacity:0];
		
		sessionData = [[NSMutableDictionary alloc] initWithCapacity:0];
		sessionID = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	
	return self;
}

- (void)dealloc
{
	[[sessionID allValues] makeObjectsPerformSelector:@selector(cancel)];
	[sessionID release];
	[sessionData release];
	
	[imageSessions release];
	[imageSessionTimer invalidate];
	
	[widgetMenu release];
		
	[images release];

	[hidden release];
	[hypercube release];
	[desktop release];
	
	[menus release];	
	[instances release];
	[widgets release];
	
	[providersSpoofed release];
	[providersHidden release];
	[providersFeatured release];
	
	[tags release];
	[coders release];
	[providers release];
	
	[welcomeSound release];
	[switchSound release];
	[clickSound release];
	[cubeDomain release];
		
	[super dealloc];
}

- (WidgetController*)createWidgetController
{
	WidgetController* controller = [[WidgetController alloc] init];
	[NSBundle loadNibNamed:@"Widget" owner:controller];

	return controller;
}

- (BrowserController*)createBrowserController
{
	BrowserController* controller = [[BrowserController alloc] init];
	[NSBundle loadNibNamed:@"Browser" owner:controller];
	
	return controller;
}

- (BOOL)testWidgetWithCode:(NSString*)code
{
	NSString* trimmedCode = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSMutableString* cleanedCode = [trimmedCode mutableCopy];
	[cleanedCode replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [cleanedCode length])];

	if([cleanedCode hasPrefix:@"<"] == NO || [cleanedCode hasSuffix:@">"] == NO)
		return NO;
		
	BOOL result = [self verifyCode:cleanedCode];
	[cleanedCode release];
	
	return result;
}

- (BOOL)installWidgetWithCode:(NSString*)code create:(BOOL)create force:(BOOL)force
{
	BOOL didCreate = NO;
	
	NSString* trimmedCode = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSMutableString* cleanedCode = [trimmedCode mutableCopy];
	[cleanedCode replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [cleanedCode length])];

	if(force) {
		if([cleanedCode hasPrefix:@"<"] == NO || [cleanedCode hasSuffix:@">"] == NO) {
			NSBeep();
			force = NO;
		}	
	}
		
	if([self verifyCode:cleanedCode] == YES || force) {
		NSString* identifier = [WidgetManager identifierFromCode:cleanedCode];
		if([self addWidget:cleanedCode title:nil image:nil identifier:identifier]) {
			if(create) {
				WidgetController* controller = nil;
				
				if(isInHypercube) {
					controller = [self createWidget:cleanedCode identifier:identifier domain:cubeDomain];
					[controller setHypercube:YES];
				}
				else
					controller = [self createWidget:cleanedCode identifier:identifier domain:@"_Desktop"];
					
				if(controller) {
					if(isInGallery && galleryMode != galleryWelcome) {
						[self setupGallery:galleryProviders];
							
						[controller setGallery:YES];
					}
						
					[controller resetOptionLevel];

					didCreate = YES;
				}
			}
		}		
	}
	
	[cleanedCode release];

	return didCreate;
}

- (BOOL)verifyCode:(NSString*)code
{
	if(createTitleCustom) {
		[createTitle release];
		createTitleCustom = NO;
	}
	
	createTitle = nil;
	
	if(createThumbnailCustom) {
		[createThumbnail release];
		createThumbnailCustom = NO;
	}
	
	createThumbnail = nil;
		
	// custom support for Google	
	if([self matchCode:code fromDomain:@"gmodules.com" andPrefix:@"<script " withTitle:@"Google"]) {
		NSRange start = [code rangeOfString:@"&title="];

		if(start.location != NSNotFound) {
			start.location += 7;
			NSRange end = [[code substringFromIndex:start.location] rangeOfString:@"&"];
			start.length = end.location;
			
			NSString* extracted = [code substringWithRange:start];
			if(extracted && [extracted length]) {
				NSMutableString* mExtracted = [extracted mutableCopy];
				[mExtracted replaceOccurrencesOfString:@"+" withString:@" " options:0 range:NSMakeRange(0, [mExtracted length])];

				createTitle = [[mExtracted stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] retain];
				createTitleCustom = YES;
				
				[mExtracted release];
			}
		}

		start = [code rangeOfString:@"url="];
		if(start.location != NSNotFound) {
			start.location += 4;
			NSRange end = [[code substringFromIndex:start.location] rangeOfString:@"&"];
			start.length = end.location;
			
			NSString* extracted = [code substringWithRange:start];
			if(extracted && [extracted length]) {
				createThumbnail = [[extracted stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] retain];
				createThumbnailCustom = YES;
			}
		}
	
		return YES;
	}

	if([code hasPrefix:@"<iphone src=\""] && [code hasSuffix:@"\" />"]) {
		createTitle = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"IPhoneApp", @"")];
		createTitleCustom = YES;

		return YES;
	}
	
	if(coders) {
		NSEnumerator* enumerator = [coders keyEnumerator];
		NSString* key;
	
		while((key = [enumerator nextObject])) {
			NSString* domain = [coders objectForKey:key];
			NSRange match = [code rangeOfString:domain];
			if(match.location != NSNotFound) {
				NSString* title = [providers objectForKey:key];
				if(title) {
					createTitle = [[NSString alloc] initWithFormat:@"%@ %@", title, NSLocalizedString(@"Widget", @"")];
					createTitleCustom = YES;
				}
									
				return YES;
			}
		}
	}
			
	return NO;
}

- (BOOL)matchCode:(NSString*)code fromDomain:(NSString*)domain andPrefix:(NSString*)prefix withTitle:(NSString*)title
{
	NSRange match = [code rangeOfString:domain];
	if(match.location != NSNotFound) {
		if(prefix == nil || [code hasPrefix:prefix]) {
			createTitle = title;
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)addWidget:(NSString*)code title:(NSString*)title image:(NSImage*)image identifier:(NSString*)identifier
{
	if(code == nil)
		return NO;
		
	NSString* fullIdentifier = identifier;
	if(fullIdentifier == nil)
		fullIdentifier = [WidgetManager identifierFromCode:code];
		
	NSMutableDictionary* widget = [widgets objectForKey:fullIdentifier];
	if(widget) {
		WidgetController* controller = [instances objectForKey:fullIdentifier];
		if(controller) {
		}
		else {
			NSString* code = [widget objectForKey:@"code"];
			[self createWidget:code identifier:fullIdentifier domain:@"_Desktop"];
		}
		
		return NO;
	}
		
	NSString* fullTitle = title;
	
	if(fullTitle == nil) {
		if(createTitleCustom)
			fullTitle = [NSString stringWithString:createTitle];
		else {
			if(createTitle == nil)
				fullTitle = [NSString stringWithString:NSLocalizedString(@"UnknownWidget", @"")];
			else
				fullTitle = [NSString stringWithFormat:@"%@ %@", createTitle, NSLocalizedString(@"Widget", @"")];
		}
	}
	
	NSImage* fullImage = image;
	if(fullImage == nil) {
		if(createThumbnailCustom) {
			NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:createThumbnail]
				cachePolicy:NSURLRequestUseProtocolCachePolicy
				timeoutInterval:20.0];
				
			NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
			[sessionID setObject:[NSString stringWithFormat:@"%@:XML.GGL", fullIdentifier] forKey:[connection description]];
		}
	}
	
	widget = [[WidgetManager widgetWithCode:code title:fullTitle image:fullImage] mutableCopy];
	
	[widgets setObject:widget forKey:fullIdentifier];
	[widget release];
	
	[self addMenuItem:fullIdentifier title:fullTitle image:fullImage];
	
	return YES;
}

- (WidgetController*)createWidget:(NSString*)code identifier:(NSString*)identifier domain:(NSString*)domain
{
	BOOL canConnect = YES;

#if 0
	NSString* netDomain = [WidgetManager domainFromCode:code];
	if(netDomain) {
		SCNetworkConnectionFlags flags;
		if(SCNetworkCheckReachabilityByName([netDomain UTF8String], &flags)) {
			if(!(flags & kSCNetworkFlagsReachable)) {
				canConnect = NO;
			}
		}
	}
#endif

	if(canConnect) {
		WidgetController* controller = [self createWidgetController];
		[controller setWidgetManager:self];
		
		if([domain isEqualToString:@"_Desktop"])
			[self addToDesktop:identifier];
		else
			[self addToHypercube:identifier];
		
		[controller setIdentifier:identifier];
		[controller setDomain:domain];
		[controller readOptions];
		
		[controller loadSnippet:code syndicate:syndicate];
		
		[instances setObject:controller forKey:identifier];

		return controller;
	}
	
	return nil;
}

- (void)loadWidget:(NSString*)identifier
{
	updateHash++;
}

- (void)closeWidget:(NSString*)identifier
{
	WidgetController* controller = [instances objectForKey:identifier];
	if(controller) {
		[controller close];
		[controller release];
	}
	
	[instances removeObjectForKey:identifier];
	[desktop removeObject:identifier];
	[hypercube removeObject:identifier];
}

- (void)removeWidget:(NSString*)identifier
{
	[self closeWidget:identifier];
	
	[widgets removeObjectForKey:identifier];
	
	NSMenuItem* menuItem = [menus objectForKey:identifier];
	if(menuItem) {
		[widgetMenu removeItem:menuItem];
		[menus removeObjectForKey:menuItem];
	}

	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	[ud synchronize];

	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	NSArray* prefs = [fm directoryContentsAtPath:libraryDirectory];
	NSEnumerator* enumerator = [prefs objectEnumerator];
	NSString* directory;
		
	while((directory = [enumerator nextObject])) {
		if([directory isEqualToString:@"_Globals"] || [directory hasSuffix:@".cube"]) {
			NSString* widgetOptions = [NSString stringWithFormat:@"%@/%@/%@.plist", libraryDirectory, directory, identifier];
			if([fm fileExistsAtPath:widgetOptions])
				[fm removeFileAtPath:widgetOptions handler:nil];
		}
	}

	if(isInGallery && galleryMode == galleryLibrary)
		[self setupGalleryLibrary];
}

- (void)forgetWidget:(NSString*)identifier inDomain:(NSString*)domain
{
	if([domain isEqualToString:@"_Desktop"])
		[self removeFromDesktop:identifier];
	else
		[self removeFromHypercube:identifier];
		
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	[ud synchronize];

	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	NSString* directory = domain;
	
	if(directory)
		directory = [NSString stringWithFormat:@"%@/%@.cube", libraryDirectory, domain];
	else {
		if(isInHypercube)
			directory = [NSString stringWithFormat:@"%@/%@.cube", libraryDirectory, cubeDomain];
		else
			directory = [NSString stringWithFormat:@"%@/_Desktop.cube", libraryDirectory];
	}
		
	if([fm fileExistsAtPath:directory] == NO)
		[fm createDirectoryAtPath:directory attributes:nil];
	else {
		NSString* widgetOptions = [NSString stringWithFormat:@"%@/%@.plist", directory, identifier];

		if([fm fileExistsAtPath:widgetOptions])
			[fm removeFileAtPath:widgetOptions handler:nil];
	}
}

- (NSString*)infoForWidget:(NSString*)identifier key:(NSString*)key
{
	NSMutableDictionary* widget = [widgets objectForKey:identifier];
	return [widget objectForKey:key];
}

- (void)setInfoForWidget:(NSString*)identifier key:(NSString*)key object:(id)object
{
	NSMutableDictionary* widget = [widgets objectForKey:identifier];
	if(widget) {
		if([key isEqualToString:@"image"]) {
			[widget setObject:[[object TIFFRepresentation] copy] forKey:key];

			NSMenuItem* menuItem = [menus objectForKey:identifier];
			if(menuItem)
				[menuItem setImage:[NSImage scaleImage:object toSize:NSMakeSize(16.0, 16.0)]];
		}
		else {
			[widget setObject:object forKey:key];
		
			if([key isEqualToString:@"title"]) {
				NSMenuItem* menuItem = [menus objectForKey:identifier];
				if(menuItem) {
					NSImage* menuImage = [menuItem image];
					[menuImage retain];
					
					[widgetMenu removeItem:menuItem];
					[menus removeObjectForKey:menuItem];
					
					NSString* menuTitle = [object copy];
					[self addMenuItem:identifier title:menuTitle image:menuImage];
					[menuTitle release];
					[menuImage release];
					
					if(isInGallery && galleryMode == galleryLibrary)
						[self setupGalleryLibrary];
				}
			}
		}
	}
}

- (void)addMenuItem:(NSString*)identifier title:(NSString*)title image:(NSImage*)image
{
	NSMenuItem* menuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:title action:@selector(menuItemAction:) keyEquivalent:@""];

	if(image)
		[menuItem setImage:[NSImage scaleImage:image toSize:NSMakeSize(16.0, 16.0)]];
	else
		[menuItem setImage:[NSImage imageNamed:@"SmallGear"]];
	
	[menuItem setTag:menuWidget];
	[menuItem setTarget:self];
	[menuItem setEnabled:YES];	
	
	int insertPoint = 0;
	
	NSEnumerator* enumerator = [[widgetMenu itemArray] objectEnumerator];
	NSMenuItem* item;
	
	while((item = [enumerator nextObject])) {
		if([item tag] == menuWidget) {
			if([title caseInsensitiveCompare:[item title]] == NSOrderedAscending)
				break;
				
			insertPoint++;
		}
	}
	
	[widgetMenu insertItem:menuItem atIndex:insertPoint];
	[menuItem release];
	
	[menus setObject:menuItem forKey:identifier];	
}

- (void)menuItemAction:(id)sender
{
	NSMenuItem* item = sender;
	
	if([item tag] == menuWidget) {
		NSArray* array = [menus allKeysForObject:item];
		if(array == nil || [array count] == 0)
			array = [menus allKeysForObject:[item representedObject]];
			
		NSString* identifier = [array objectAtIndex:0];
		
		WidgetController* controller = [instances objectForKey:identifier];
		if(controller) {
			if([[controller window] isVisible]) {
#if defined(Obsolete)
				UInt32 modifiers = GetCurrentKeyModifiers();
				if((modifiers & (1<<9)))
					[controller focus];
				else {
					[self removeFromDesktop:identifier];
					
					[controller hide];
					[controller writeOptions];
					
					return;
				}
#endif
			}
			else {
				if([controller getHypercube]) {
					[controller setDomain:@"_Desktop"];
					[controller readOptions];
					
					[controller setHypercube:NO];
					[controller resetOptionLevel];
				}
				else
					[controller readOptions];
				
				[controller show];
				[controller focus];
			}
		
			[self addToDesktop:identifier];
		}
		else {
			NSMutableDictionary* widget = [widgets objectForKey:identifier];
			if(widget) {
				NSString* code = [widget objectForKey:@"code"];
				WidgetController* controller = [self createWidget:code identifier:identifier domain:@"_Desktop"];
				[controller focus];
			}
		}
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{	
	if([item tag] == menuWidget) {
		NSArray* array = [menus allKeysForObject:item];
		if(array == nil || [array count] == 0)
			array = [menus allKeysForObject:[item representedObject]];
			
		NSString* identifier = [array objectAtIndex:0];
		
		WidgetController* controller = [instances objectForKey:identifier];
		if(controller) {
			if([controller isReady] == NO)
				[item setState:NSMixedState];
			else if([[controller window] isVisible])
				[item setState:NSOnState];
		}
		else
			[item setState:NSOffState];
	}
/*
	else switch([item tag]) {
		case menuHide:
		{
			NSLog(@"%d", [item tag]);
			NSEnumerator* enumerator = [[instances allValues] objectEnumerator];
			WidgetController* controller;
				
			while((controller = [enumerator nextObject])) {
				if([controller isOrWillBeVisible])
					return YES;
			}
	
			return NO;
		}
			
		case menuShow:
			return ([hidden count] > 0 ? YES : NO);
	}
*/	
	return YES;
}

- (void)writeToPath:(NSString*)path
{
	[self writeDomain:@"_Desktop"];

	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSString* defaultCube = [NSString stringWithString:cubeDomain];
	[ud setObject:defaultCube forKey:@"DefaultCube"];
	if(hidden) {
		NSArray* hiddenWidgets = [NSArray arrayWithArray:hidden];
		[ud setObject:hiddenWidgets forKey:@"HiddenWidgets"];
	}
	if(updateHash) {
		int calculatedHash = updateHash * 1423;
		int verifier = 983 + (calculatedHash % 223);
		calculatedHash += verifier;
		
		[ud setInteger:calculatedHash forKey:@"LibraryImageHash"];
		[ud setInteger:verifier forKey:@"LibraryCodeHash"];
	}
	else {
		[ud removeObjectForKey:@"LibraryImageHash"];
		[ud removeObjectForKey:@"LibraryCodeHash"];
	}
	[ud synchronize];

	NSString* error = nil;
	 
	if([widgets count]) { 
		NSData* data = [NSPropertyListSerialization dataFromPropertyList:widgets
			format:NSPropertyListBinaryFormat_v1_0
			errorDescription:&error];

		if(data)
			[data writeToFile:path atomically:YES];
		else {
			NSLog(@"%@", error);
			[error release];
		}
	}
	else {
		NSFileManager* fm = [NSFileManager defaultManager];
		[fm removeFileAtPath:path handler:nil];
	}
}

- (void)readFromPath:(NSString*)path andCreate:(BOOL)create
{
	NSPropertyListFormat format;
	NSString* error = nil;

	NSData* data = [NSData dataWithContentsOfFile:path];
	id plist = [NSPropertyListSerialization propertyListFromData:data
		mutabilityOption:NSPropertyListMutableContainersAndLeaves
		format:&format
		errorDescription:&error];

	if(plist) {
		[widgets release];
		widgets = [NSMutableDictionary dictionaryWithCapacity:[plist count]];
		[widgets addEntriesFromDictionary:plist];
		[widgets retain];
		
		NSEnumerator* enumerator = [[widgets allValues] objectEnumerator];
		NSMutableDictionary* widget;
		
		while((widget = [enumerator nextObject])) {
			NSString* code = [widget objectForKey:@"code"];
			NSString* title = [widget objectForKey:@"title"];
			NSData* imageData = [widget objectForKey:@"image"];
			
			NSImage* image = [[NSImage alloc] initWithData:imageData];
			
			NSString* identifier = [WidgetManager identifierFromCode:code];
			[self addMenuItem:identifier title:title image:image];
			
			[image release];
		}
	}
	else {
		NSLog(@"%@", error);
		[error release];
	}

	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSString* defaultCube = [ud objectForKey:@"DefaultCube"];
	if(defaultCube) {
		[cubeDomain release];
		cubeDomain = [[NSString stringWithString:defaultCube] retain];
	}
	NSArray* hiddenWidgets = [ud objectForKey:@"HiddenWidgets"];
	if(hiddenWidgets) {
		[hidden release];
		hidden = [[NSArray arrayWithArray:hiddenWidgets] retain];
	}
	updateDay = [ud integerForKey:@"LibraryUpdate"];
	
	int provisionalHash = [ud integerForKey:@"LibraryImageHash"];
	int verifier = [ud integerForKey:@"LibraryCodeHash"];
	if(provisionalHash && verifier) {
		provisionalHash -= verifier;
		verifier -= 983;
		if(provisionalHash && (provisionalHash % 1423) == 0 && (provisionalHash % 223) == verifier) {
			updateHash = provisionalHash / 1423;

			//NSLog(@"found valid widget served count: %d", updateHash);
		}
	}
	
	if([ud objectForKey:@"Syndicate"])
		syndicate = [ud boolForKey:@"Syndicate"];
	
	[self readDomain:@"_Desktop"];

	if(desktop && create) {
		NSEnumerator* enumerator = [desktop objectEnumerator];
		NSString* identifier;
		
		while((identifier = [enumerator nextObject])) {
			NSMutableDictionary* widget = [widgets objectForKey:identifier];
			if(widget) {
				NSString* code = [widget objectForKey:@"code"];
				[self createWidget:code identifier:identifier domain:@"_Desktop"];
			}
		}
	}
}

- (void)readFromNet
{
	BOOL canConnect = YES;
			
	SCNetworkConnectionFlags flags;
	if(SCNetworkCheckReachabilityByName("amnestywidgets.com", &flags)) {
		if(!(flags & kSCNetworkFlagsReachable)) {
			canConnect = NO;
		}
	}
	
	NSURLRequestCachePolicy policy = NSURLRequestReloadIgnoringCacheData;
	
	if(canConnect == NO)
		policy = NSURLRequestReturnCacheDataDontLoad;
	  
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.amnestywidgets.com/hypercube/widgets/default.xml"]
		cachePolicy:policy
		timeoutInterval:20.0];

	NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[sessionID setObject:[NSString stringWithFormat:@"DEFAULT:WGT"] forKey:[connection description]];
}

- (void)writeDomain:(NSString*)domain
{
	NSMutableArray* visibleWidgets = [NSMutableArray arrayWithCapacity:0];
	
	NSEnumerator* enumerator = [[instances allValues] objectEnumerator];
	WidgetController* controller;
	
	if([domain isEqualToString:@"_Desktop"]) {
		while((controller = [enumerator nextObject])) {
			if([controller isOrWillBeVisible] && [desktop containsObject:[controller getIdentifier]]) {
				[controller writeOptions];
				[visibleWidgets addObject:[controller getIdentifier]];
			}
		}
	}
	else {
		while((controller = [enumerator nextObject])) {
			if([controller isOrWillBeVisible] && [hypercube containsObject:[controller getIdentifier]]) {
				[controller writeOptions];
				[visibleWidgets addObject:[controller getIdentifier]];
			}
		}
	}

	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];	
	NSMutableDictionary* udEntry = [[NSMutableDictionary alloc] initWithCapacity:0];
	[udEntry setObject:visibleWidgets forKey:@"VisibleWidgets"];
	[ud setPersistentDomain:udEntry forName:[NSString stringWithFormat:@"Amnesty Hypercube/%@.cube/CubeSettings", domain]];
	
	[udEntry release];
	[ud synchronize];
}

- (void)readDomain:(NSString*)domain
{
	BOOL didReadDomain = NO;
	
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSDictionary* udEntry = [ud persistentDomainForName:[NSString stringWithFormat:@"Amnesty Hypercube/%@.cube/CubeSettings", domain]];
	if(udEntry) {
		NSArray* visibleWidgets = [udEntry objectForKey:@"VisibleWidgets"];
		if(visibleWidgets && [visibleWidgets count]) {
			if([domain isEqualToString:@"_Desktop"]) {
				[desktop release];
				desktop = [[NSMutableArray alloc] initWithCapacity:[visibleWidgets count]];
				[desktop addObjectsFromArray:visibleWidgets];
				
				didReadDomain = YES;
			}
			else {
				[hypercube release];
				hypercube = [[NSMutableArray alloc] initWithCapacity:[visibleWidgets count]];
				[hypercube addObjectsFromArray:visibleWidgets];
				
				didReadDomain = YES;
			}
		}
	}
	
	if(didReadDomain == NO) {
		if([domain isEqualToString:@"_Desktop"]) {
			[desktop release];
			desktop = [[NSMutableArray alloc] initWithCapacity:0];
		}
		else {
			[hypercube release];
			hypercube = [[NSMutableArray alloc] initWithCapacity:0];
		}
	}
}

- (void)hideWidgets
{
	[self writeDomain:@"_Desktop"];

	[hidden release];
	hidden = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSEnumerator* enumerator = [[instances allValues] objectEnumerator];
	WidgetController* controller;
		
	while((controller = [enumerator nextObject])) {
		if([controller isOrWillBeVisible]) {
			[hidden addObject:[controller getIdentifier]];
			
			[self removeFromDesktop:[controller getIdentifier]];
			[controller hide];
		}
	}
}

- (void)showWidgets:(BOOL)all
{
	if(all) {
		NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];

		NSEnumerator* enumerator = [[widgetMenu itemArray] objectEnumerator]; 
		NSMenuItem* item;
		while((item = [enumerator nextObject])) {
			 if([item tag] == menuWidget) {
				NSArray* array = [menus allKeysForObject:item];
				NSString* identifier = [array objectAtIndex:0];

				NSDictionary* udEntry = [ud persistentDomainForName:[NSString stringWithFormat:@"Amnesty Hypercube/_Desktop.cube/%@", identifier]];
				if(udEntry || [desktop containsObject:identifier]) {
					WidgetController* controller = [instances objectForKey:identifier];
					if(controller) {
						if([controller getHypercube]) {
							[controller setDomain:@"_Desktop"];
							[controller readOptions];
							
							[controller setHypercube:NO];
							[controller resetOptionLevel];
						}
						else
							[controller readOptions];
						
						[controller show];
					
						[self addToDesktop:identifier];
					}
					else {
						NSMutableDictionary* widget = [widgets objectForKey:identifier];
						if(widget) {
							NSString* code = [widget objectForKey:@"code"];
							[self createWidget:code identifier:identifier domain:@"_Desktop"];
						}
					}
				}
			}
		}	
	}
	else if(hidden) {
		NSEnumerator* enumerator = [hidden objectEnumerator];
		NSString* identifier;
			
		while((identifier = [enumerator nextObject])) {
			WidgetController* controller = [instances objectForKey:identifier];
			if(controller) {
				if([controller getHypercube]) {
					[controller setDomain:@"_Desktop"];
					[controller readOptions];
					
					[controller setHypercube:NO];
					[controller resetOptionLevel];
				}
				else
					[controller readOptions];
				
				[controller show];

				[self addToDesktop:identifier];
			}
			else {
				NSMutableDictionary* widget = [widgets objectForKey:identifier];
				if(widget) {
					NSString* code = [widget objectForKey:@"code"];
					[self createWidget:code identifier:identifier domain:@"_Desktop"];
				}
			}
		}
	}
}

- (BOOL)isInHypercube
{
	return isInHypercube;
}

- (BOOL)isInGallery
{
	return isInGallery;
}

- (void)setPreset:(id)sender
{
	NSButton* button = (NSButton*) sender;
	preset = [button tag];
	
	GalleryController* controller = [gallery windowController];
	[controller setPresetButton:[button tag]];

	[self setupGalleryProviders];
}

- (void)addToDashboard:(NSString*)code identifier:(NSString*)identifier dashboard:(NSString*)dashboardID width:(int)width height:(int)height
{
	if(isInGallery)
		[self closeGallery];
		
	if(isInHypercube)
		[self closeCube];
		
	SInt32 macVersion = 0;
	Gestalt(gestaltSystemVersion, &macVersion);

	{
		int version1 = 0;
		int version2 = 0;	
		NSString* tempBlock1 = [NSString stringWithFormat:@"%@%@", identifier, @"Generator"];
		NSString* tempBlock2 = [NSString stringWithFormat:@"%@%@", @"widgetplugin", identifier];
		const char* tempString1 = [tempBlock1 UTF8String];
		if(tempString1) {
			long len = strlen(tempString1);
			widgetData = (char*) malloc(len+1);
			if(widgetData) {
				memcpy(widgetData, tempString1, len+1);
				version1 = [self getWidgetVersion];
				free(widgetData);
			}
		}
		const char* tempString2 = [tempBlock2 UTF8String];
		if(tempString2) {
			long len = strlen(tempString2);
			widgetData = (char*) malloc(len+1);
			if(widgetData) {
				memcpy(widgetData, tempString2, len+1);
				version2 = [self getWidgetVersion];
				free(widgetData);
			}
		}
		if(version1 == 0 || version2 == 0)
			;
		else {
			NSString* v0 = [NSString stringWithFormat:@"%8x", version1];
			NSString* v1 = [NSString stringWithFormat:@"%8x", version2];
			
			NSString* s0 = [NSString stringWithFormat:@"%@%@", v0, v1];
			NSString* s1 = [s0 substringWithRange:NSMakeRange(0, 4)];
			NSString* s2 = [s0 substringWithRange:NSMakeRange(4, 4)];
			NSString* s3 = [s0 substringWithRange:NSMakeRange(8, 4)];
			NSString* s4 = [s0 substringWithRange:NSMakeRange(12, 4)];			
			NSString* sN = [NSString stringWithFormat:@"%@-%@-%@-%@", s1, s2, s3, s4];
			
			NSMutableString* temp = [sN mutableCopy];
			[temp replaceOccurrencesOfString:@" " withString:@"0" options:0 range:NSMakeRange(0, [temp length])];
			widgetName = [temp uppercaseString];
			[temp release];
			
			[widgetName retain];
		}
	}

	NSString* userWidgetFolder = [NSString stringWithFormat:@"%@/Library/Widgets", NSHomeDirectory()];

	NSString* name = [self infoForWidget:identifier key:@"title"];	
	NSImage* image = nil;
	
	NSData* imageData = (NSData*) [self infoForWidget:identifier key:@"image"];
	if([imageData length])
		image = [[[NSImage alloc] initWithData:imageData] autorelease];
	else
		image = [NSImage imageNamed:@"LargeGear"];

	{
		NSFileManager* fm = [NSFileManager defaultManager];
		NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
		NSString* directory = [NSString stringWithFormat:@"%@/_DashboardTemp", libraryDirectory];
		if([fm fileExistsAtPath:directory] == NO)
			[fm createDirectoryAtPath:directory attributes:nil];

		NSString* amnestyWidget = [NSString stringWithFormat:@"%@/Generator.wdgt", [[NSBundle mainBundle] resourcePath]];
		NSString* singleTemp = [NSString stringWithFormat:@"%@/%@.wdgt", directory, name];
		
		if([fm fileExistsAtPath:singleTemp])
			[fm removeFileAtPath:singleTemp handler:nil];

		if([fm copyPath:amnestyWidget toPath:singleTemp handler:nil] == YES) {
			NSString* path = [NSString stringWithFormat:@"%@/Info.plist", singleTemp];
			NSData* plistData = [NSData dataWithContentsOfFile:path];
			
			NSString* error;
			NSPropertyListFormat format;
			id plist = [NSPropertyListSerialization propertyListFromData:plistData
				mutabilityOption:NSPropertyListImmutable
				format:&format
				errorDescription:&error];
				
			if(plist) {
				CFMutableDictionaryRef prefDict = CFDictionaryCreateMutableCopy(
					kCFAllocatorDefault,
					0,
					(CFDictionaryRef) plist);

				CFDictionarySetValue(prefDict, CFSTR("CFBundleName"), name);	
				CFDictionarySetValue(prefDict, CFSTR("CFBundleIdentifier"), identifier);
				NSNumber* h = [NSNumber numberWithInt:height];
				CFDictionarySetValue(prefDict, CFSTR("Height"), h);
				NSNumber* w = [NSNumber numberWithInt:width];
				CFDictionarySetValue(prefDict, CFSTR("Width"), w);
								
				plist = (id) prefDict;	
					
				NSData* xmlData = [NSPropertyListSerialization dataFromPropertyList:plist
					format:NSPropertyListXMLFormat_v1_0
					errorDescription:&error];
					
				if(xmlData)
					[xmlData writeToFile:path atomically:YES];
			}

			NSImage* icon = image;
			if(icon) {
				NSString* imagePath = [NSString stringWithFormat:@"%@/Icon.png", singleTemp];
				[fm removeFileAtPath:imagePath handler:nil];
				
				NSSize size = [icon size]; 
				[icon lockFocus];
				NSBitmapImageRep* bits = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0,0,size.width,size.height)];
				[icon unlockFocus];				
				
				NSData* png = [bits representationUsingType:NSPNGFileType properties:nil];
				[png writeToFile:imagePath atomically:NO];		
			}
			
			NSString* htmlPath = [NSString stringWithFormat:@"%@/generator.htm", singleTemp];
			NSString* htmlData = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
				
			if(htmlData) {
				NSMutableString* mHtmlData = [htmlData mutableCopy];
				NSRange start = [mHtmlData rangeOfString:@"</div>"];
				[mHtmlData insertString:code atIndex:start.location];
				
				NSFileHandle* f = [NSFileHandle fileHandleForWritingAtPath:htmlPath];
				NSData* d = [mHtmlData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
				[f truncateFileAtOffset:0];
				[f writeData:d];
				[f synchronizeFile];
				[f closeFile];
			}

			NSString* jsPath = [NSString stringWithFormat:@"%@/generator.js", singleTemp];
			NSString* jsData = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
			
			if(jsData) {
				NSMutableString* mJsData = [jsData mutableCopy];
				[mJsData replaceOccurrencesOfString:@"RegisterWidget" withString:identifier options:0 range:NSMakeRange(0, [mJsData length])];
				[mJsData replaceOccurrencesOfString:@"0000-0000-0000-0000" withString:widgetName options:0 range:NSMakeRange(0, [mJsData length])];
				if(dashboardID)
					[mJsData replaceOccurrencesOfString:@"InitWidget" withString:dashboardID options:0 range:NSMakeRange(0, [mJsData length])];
				else	
					[mJsData replaceOccurrencesOfString:@"InitWidget" withString:identifier options:0 range:NSMakeRange(0, [mJsData length])];
				[mJsData replaceOccurrencesOfString:@"UserWidgetFolder" withString:userWidgetFolder options:0 range:NSMakeRange(0, [mJsData length])];
				
				NSFileHandle* f = [NSFileHandle fileHandleForWritingAtPath:jsPath];
				NSData* d = [mJsData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
				[f truncateFileAtOffset:0];
				[f writeData:d];
				[f synchronizeFile];
				[f closeFile];
			}
						
            {
				NSString* cssPath = [NSString stringWithFormat:@"%@/generator.css", singleTemp];
				NSString* cssData = [NSString stringWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:nil];
				
				if(cssData) {
					NSMutableString* mCssData = [cssData mutableCopy];
					//if(margin)
					//	[mCssData replaceOccurrencesOfString:@"0px;" withString:@"20px;" options:0 range:NSMakeRange(0, [mCssData length])];
						
					//if(region)
					//	[mCssData replaceOccurrencesOfString:@"none" withString:region options:0 range:NSMakeRange(0, [mCssData length])];
					
					//if(fullDrag)
						[mCssData replaceOccurrencesOfString:@"dashboard-region(control rectangle 0px 0px 0px 0px)" withString:@"none" options:0 range:NSMakeRange(0, [mCssData length])];
					
					NSFileHandle* f = [NSFileHandle fileHandleForWritingAtPath:cssPath];
					NSData* d = [mCssData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
					[f truncateFileAtOffset:0];
					[f writeData:d];
					[f synchronizeFile];
					[f closeFile];
				}
			}

			{
				NSURL* target = [NSURL fileURLWithPath:singleTemp];
				if(target)
					LSOpenCFURLRef((CFURLRef) target, NULL);
			}
		}
	}
}

- (void)addToDesktop:(NSString*)identifier
{
	if([desktop containsObject:identifier] == NO)	
		[desktop addObject:identifier];
}

- (void)addToHypercube:(NSString*)identifier
{
	if([hypercube containsObject:identifier] == NO)	
		[hypercube addObject:identifier];
}

- (void)removeFromDesktop:(NSString*)identifier
{
	if([desktop containsObject:identifier])	
		[desktop removeObject:identifier];
}

- (void)removeFromHypercube:(NSString*)identifier
{
	if([hypercube containsObject:identifier])	
		[hypercube removeObject:identifier];
}

- (void)openCube
{	
	if(isInHypercube)
		return;
		
	[NSApp activateIgnoringOtherApps:YES];	

	AppController* app = (AppController*) [NSApp delegate];
	if([app prefUISound])
		[switchSound play];

	isInHypercube = YES;	

	[self writeDomain:@"_Desktop"];
	[self readDomain:cubeDomain];
		
	if(cubeWindows == nil) {
		NSArray* screens = [NSScreen screens];
		if(screens) {
			cubeWindows = [NSMutableArray arrayWithCapacity:[screens count]];

			NSEnumerator* enumerator = [screens objectEnumerator];
			NSScreen* anObject;
			
			while((anObject = (NSScreen*) [enumerator nextObject])) {
				if([anObject isEqual:[NSScreen mainScreen]])
					continue;
					
				NSRect frame = [anObject frame];
				
				GalleryWindow* window = [[GalleryWindow alloc]
					initWithContentRect:frame
					styleMask:NSBorderlessWindowMask
					backing:NSBackingStoreBuffered
					defer:NO
				];
																
				[window setBackgroundColor:[NSColor colorWithDeviceWhite:0.05 alpha:1.0]];
				[window setLevel:NSPopUpMenuWindowLevel - 5]; 
				[window setAcceptsMouseMovedEvents:NO];
				
				NSImageView* brand = [[NSImageView alloc] initWithFrame:NSMakeRect(frame.size.width - 84.0, 20.0, 64.0, 64.0)];
				[[window contentView] addSubview:brand];
				[brand setImage:[NSImage imageNamed:@"Hypercube"]];
				[brand release];
				
				[cubeWindows addObject:window];
				
				[window release];
			}
			
			[cubeWindows retain];
		}
	}
	
	if(cubeWindows) {
		NSEnumerator* enumerator = [cubeWindows objectEnumerator];
		NSWindow* anObject;
		
		while((anObject = [enumerator nextObject]))
			[anObject orderFront:self];
	}	

	if(cube == nil) {
		NSRect frame = [[NSScreen mainScreen] frame];

		GalleryWindow* window = [[GalleryWindow alloc]
			initWithContentRect:frame
			styleMask:NSBorderlessWindowMask
			backing:NSBackingStoreBuffered
			defer:NO
		];
														
		[window setBackgroundColor:[NSColor colorWithDeviceWhite:0.05 alpha:1.0]];
		[window setLevel:NSPopUpMenuWindowLevel - 5]; 

		NSRect buttonFrame = NSMakeRect(frame.size.width - 270.0, frame.size.height - 58.0, 48.0, 48.0);
		CubeButton* button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"Library" inWindow:window];					
		[button setTarget:self];
		[button setAction:@selector(openGallery:)];
		[button setTag:galleryLibrary];
		[button setToolTip:NSLocalizedString(@"TipWidgetGallery", @"")];
		[button release];

		buttonFrame = NSMakeRect(frame.size.width - 217.0, frame.size.height - 58.0, 48.0, 48.0);
		button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"Cube" inWindow:window];					
		[button setTarget:self];
		[button setAction:@selector(openGallery:)];
		[button setTag:galleryCubes];
		[button setToolTip:NSLocalizedString(@"TipCubeGallery", @"")];
		[button release];

		buttonFrame = NSMakeRect(frame.size.width - 164.0, frame.size.height - 58.0, 48.0, 48.0);
		button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"Providers" inWindow:window];					
		[button setTarget:self];
		[button setAction:@selector(openGallery:)];
		[button setTag:galleryProviders];
		[button setToolTip:NSLocalizedString(@"TipProviderGallery", @"")];
		[button release];

		buttonFrame = NSMakeRect(frame.size.width - 111.0, frame.size.height - 58.0, 48.0, 48.0);
		button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"Help" inWindow:window];					
		[button setTarget:self];
		[button setAction:@selector(openGallery:)];
		[button setTag:galleryHelp];
		[button setToolTip:NSLocalizedString(@"TipHelp", @"")];
		[button release];
		
		buttonFrame = NSMakeRect(frame.size.width - 58.0, frame.size.height - 58.0, 48.0, 48.0);
		button = [[CubeButton alloc] initWithFrame:buttonFrame imageNamed:@"Close" inWindow:window];					
		[button setTarget:self];
		[button setAction:@selector(closeCube)];
		[button setToolTip:NSLocalizedString(@"TipExit", @"")];
		[button release];
		
		cubeTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(20.0, 20.0, frame.size.width - 40.0, 25.0)];
		[[window contentView] addSubview:cubeTitle];
		[cubeTitle setBordered:NO];
		[cubeTitle setEditable:NO];
		[cubeTitle setSelectable:NO];
		[cubeTitle setDrawsBackground:NO];

		NSImageView* brand = [[NSImageView alloc] initWithFrame:NSMakeRect(frame.size.width - 84.0, 20.0, 64.0, 64.0)];
		[[window contentView] addSubview:brand];
		[brand setImage:[NSImage imageNamed:@"Hypercube"]];
		[brand release];
		
		cube = window;
	}

	if(cubeTitle) {
		NSString* cubeName = cubeDomain;
		
		if([cubeDomain hasPrefix:@"_Cube"]) {
			NSString* defaultSuffix = [cubeDomain substringFromIndex:5];
			cubeName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Cube", @""), defaultSuffix];
		}
			
		NSString* title = [NSString stringWithFormat:@"%@ > %@", NSLocalizedString(@"Hypercube", @""), cubeName];
		
		NSDictionary* txtDict = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSFont fontWithName:@"Arial" size:18.0], NSFontAttributeName,
			[NSColor colorWithDeviceWhite:.90 alpha:1.0], NSForegroundColorAttributeName,
			//paraStyle, NSParagraphStyleAttributeName,
			nil];		
		NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:title attributes:txtDict];
		[cubeTitle setAttributedStringValue:attrStr];
		[attrStr release];
	}
	
	[cube orderFront:self];
	
	if(desktop) {
		NSEnumerator* enumerator = [desktop objectEnumerator];
		NSString* identifier;
		
		while((identifier = [enumerator nextObject])) {
			if(hypercube == nil || [hypercube containsObject:identifier] == NO) {
				WidgetController* controller = [instances objectForKey:identifier];
				if(controller)
					[controller hide];
			}
		}
	}
	
	if(hypercube) {
		NSEnumerator* enumerator = [hypercube objectEnumerator];
		NSString* identifier;
		
		while((identifier = [enumerator nextObject])) {
			WidgetController* controller = [instances objectForKey:identifier];
			if(controller) {
				[controller setDomain:cubeDomain];
				[controller readOptions];
				
				[controller setHypercube:YES];
				[controller resetOptionLevel];
				[controller show];
			}
			else {
				NSMutableDictionary* widget = [widgets objectForKey:identifier];
				if(widget) {
					NSString* code = [widget objectForKey:@"code"];
					WidgetController* controller = [self createWidget:code identifier:identifier domain:cubeDomain];
					[controller setHypercube:YES];
					[controller resetOptionLevel];
				}
			}
		}
	}

	[cube makeKeyWindow];

	if(isInGallery)
		[gallery makeKeyAndOrderFront:self];
}

- (void)closeCube
{
	if(isInHypercube == NO)
		return;
		
	isInHypercube = NO;
		
	[self writeDomain:cubeDomain];
	[self readDomain:@"_Desktop"];
		
	if(isInGallery)
		[gallery orderOut:self];

	if(hypercube) {
		NSEnumerator* enumerator = [hypercube objectEnumerator];
		NSString* identifier;
		
		while((identifier = [enumerator nextObject])) {
			if(desktop == nil || [desktop containsObject:identifier] == NO) {
				WidgetController* controller = [instances objectForKey:identifier];
				if(controller)
					[controller hide];
			}
		}
	}

	if(desktop) {
		NSEnumerator* enumerator = [desktop objectEnumerator];
		NSString* identifier;
		
		while((identifier = [enumerator nextObject])) {
			WidgetController* controller = [instances objectForKey:identifier];
			if(controller) {
				[controller setDomain:@"_Desktop"];
				[controller readOptions];
			
				[controller setHypercube:NO];
				[controller resetOptionLevel];
				[controller show];
			}
			else {
				// this actually should never occur but we keep in here in case we decide to allow desktop instatiation
				// from the hypercube
				
				NSMutableDictionary* widget = [widgets objectForKey:identifier];
				if(widget) {
					NSString* code = [widget objectForKey:@"code"];
					[self createWidget:code identifier:identifier domain:@"_Desktop"];
				}
			}
		}
	}
	
	if(cubeWindows) {
		NSEnumerator* enumerator = [cubeWindows objectEnumerator];
		NSWindow* anObject;
		
		while((anObject = [enumerator nextObject]))
			[anObject orderOut:self];
	}
	
	[cube orderOut:self];
}

- (void)openGallery:(id)sender
{
	if(isInGallery)
		return;

	[NSApp activateIgnoringOtherApps:YES];	

	isInGallery = YES;	

	// cover up the desktop...
	NSArray* screens = [NSScreen screens];
	
	if(galleryWindows == nil) {
		int count = [screens count];
		if(count > 1) {
			galleryWindows = [NSMutableArray arrayWithCapacity:count - 1];

			NSEnumerator* enumerator = [screens objectEnumerator];
			NSScreen* anObject;
			
			while((anObject = (NSScreen*) [enumerator nextObject])) {
				if([anObject isEqual:[NSScreen mainScreen]])
					continue;
				
				NSRect frame = [anObject frame];
				
				GalleryWindow* window = [[GalleryWindow alloc]
					initWithContentRect:frame
					styleMask:NSBorderlessWindowMask
					backing:NSBackingStoreBuffered
					defer:NO
				];
				
				[galleryWindows addObject:window];
				
				[window release];
			}
			
			[galleryWindows retain];
		}
	}
	
	if(galleryWindows) {
		NSEnumerator* enumerator = [galleryWindows objectEnumerator];
		NSWindow* anObject;
		
		while((anObject = [enumerator nextObject]))
			[anObject orderFront:self];
	}	
			
	GalleryController* controller = nil;
			
	// ...and show the Gallery in the main screen	
	if(gallery) 
		controller = (GalleryController*) [gallery windowController];
	else {
		controller = [[GalleryController alloc] init];
		[NSBundle loadNibNamed:@"Gallery" owner:controller];
			
		gallery = (GalleryWindow*) [controller window];	
		NSRect screenFrame = [[NSScreen mainScreen] frame];

		// kludge: if a webView's host window has a height that is not a multiple of 4,
		// scrolling in that window will reveal a boundary error during the blit.  we want
		// the gallery to cover the main window, so we just make it a bit taller.
		int mod = ((int) screenFrame.size.height % 4);
		if(mod != 0) {
			screenFrame.size.height += (4.0 - (float) mod);
		}

		[gallery setFrame:screenFrame display:NO];
		
		[controller setWidgetManager:self];
		[controller createButtons:self];
		[controller adjustGridForCount:0];
	}
		
	if(sender == nil)
		[self setupGallery:galleryWelcome];
	else 
		[self setupGallery:[sender tag]];
		
	[gallery makeKeyAndOrderFront:self];
	
	//GalleryView* view = (GalleryView*) [gallery contentView];
	//[view setCubeImage:[self getDesktopImage]];
}

- (void)setupGallery:(int)mode
{
	AppController* app = (AppController*) [NSApp delegate];

	GalleryController* controller = [gallery windowController];
	GalleryGrid* grid = [controller grid];
	[grid setFeatured:NO];

	galleryMode = mode;

	switch(mode) {
		case galleryLibrary:
		{
			[[grid superview] setHidden:NO];
			[controller stopBrowser];
			[controller showPresets:NO];

			[controller setGalleryTitle:NSLocalizedString(@"WidgetGallery", @"")];

			[self setupGalleryLibrary];
			break;
		}
		
		case galleryCubes:
		{
			[[grid superview] setHidden:NO];
			[controller stopBrowser];
			[controller showPresets:NO];

			[controller setGalleryTitle:NSLocalizedString(@"CubeGallery", @"")];

			[self setupGalleryCubes];
			break;
		}
		
		case galleryProviders:
		{
			[[grid superview] setHidden:YES];
			[controller stopBrowser];
						
			[controller setGalleryTitle:NSLocalizedString(@"ProviderGallery", @"")];

			if(providers)
				[self setupGalleryProviders];
			break;
		}
		
		case galleryBrowser:
		{
			[[grid superview] setHidden:YES];
			[controller showPresets:NO];

			[[controller webView] setMaintainsBackForwardList:YES];

			[controller startBrowser:NO];
			[controller goHome];
			break;
		}
		
		case galleryHelp:
		{
			[[grid superview] setHidden:YES];
			[controller showPresets:NO];
			
			[[controller webView] setMaintainsBackForwardList:NO];

			[controller setGalleryTitle:NSLocalizedString(@"InfoCenter", @"")];

			[controller startBrowser:YES];
			[controller setHome:@"http://www.amnestywidgets.com/hypercube/info/home.html" spoof:NO];
			[controller goHome];
			break;
		}
		
		case galleryWelcome:
		{
			[[grid superview] setHidden:YES];
			[controller showPresets:NO];
			
			[[controller webView] setMaintainsBackForwardList:NO];

			[controller setGalleryTitle:NSLocalizedString(@"Welcome", @"")];

			[controller startBrowser:YES];
			[controller setHome:@"http://www.amnestywidgets.com/hypercube/info/welcome.html" spoof:NO];
			[controller goHome];

			if([app prefUISound])
				[welcomeSound play];		
			break;
		}
	}
}

- (void)setupGalleryLibrary
{
	GalleryController* controller = [gallery windowController];
	GalleryGrid* grid = [controller grid];
	
	int count = [widgets count];
	[controller adjustGridForCount:[widgets count]];
		
	NSArray* cells = [grid cells];
	NSEnumerator* enumerator = [cells objectEnumerator];
	GalleryCell* cell;
	
	int index = 0;
	NSEnumerator* enumerator2 = [[widgetMenu itemArray] objectEnumerator];
	NSMenuItem* item;
	while((item = [enumerator2 nextObject]) && [item tag] != menuWidget)
		continue;

	while((cell = [enumerator nextObject])) {
		if(index++ < count) {
			NSArray* array = [menus allKeysForObject:item];
			NSString* identifier = [array objectAtIndex:0];
	
			[cell setIdentifier:identifier];
			[cell setTarget:self];
			[cell setAction:@selector(galleryLibraryAction:)];
			[cell setFeatured:NO];
							
			NSString* imageKey = [NSString stringWithFormat:@"WIDGET(%@)", identifier];
			NSImage* image = (NSImage*) [images objectForKey:imageKey];
			if(image)
				[cell setGalleryImage:image];
			else {
				NSData* imageData = (NSData*) [self infoForWidget:identifier key:@"image"];
				if(imageData && [imageData length]) {
					NSImage* image = [[NSImage alloc] initWithData:imageData];
					
					NSImage* mirroredImage = [GalleryCell getMirroredImage:image scale:YES];
					[cell setGalleryImage:mirroredImage];
					[images setObject:mirroredImage forKey:imageKey];
					
					[image release];
				}
				else {
					image = (NSImage*) [images objectForKey:@"DEFAULT(LargeGear)"];
					if(image)
						[cell setGalleryImage:image];
					else {
						NSImage* mirroredImage = [GalleryCell getMirroredImage:[NSImage imageNamed:@"LargeGear"] scale:YES];
						[cell setGalleryImage:mirroredImage];
						[images setObject:mirroredImage forKey:@"DEFAULT(LargeGear)"];
					}
				}
			}
									
			[cell setGalleryTitle:[item title]];
			item = [enumerator2 nextObject];
	
			[cell setEnabled:YES];
		}
		else
			[cell setEnabled:NO];
	}

	[controller checkScrollers]; 
	[grid setNeedsDisplay:YES];
}

- (void)galleryLibraryAction:(id)sender
{
	AppController* app = (AppController*) [NSApp delegate];
	if([app prefUISound])
		[clickSound play];

	GalleryCell* cell = [(GalleryGrid*)sender keyCell];
	NSString* identifier = [cell getIdentifier];
	
	if(identifier) {
		WidgetController* controller = [instances objectForKey:identifier];
		if(controller) {
			if([[controller window] isVisible]) {
				if([controller getGallery]) {
					if(isInHypercube == NO)
						[self removeFromDesktop:identifier];
					else {
						[controller setHypercube:NO];
						[self removeFromHypercube:identifier];
					}
						
					[controller setGallery:NO];
					[controller resetOptionLevel];
					
					[controller hide];
					[controller writeOptions];
				}
				else {
					[controller setGallery:YES];
					[controller resetOptionLevel];
				}
			}
			else {
				if(isInHypercube == NO) {
					if([controller getHypercube]) {
						[controller setDomain:@"_Desktop"];
						[controller readOptions];
						
						[controller setHypercube:NO];
					}
					else
						[controller readOptions];
					
					[controller setGallery:YES];
					[controller resetOptionLevel];
					
					[controller show];
					
					[self addToDesktop:identifier];
				}
				else {
					[controller show];
					
					if([controller getHypercube] == NO || [[controller getDomain] isEqualToString:cubeDomain] == NO) {
						[controller setDomain:cubeDomain];
						[controller readOptions];
						
						[controller setHypercube:YES];
					}	
					else
						[controller readOptions];
					
					[controller setGallery:YES];
					[controller resetOptionLevel];
					
					[self addToHypercube:identifier];
				}
			}
		}
		else {
			NSMutableDictionary* widget = [widgets objectForKey:identifier];
			
			if(widget) {
				NSString* code = [widget objectForKey:@"code"];
				WidgetController* controller = nil;
				
				if(isInHypercube) {
					controller = [self createWidget:code identifier:identifier domain:cubeDomain];
					[controller setHypercube:YES];
				}
				else
					controller = [self createWidget:code identifier:identifier domain:@"_Desktop"];
					
				[controller setGallery:YES];
				[controller resetOptionLevel];
			}
		}
	}
}

- (void)setupGalleryCubes
{
	NSMutableArray* cubes = [[NSMutableArray alloc] initWithCapacity:0];
		
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	NSArray* prefs = [fm directoryContentsAtPath:libraryDirectory];
	NSEnumerator* enumerator = [prefs objectEnumerator];
	NSString* directory;
		
	while((directory = [enumerator nextObject])) {
		if([directory hasSuffix:@".cube"]) {
			if([directory hasPrefix:@"_Cube"] || [directory hasPrefix:@"_"] == NO) {
				NSString* cubeName = [directory substringToIndex:[directory length] - 5];
				[cubes addObject:cubeName];
			}
		}
	}

	int count = [cubes count];
	if(count) {
		GalleryController* controller = [gallery windowController];
		GalleryGrid* grid = [controller grid];
		
		[controller adjustGridForCount:count];
		
		NSArray* cells = [grid cells];
		NSEnumerator* enumerator = [cells objectEnumerator];
		GalleryCell* cell;
		
		int index = 0;
		NSEnumerator* enumerator2 = [cubes objectEnumerator];
		NSString* key;
		
		while((cell = [enumerator nextObject])) {
			if(index++ < count) {
				key = [enumerator2 nextObject];
						
				[cell setIdentifier:key];
				[cell setTarget:self];
				[cell setAction:@selector(galleryCubeAction:)];
				[cell setFeatured:NO];
								
				NSString* imageKey = [NSString stringWithFormat:@"CUBE(%@)", key];
				NSImage* image = (NSImage*) [images objectForKey:imageKey];
				if(image)
					[cell setGalleryImage:image];
				else {
					image = (NSImage*) [images objectForKey:@"DEFAULT(LargeCube)"];
					if(image)
						[cell setGalleryImage:image];
					else {
						NSImage* mirroredImage = [GalleryCell getMirroredImage:[NSImage imageNamed:@"LargeCube"] scale:YES];
						[cell setGalleryImage:mirroredImage];
						[images setObject:mirroredImage forKey:@"DEFAULT(LargeCube)"];
					}
				}

				NSString* cubeName = key;
				
				if([key hasPrefix:@"_Cube"]) {
					NSString* defaultSuffix = [key substringFromIndex:5];
					cubeName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Cube", @""), defaultSuffix];
				}
										
				[cell setGalleryTitle:cubeName];
				[cell setEnabled:YES];
			}
			else
				[cell setEnabled:NO];
		}

		[[grid superview] setHidden:NO];
		[controller checkScrollers]; 
		[grid setNeedsDisplay:YES];
	}
	
	[cubes release];
}

- (void)galleryCubeAction:(id)sender
{
	AppController* app = (AppController*) [NSApp delegate];
	if([app prefUISound])
		[clickSound play];

	GalleryCell* cell = [(GalleryGrid*)sender keyCell];
	NSString* identifier = [cell getIdentifier];
	
	if(identifier == nil || [identifier isEqualToString:cubeDomain])
		return;

	if([app prefUISound])
		[switchSound play];
		
	[self writeDomain:cubeDomain];

	[cubeDomain release];
	cubeDomain = [[NSString stringWithString:identifier] retain];
	
	[self readDomain:cubeDomain];

	if(cubeTitle) {
		NSString* cubeName = cubeDomain;
		
		if([cubeDomain hasPrefix:@"_Cube"]) {
			NSString* defaultSuffix = [cubeDomain substringFromIndex:5];
			cubeName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Cube", @""), defaultSuffix];
		}
			
		NSString* title = [NSString stringWithFormat:@"%@ > %@", NSLocalizedString(@"Hypercube", @""), cubeName];
		
		NSDictionary* txtDict = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSFont fontWithName:@"Arial" size:18.0], NSFontAttributeName,
			[NSColor whiteColor], NSForegroundColorAttributeName,
			//paraStyle, NSParagraphStyleAttributeName,
			nil];		
			
		NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:title attributes:txtDict];
		[cubeTitle setAttributedStringValue:attrStr];
		[attrStr release];
	}

	NSEnumerator* enumerator = [[instances allValues] objectEnumerator];
	WidgetController* controller;
		
	while((controller = [enumerator nextObject])) {
		if([[controller window] isVisible]) {
			NSString* identifier = [controller getIdentifier];
			
			if(hypercube == nil || [hypercube containsObject:identifier] == NO) {
				WidgetController* controller = [instances objectForKey:identifier];
				if(controller)
					[controller hide];
			}
		}
	}
	
	if(hypercube) {
		NSEnumerator* enumerator = [hypercube objectEnumerator];
		NSString* identifier;
		
		while((identifier = [enumerator nextObject])) {
			WidgetController* controller = [instances objectForKey:identifier];
			if(controller) {
				[controller setDomain:cubeDomain];
				[controller readOptions];
				
				[controller setHypercube:YES];
				[controller resetOptionLevel];
				[controller show];
			}
			else {
				NSMutableDictionary* widget = [widgets objectForKey:identifier];
				if(widget) {
					NSString* code = [widget objectForKey:@"code"];
					WidgetController* controller = [self createWidget:code identifier:identifier domain:cubeDomain];
					[controller setHypercube:YES];
					[controller resetOptionLevel];
				}
			}
		}
	}
}

- (NSArray*)filteredProviders
{
	GalleryController* controller = [gallery windowController];
	GalleryGrid* grid = [controller grid];
	
	NSArray* ordered = [providers keysSortedByValueUsingSelector:@selector(caseInsensitiveCompare:)];
	NSMutableArray* filtered = [NSMutableArray arrayWithCapacity:[ordered count]];

	{
		NSEnumerator* enumerator2 = [ordered objectEnumerator];
		NSString* key;
		while((key = [enumerator2 nextObject])) {
			BOOL add = YES;
			
			if([providersHidden containsObject:key])
				add = NO;
				
			switch(preset) {
				case presetLibraries:
				{
					NSString* tag = [tags objectForKey:key];
					if(tag && [tag hasPrefix:@"library"] == NO)
						add = NO;
				}
				break;
				
				case presetGames:
				{
					NSString* tag = [tags objectForKey:key];
					if(tag && [tag hasPrefix:@"games"] == NO)
						add = NO;
				}
				break;
				
				case presetVideo:
				{
					NSString* tag = [tags objectForKey:key];
					if(tag && [tag hasPrefix:@"video"] == NO)
						add = NO;
				}
				break;
				
				case presetPhotos:
				{
					NSString* tag = [tags objectForKey:key];
					if(tag && [tag hasPrefix:@"photos"] == NO)
						add = NO;
				}
				break;
				
				case presetMusic:
				{
					NSString* tag = [tags objectForKey:key];
					if(tag && [tag hasPrefix:@"music"] == NO)
						add = NO;
				}
				break;
				
				case presetOther:
				{
					NSString* tag = [tags objectForKey:key];
					if(tag && [tag hasPrefix:@"custom"] == NO)
						add = NO;
				}
				break;
			}	
				
			if(add)
				[filtered addObject:key];
		}
	}
		
	int featuredCount = 0;

	if([filtered count]) {
		NSMutableArray* insertions = [NSMutableArray arrayWithCapacity:[providersFeatured count]];
		
		// remove the featured providers...		
		{
			NSEnumerator* enumerator2 = [providersFeatured reverseObjectEnumerator];
			NSString* key;
			while((key = [enumerator2 nextObject])) {
				if([filtered containsObject:key]) {
					[insertions addObject:key];
					[filtered removeObject:key];
					
					featuredCount++;
				}
			}
		}
		
		// ..and move them to the top of the list
		{
			NSEnumerator* enumerator2 = [insertions objectEnumerator];
			NSString* key;
			while((key = [enumerator2 nextObject])) {
				[filtered insertObject:key atIndex:0];
			}
		}
	}
	
	// pad any featured providers
	int padding = (featuredCount == 0 ? 0 : ([grid numberOfColumns] - featuredCount));
	while(padding-- > 0)
		[filtered insertObject:[NSNull null] atIndex:featuredCount];
		
	return filtered;
}

- (void)setupGalleryProviders
{
	if(providers == nil || [providers count] == 0)
		return;
			
	int count = [providers count] - [providersHidden count];
	
	if(count) {
		GalleryController* controller = [gallery windowController];
		GalleryGrid* grid = [controller grid];
		
		NSArray* ordered = [self filteredProviders];
		count = [ordered count];
		[controller adjustGridForCount:count];
		
		NSArray* cells = [grid cells];
		NSEnumerator* enumerator = [cells objectEnumerator];
		GalleryCell* cell;
		
		int index = 0;
		int featuredCount = 0;
		NSEnumerator* enumerator2 = [ordered objectEnumerator];
		NSString* key;
		
		while((cell = [enumerator nextObject])) {
			if(index++ < count) {
				key = [enumerator2 nextObject];
				
				if(key == nil || [key isEqualTo:[NSNull null]])
					[cell setEnabled:NO];
				else {		
					[cell setTag:[key hash]];
					[cell setIdentifier:key];
					[cell setTarget:self];
					[cell setAction:@selector(galleryProviderAction:)];
					
					if([providersFeatured containsObject:key]) {
						[cell setFeatured:YES];
						featuredCount++;
					}
					else {
						[cell setFeatured:NO];
					}
						
					NSString* imageKey = [NSString stringWithFormat:@"PROVIDER(%@)", key];
					NSImage* image = (NSImage*) [images objectForKey:imageKey];
					if(image)
						[cell setGalleryImage:image];
					else {
						image = (NSImage*) [images objectForKey:@"DEFAULT(LargeWorld)"];
						if(image)
							[cell setGalleryImage:image];
						else {
							NSImage* mirroredImage = [GalleryCell getMirroredImage:[NSImage imageNamed:@"LargeWorld"] scale:YES];
							[cell setGalleryImage:mirroredImage];
							[images setObject:mirroredImage forKey:@"DEFAULT(LargeWorld)"];
						}
					}

					[cell setGalleryTitle:[providers valueForKey:key]];
					[cell setEnabled:YES];
				}
			}
			else
				[cell setEnabled:NO];
		}
		
		if(featuredCount)
			[grid setFeatured:YES];
		else
			[grid setFeatured:NO];
		
		[controller showPresets:YES];
		
		NSString* presetString = nil;
		switch(preset) {
			case presetAll:
				presetString = NSLocalizedString(@"TipPresetAll", @"");
				break;
				
			case presetLibraries:
				presetString = NSLocalizedString(@"TipPresetLibraries", @"");
				break;
				
			case presetGames:
				presetString = NSLocalizedString(@"TipPresetGames", @"");
				break;
				
			case presetVideo:
				presetString = NSLocalizedString(@"TipPresetVideo", @"");
				break;
				
			case presetPhotos:
				presetString = NSLocalizedString(@"TipPresetPhotos", @"");
				break;
				
			case presetMusic:
				presetString = NSLocalizedString(@"TipPresetMusic", @"");
				break;
				
			case presetOther:
				presetString = NSLocalizedString(@"TipPresetOther", @"");
				break;
		}		
		[controller setGalleryTitle:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"ProviderGallery", @""), presetString]];

		[[grid superview] setHidden:NO];
		[controller checkScrollers]; 
		[grid setNeedsDisplay:YES];
	}
}

- (void)galleryProviderAction:(id)sender
{
	AppController* app = (AppController*) [NSApp delegate];
	if([app prefUISound])
		[clickSound play];

	GalleryCell* cell = [(GalleryGrid*)sender keyCell];
	NSString* identifier = [cell getIdentifier];
	NSString* homeURL = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/providers/pages/%@.html", identifier];

	BOOL spoofFlag = NO;
	if([providersSpoofed containsObject:identifier])
		spoofFlag = YES;

	GalleryController* controller = [gallery windowController];
	[controller setHome:homeURL spoof:spoofFlag];

	[controller setGalleryTitle:[NSString stringWithFormat:@"%@ > %@", NSLocalizedString(@"ProviderGallery", @""), [cell title]]];

	[self setupGallery:galleryBrowser];
}

-(void)resetProviders
{
	[self setupGallery:galleryProviders];
}

- (void)closeGallery
{
	if(isInGallery == NO)
		return;
		
	if(galleryMode == galleryBrowser || galleryMode == galleryHelp || galleryMode == galleryWelcome) {
		GalleryController* controller = [gallery windowController];
		[controller stopBrowser];
	}
	
	isInGallery = NO;	

	NSEnumerator* enumerator = [[instances allValues] objectEnumerator];
	WidgetController* controller;
		
	while((controller = [enumerator nextObject])) {
		[controller setGallery:NO];
		[controller resetOptionLevel];
	}

	if(galleryWindows) {
		NSEnumerator* enumerator = [galleryWindows objectEnumerator];
		NSWindow* anObject;
		
		while((anObject = [enumerator nextObject]))
			[anObject orderOut:self];
	}
	
	[gallery orderOut:self];
	
	if(isInHypercube)
		[cube makeKeyAndOrderFront:self];
}

/*- (NSColor *)backdropColorForFrame:(NSRect)frame
{
    NSImage* bg = [[NSImage alloc] initWithSize:frame.size];
    [bg lockFocus];

	{
		NSBezierPath* bgPath = [NSBezierPath bezierPath];
		
		int x = 0;
		int y = 0;
		
		for(x = 0; x <= (frame.size.width / 100.0) + 2; x += 2) {
			for(y = 0; y <= (frame.size.height / 100.0) + 2; y++) {
				if((y % 2) == 0)
					[bgPath appendBezierPathWithRect:NSMakeRect(x*100.0, y*100.0, 100.0, 100.0)];
				else
					[bgPath appendBezierPathWithRect:NSMakeRect(100.0 + (x*100.0), y*100.0, 100.0, 100.0)];
			}
		}
		[bgPath closePath];
		
		[[NSColor colorWithDeviceRed:.063 green:.282 blue:.482 alpha:.55] set];
		[bgPath fill];
	}
		
	{
		NSBezierPath* bgPath = [NSBezierPath bezierPath];
		
		int x = 0;
		int y = 0;
		
		for(x = 0; x <= (frame.size.width / 100.0) + 2; x += 2) {
			for(y = 0; y <= (frame.size.height / 100.0) + 2; y++) {
				if((y % 2) == 0)
					[bgPath appendBezierPathWithRect:NSMakeRect(100.0 + (x*100.0), y*100.0, 100.0, 100.0)];
				else
					[bgPath appendBezierPathWithRect:NSMakeRect(x*100.0, y*100.0, 100.0, 100.0)];
			}
		}
		[bgPath closePath];
		
		[[NSColor colorWithDeviceRed:.090 green:.318 blue:.533 alpha:.55] set];
		[bgPath fill];
	}
		
	[bg unlockFocus];
	
	return [NSColor colorWithPatternImage:[bg autorelease]];
}
*/

#if 0
- (NSImage*)getDesktopImage
{
	NSImage *image = nil;

	PicHandle picHandle;
	GDHandle mainDevice;
	Rect rect;
	NSImageRep *imageRep;
	
    NSRect cocoaRect = [[NSScreen mainScreen] frame];

	// Convert NSRect to Rect
	SetRect(&rect, NSMinX(cocoaRect), NSMinY(cocoaRect), NSMaxX(cocoaRect), NSMaxY(cocoaRect));
	
	// Get the main screen. I may want to add support for multiple screens later
	mainDevice = GetMainDevice();
	
	// Capture the screen into the PicHandle.
	picHandle = OpenPicture(&rect);
	CopyBits((BitMap *)*(**mainDevice).gdPMap, (BitMap *)*(**mainDevice).gdPMap,
				&rect, &rect, srcCopy, 0l);
	ClosePicture();
	
	// Convert the PicHandle into an NSImage
	// First lock the PicHandle so it doesn't move in memory while we copy
	HLock((Handle)picHandle);
	imageRep = [NSPICTImageRep imageRepWithData:[NSData dataWithBytes:(*picHandle)
					length:GetHandleSize((Handle)picHandle)]];
	HUnlock((Handle)picHandle);
	
	// We can release the PicHandle now that we're done with it
	KillPicture(picHandle);
	
	// Create an image with the representation
	image = [[[NSImage alloc] initWithSize:[imageRep size]] autorelease];
	[image addRepresentation:imageRep];
	[image setScalesWhenResized:YES];
	//float width = (60.0 * cocoaRect.size.width) / cocoaRect.size.height;
	//[image setSize:NSMakeSize(width, 60.0)];
	
	return image;
}
#endif

// NSMenu delegate
- (void)menuNeedsUpdate:(NSMenu *)menu
{
	NSWindow* modal = [NSApp modalWindow];
	if(modal)
		[NSApp activateIgnoringOtherApps:YES];

	NSMenuItem* item;
		
	BOOL didRemove = NO;	
		
	while((item = [menu itemWithTag:menuWidget])) {
		[menu removeItem:item];
		didRemove = YES;
	}

	if(didRemove)
		[menu removeItemAtIndex:0];

	BOOL didInsert = NO;

	NSEnumerator* enumerator = [[widgetMenu itemArray] objectEnumerator];
	int insertPoint = 0;
	
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	
	while((item = [enumerator nextObject])) {
		if([item tag] == menuWidget) {
			NSArray* array = [menus allKeysForObject:item];
			NSString* identifier = [array objectAtIndex:0];
			
			NSDictionary* udEntry = [ud persistentDomainForName:[NSString stringWithFormat:@"Amnesty Hypercube/_Desktop.cube/%@", identifier]];
			if(udEntry || [desktop containsObject:identifier]) {
				NSMenuItem* menuItem = [item copy];
				[menuItem setRepresentedObject:item];
				
				[menu insertItem:menuItem atIndex:insertPoint++];
				
				[menuItem release];
				
				didInsert = YES;
			}
		}
	}
	
	if(didInsert)
		[menu insertItem:[NSMenuItem separatorItem] atIndex:insertPoint++];
}

// NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSString* connectionID = [sessionID objectForKey:[connection description]];
	if(connectionID) {
		if([connectionID hasSuffix:@":LIB"]) {
			if(providers == nil)
				[self buildDefaultLibrary];
		
			if([connectionID hasPrefix:@"GALLERY:"])
				[self setupGalleryProviders];
				
			isUpdating = NO;
		}
		else if([connectionID hasSuffix:@":IMG"]) {
			imageSessionCount--;
		}
	}

	[sessionData removeObjectForKey:[connection description]];
	[sessionID removeObjectForKey:[connection description]];	
	[connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSMutableData* connectionData = [sessionData objectForKey:[connection description]];
	if(connectionData == nil) {
		connectionData = [[NSMutableData alloc] initWithCapacity:[data length]];
		[sessionData setObject:connectionData forKey:[connection description]];
		[connectionData release];
	}
	
	[connectionData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSMutableData* connectionData = [sessionData objectForKey:[connection description]];
	NSString* connectionID = [sessionID objectForKey:[connection description]];
	
 	if(connectionData && [connectionData length] && connectionID) {
		if([connectionID hasSuffix:@":XML.GGL"]) {
			NSString* identifier = [connectionID substringToIndex:[connectionID length] - 8];
			NSString* code = [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding];
			
			if(code) {
				BOOL foundCode = NO;
				
				NSRange start = [code rangeOfString:@"thumbnail=\"" options: NSCaseInsensitiveSearch];
				if(start.location != NSNotFound) {
					start.location += 11;
					foundCode = YES;
				}
				else {
					start = [code rangeOfString:@"screenshot=\"" options: NSCaseInsensitiveSearch];
					if(start.location != NSNotFound) {
						start.location += 12;
						foundCode = YES;
					}
				}
				
				if(foundCode) {
					NSRange end = [[code substringFromIndex:start.location] rangeOfString:@"\""];
					start.length = end.location;
					
					NSString* extracted = [code substringWithRange:start];
					if(extracted && [extracted length]) {
						if([extracted hasPrefix:@"http://"] == NO)
							extracted = [NSString stringWithFormat:@"http://www.google.com%@", extracted];
							
						NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:extracted]
							cachePolicy:NSURLRequestUseProtocolCachePolicy
							timeoutInterval:20.0];
							
						NSURLConnection* newConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
						[sessionID setObject:[NSString stringWithFormat:@"%@:IMG.WGT", identifier] forKey:[newConnection description]];
					}
				}
			}
			
			[code release];
		}
		else if([connectionID hasSuffix:@":IMG.WGT"]) {
			NSString* identifier = [connectionID substringToIndex:[connectionID length] - 8];
			NSImage* image = [[NSImage alloc] initWithData:connectionData];
			if(image) {
				[self setInfoForWidget:identifier key:@"image" object:image];
				[image release];
			}
		}
		else if([connectionID hasSuffix:@":IMG"]) {
			imageSessionCount--;

			NSString* key = [connectionID substringToIndex:[connectionID length] - 4];
			NSImage* image = [[NSImage alloc] initWithData:connectionData];
			NSImage* mirroredImage = nil;
			if(image) {
				mirroredImage = [GalleryCell getMirroredImage:image scale:YES];
				[images setObject:mirroredImage forKey:key];
			}
			[image release];
			
			if(isInGallery && galleryMode == galleryProviders) {
				GalleryController* controller = (GalleryController*) [gallery windowController];
				GalleryGrid* grid = [controller grid];
		
				NSString* identifier = [key substringWithRange:NSMakeRange(9, [key length] - 10)];
		
				GalleryCell* cell = [grid cellWithTag:[identifier hash]];
				if(cell)
					[cell setImage:mirroredImage];
			}
		}
		else if([connectionID hasSuffix:@":LIB"]) {
			NSString* lib = [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding];
			[self parseLibrary:lib];
			
			if([connectionID hasPrefix:@"GALLERY:"] || (isInGallery && galleryMode == galleryProviders)) {
				[self setupGalleryProviders];
			}
				
			[lib release];
			
			isUpdating = NO;
		}
		else if([connectionID hasSuffix:@":WGT"]) {
			NSString* lib = [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding];
			[self parseWidgets:lib];
			[lib release];
		}
	}

	[sessionData removeObjectForKey:[connection description]];
	[sessionID removeObjectForKey:[connection description]];	
	[connection release];
}

- (void)loadLibrary
{
	[self updateLibrary:nil];
	
	[NSTimer
		scheduledTimerWithTimeInterval:(double) 3600.0
		target:self
		selector:@selector(updateLibrary:)
		userInfo:nil
		repeats:YES];
}

- (void)updateLibrary:(id)sender
{
	if(isInGallery && galleryMode == galleryProviders)
		return;
		
	if(isUpdating)
		return;

	BOOL loadLocal = NO;
	BOOL canConnect = YES;
	
	// try to update the library once per day
	NSCalendarDate* date = [NSCalendarDate calendarDate];
	int day = [date dayOfMonth];
	if(day == updateDay) {
		if(sender == nil)
			loadLocal = YES;
		else if(usingDefaultLibrary == NO)	
			return;
	}
		
	isUpdating = YES;
	
	SCNetworkConnectionFlags flags;
	if(SCNetworkCheckReachabilityByName("amnestywidgets.com", &flags)) {
		if(!(flags & kSCNetworkFlagsReachable)) {
			canConnect = NO;
		}
	}
	
	if(canConnect && loadLocal == NO)
		[[NSURLCache sharedURLCache] removeAllCachedResponses];
	
	NSURLRequestCachePolicy policy = NSURLRequestUseProtocolCachePolicy;
	
	if(loadLocal)
		policy = NSURLRequestReturnCacheDataElseLoad;
		
	if(canConnect == NO)
		policy = NSURLRequestReturnCacheDataDontLoad;
	  
	NSMutableURLRequest* request = [[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.amnestywidgets.com/hypercube/providers/default.xml"]
		cachePolicy:policy
		timeoutInterval:20.0] mutableCopy];

	[request setValue:@"Amnesty Hypercube/0.25a (Macintosh)" forHTTPHeaderField:@"User-Agent"];

	if(canConnect && loadLocal == NO && updateHash) {
		int calculatedHash = updateHash * 1423;
		int verifier = 983 + (calculatedHash % 223);
		calculatedHash += verifier;
		
		[request setValue:[NSString stringWithFormat:@"Amnesty Hypercube/0.25a (Macintosh; I%d; C%d)", calculatedHash, verifier] forHTTPHeaderField:@"User-Agent"];
		
		updateHash = 0;
	}
		
	NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[sessionID setObject:[NSString stringWithFormat:@"UPDATE:LIB"] forKey:[connection description]];
	
	[request release];
}

- (void)parseLibrary:(NSString*)xml
{
	BOOL loadLocal = NO;
	BOOL canConnect = YES;
	
	// try to update the library once per day
	NSCalendarDate* date = [NSCalendarDate calendarDate];
	int day = [date dayOfMonth];
	if(day == updateDay)
		loadLocal = YES;
	
	SCNetworkConnectionFlags flags;
	if(SCNetworkCheckReachabilityByName("amnestywidgets.com", &flags)) {
		if(!(flags & kSCNetworkFlagsReachable)) {
			canConnect = NO;
		}
	}

	NSURLRequestCachePolicy policy = NSURLRequestUseProtocolCachePolicy;
	
	if(loadLocal)
		policy = NSURLRequestReturnCacheDataElseLoad;
		
	if(canConnect == NO)
		policy = NSURLRequestReturnCacheDataDontLoad;

	NSRange start = [xml rangeOfString:@"<provider"];
	int length = [xml length];

	NSMutableDictionary* provisionalProviders = [NSMutableDictionary dictionaryWithCapacity:0];		
	NSMutableDictionary* provisionalCoders = [NSMutableDictionary dictionaryWithCapacity:0];
	NSMutableDictionary* provisionalTags = [NSMutableDictionary dictionaryWithCapacity:0];
	
	BOOL rebuild = YES;
		
	while(start.location != NSNotFound) {
		NSString* title = nil;
		NSString* key = nil;
		NSString* domain = nil;
		NSString* tag = nil;
		
		NSRange end = [xml rangeOfString:@"</provider>" options:0 range:NSMakeRange(start.location, length - start.location)];
		if(end.location == NSNotFound)
			break;
			
		start.length = end.location - start.location;
		
		NSString* siteXML = [xml substringWithRange:start];
		if(siteXML) {
			NSRange titleStart = [siteXML rangeOfString:@"<title>"];
			NSRange titleEnd = [siteXML rangeOfString:@"</title>"];
			
			if(titleStart.location != NSNotFound && titleEnd.location != NSNotFound) {
				titleStart.location += 7;
				titleStart.length = titleEnd.location - titleStart.location;
				title = [siteXML substringWithRange:titleStart];
			}
			
			NSRange keyStart = [siteXML rangeOfString:@"<key>"];
			NSRange keyEnd = [siteXML rangeOfString:@"</key>"];
			
			if(keyStart.location != NSNotFound && keyEnd.location != NSNotFound) {
				keyStart.location += 5;
				keyStart.length = keyEnd.location - keyStart.location;
				key = [siteXML substringWithRange:keyStart];
			}
			
			NSRange domainStart = [siteXML rangeOfString:@"<domain>"];
			NSRange domainEnd = [siteXML rangeOfString:@"</domain>"];
			
			if(domainStart.location != NSNotFound && domainEnd.location != NSNotFound) {
				domainStart.location += 8;
				domainStart.length = domainEnd.location - domainStart.location;
				domain = [siteXML substringWithRange:domainStart];
			}
			
			NSRange tagsStart = [siteXML rangeOfString:@"tags=\""];
			NSRange tagsEnd = [siteXML rangeOfString:@"\">"];
			
			if(tagsStart.location != NSNotFound && tagsStart.location != NSNotFound) {
				tagsStart.location += 6;
				tagsStart.length = tagsEnd.location - tagsStart.location;
				tag = [siteXML substringWithRange:tagsStart];
			}
		}

		if(title && key) {
			//NSLog(key);
			
			if(rebuild == YES) {
				[providersFeatured removeAllObjects];
				[providersHidden removeAllObjects];
				[providersSpoofed removeAllObjects];
				
				rebuild = NO;
			}
			
			NSRange featuredFlag = [siteXML rangeOfString:@"featured="];
			if(featuredFlag.location != NSNotFound)
				[providersFeatured addObject:key];

			NSRange hiddenFlag = [siteXML rangeOfString:@"hidden="];
			if(hiddenFlag.location != NSNotFound)
				[providersHidden addObject:key];
				
			NSRange spoofFlag = [siteXML rangeOfString:@"spoof="];
			if(spoofFlag.location != NSNotFound)
				[providersSpoofed addObject:key];

			if(hiddenFlag.location == NSNotFound) {
				NSString* imageKey = [NSString stringWithFormat:@"PROVIDER(%@)", key];
				NSString* sessionKey = [NSString stringWithFormat:@"%@:IMG", imageKey];

				if([images objectForKey:imageKey] == nil && [imageSessions objectForKey:sessionKey] == nil) {
					NSString* imageURL = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/providers/images/%@.png", key];   
						
					NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]
						cachePolicy:policy
						timeoutInterval:20.0];
						
					[imageSessions setObject:request forKey:sessionKey];
					
					if(imageSessionTimer == nil) {
						imageSessionTimer = [NSTimer
							scheduledTimerWithTimeInterval:(double) 0.01
							target:self
							selector:@selector(pollImageSessions:)
							userInfo:nil
							repeats:YES];
					}
				}
			}
			
			[provisionalProviders setObject:title forKey:key];
		}
		
		if(domain) {
			[provisionalCoders setObject:domain forKey:key];
		}
		
		if(tag) {
			[provisionalTags setObject:tag forKey:key];
		}
			
		start = [xml rangeOfString:@"<provider" options:0 range:NSMakeRange(end.location, [xml length] - end.location)];
	}
	
	if([provisionalProviders count]) {
		[providers release];
		providers = [provisionalProviders retain];

		NSCalendarDate* date = [NSCalendarDate calendarDate];
		updateDay = [date dayOfMonth];
		
		NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
		
		[ud setInteger:updateDay forKey:@"LibraryUpdate"];
		if([providersSpoofed containsObject:@"GoogleGadgets"]) {
			//NSLog(@"will not syndicate Google");
			
			syndicate = NO;
			[ud setBool:syndicate forKey:@"Syndicate"];
		}
		else
			[ud removeObjectForKey:@"Syndicate"];
		
		[ud synchronize];
		
		usingDefaultLibrary = NO;
	}
	
	if([provisionalCoders count]) {
		[coders release];
		coders = [provisionalCoders retain];
	}
	
	if([provisionalTags count]) {
		[tags release];
		tags = [provisionalTags retain];
	}
	
	if(providers == nil)
		[self buildDefaultLibrary];
}

- (void)parseWidgets:(NSString*)xml
{
	NSRange start = [xml rangeOfString:@"<widget"];
	int length = [xml length];
	
	while(start.location != NSNotFound) {
		NSRange end = [xml rangeOfString:@"</widget>" options:0 range:NSMakeRange(start.location, length - start.location)];
		if(end.location == NSNotFound)
			break;

		start.length = end.location - start.location;

		NSString* siteXML = [xml substringWithRange:start];
		if(siteXML) {
			NSRange titleStart = [siteXML rangeOfString:@"<![CDATA["];
			NSRange titleEnd = [siteXML rangeOfString:@"]]>"];
			
			if(titleStart.location != NSNotFound && titleEnd.location != NSNotFound) {
				titleStart.location += 9;
				titleStart.length = titleEnd.location - titleStart.location;
				NSString* code = [siteXML substringWithRange:titleStart];
				NSString* trimmedCode = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

				BOOL create = NO;
				NSRange createFlag = [siteXML rangeOfString:@"create="];
				if(createFlag.location != NSNotFound)
					create = YES;

				BOOL exclude = NO;
				NSRange excludeFlag = [siteXML rangeOfString:@"exclude=\"mac\""];
				if(excludeFlag.location != NSNotFound)
					exclude = YES;

				if(exclude == NO)
					[self installWidgetWithCode:trimmedCode create:create force:YES];
			}
		}
		
		start = [xml rangeOfString:@"<widget" options:0 range:NSMakeRange(end.location, [xml length] - end.location)];
	}
}

- (void)buildDefaultLibrary
{
	if(providers == nil) {
		providers = [[NSMutableDictionary alloc] initWithCapacity:0];
		
		[providers setObject:@"Google Gadgets" forKey:@"GoogleGadgets"];
		[providers setObject:@"YouTube" forKey:@"YouTube"];
	}
		
	if(coders == nil) {
		coders = [[NSMutableDictionary alloc] initWithCapacity:0];
		
		[coders setObject:@"gmodules.com" forKey:@"GoogleGadgets"];
		[coders setObject:@"youtube.com" forKey:@"YouTube"];
	}
	
	usingDefaultLibrary = YES;
}

// client integration
- (int)getWidgetVersion // hash
{
   	int base1 = 0;
	int base2 = 0;
	int base3 = 0;
	int base4 = 0;
	
	if(widgetData == nil)
		return 0;
		
	char* element = widgetData;
		
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

- (void)pollImageSessions:(id)sender
{
	if([imageSessions count]) {
		if(imageSessionCount < 8) {
			NSString* sessionKey = [[imageSessions allKeys] objectAtIndex:0];
			NSURLRequest* request = [imageSessions objectForKey:sessionKey];
			
			NSURLConnection* newConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
			[sessionID setObject:sessionKey forKey:[newConnection description]];
			imageSessionCount++;
			
			[imageSessions removeObjectForKey:sessionKey];
		}
	}
	else {
		[imageSessionTimer invalidate];
		imageSessionTimer = nil;
	}
}

@end
