//
//  WidgetManager.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/26/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "WidgetManager.h"
#import "Provider.h"
#import "Widget.h"
#import "MainController.h"


@implementation WidgetManager

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
	int codeLength = [code length];
	
	while(start.location != NSNotFound) {
		start.location += 7;
		
		NSRange subRange = start;
		subRange.length = 32;
		
		if(subRange.location + 32 > codeLength)
			subRange.length = codeLength - subRange.location;
		else
			subRange.length = 32;
		
		NSString* sub = [code substringWithRange:subRange];
		const char* s = [sub UTF8String];
		char raw[32];
		int r = 0;
		while(*s) {
			if(isalnum(*s) || *s == '.' || *s == '-')
				raw[r++] = *s;
			else
				break;
			s++;
		}
		raw[r] = '\0';
		if(r) {
			NSString* extracted = [NSString stringWithFormat:@"%s", raw];

			NSRange ignore1 = [extracted rangeOfString:@"macromedia.com"];
			NSRange ignore2 = [extracted rangeOfString:@"adobe.com"];
			NSRange ignore3 = [extracted rangeOfString:@"gmodules.com"];
			
			if(ignore1.location == NSNotFound && ignore2.location == NSNotFound && ignore3.location == NSNotFound) {
				if(domain == nil)
					domain = extracted;
			}
		}
		
		start.location += start.length;
		start.length = codeLength - start.location;
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
		identifier = [[[NSString alloc] initWithFormat:@"(%@)%@", domain, serial] autorelease];
	else
		identifier = [[[NSString alloc] initWithFormat:@"(localhost)%@", serial] autorelease];
														
	return identifier;
}

- (id)init
{
	if(self = [super init]) {
		library = [[NSMutableDictionary alloc] init];
		alphaLibrary = nil;
		
		dashboardLibrary = [[NSMutableDictionary alloc] init];
		yahooLibrary = [[NSMutableDictionary alloc] init];
		destinations = [[NSMutableDictionary alloc] init];
		providers = [[NSMutableDictionary alloc] init];
		clients = [[NSMutableDictionary alloc] init];

		sessionData = [[NSMutableDictionary alloc] init];
		sessionID = [[NSMutableDictionary alloc] init];
		
		openClients =  [[NSMutableArray alloc] init];;
		
		NSArray* keys = [NSArray arrayWithObjects:@"canShowAll", @"canHideAll", @"canCloseAll", nil];
		NSArray* values = [NSArray arrayWithObjects:[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], nil];
		properties = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
		
		id transformer;
		transformer = [[[WidgetCanLaunchTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"WidgetCanLaunchTransformer"];
		transformer = [[[WidgetCanCloseTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"WidgetCanCloseTransformer"];
		transformer = [[[WidgetCanHideTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"WidgetCanHideTransformer"];
		transformer = [[[WidgetCanShowTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"WidgetCanShowTransformer"];
		transformer = [[[WebWidgetTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"WebWidgetTransformer"];
		transformer = [[[PlatformTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"PlatformTransformer"];
		transformer = [[[DestinationTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"DestinationTransformer"];
		transformer = [[[LinkedTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"LinkedTransformer"];
		transformer = [[[SingleSelectionTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"SingleSelectionTransformer"];
		transformer = [[[EmptyStringTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"EmptyStringTransformer"];
	}

	return self;
}

- (void)dealloc
{
	[[sessionID allValues] makeObjectsPerformSelector:@selector(cancel)];
	[sessionID release];
	[sessionData release];

	[super dealloc];
}

- (NSMutableDictionary*)library
{
	return library;
}

- (NSMutableDictionary*)dashboardLibrary
{
	return dashboardLibrary;
}

- (NSMutableDictionary*)yahooLibrary
{
	return yahooLibrary;
}

- (NSMutableDictionary*)destinations
{
	return destinations;
}

- (NSMutableDictionary*)providers
{
	return providers;
}

- (NSMutableDictionary*)clients
{
	return clients;
}

- (NSMutableArray*)openClients
{
	return openClients;
}

- (NSArray*)visibleProviders
{
	NSMutableArray* visible = [[[NSMutableArray alloc] initWithCapacity:[providers count]] autorelease];
	NSEnumerator* enumerator = [[providers allValues] objectEnumerator];
	Widget* widget;
	
	while((widget = [enumerator nextObject])) {
		NSString* identifier = [widget identifier];
		if([identifier hasPrefix:@"publisher:"])
			[visible addObject:widget];
	}
	
	return visible;
}

- (NSString*)providerForCode:(NSString*)code
{
	NSEnumerator* enumerator = [[providers allValues] objectEnumerator];
	Widget* widget;
	
	while((widget = [enumerator nextObject])) {
		NSString* domain = [widget code];
		NSRange test = [code rangeOfString:domain];
		if(test.location != NSNotFound)
			return [widget title];
	}
	
	return nil;
}

- (id)widgetWithIdentifier:(NSString*)identifier
{
	id widget = nil;
	
	widget = [library objectForKey:identifier];

	if(widget == nil) {
		NSEnumerator* enumerator = [[destinations allValues] objectEnumerator];
		NSMutableDictionary* destination;
		
		while(widget == nil && (destination = [enumerator nextObject])) {
			widget = [destination objectForKey:identifier];
		}
	}
	
	return widget;
}

- (NSArray*)widgetsWithIdentifier:(NSString*)identifier
{
	NSMutableArray* widgetArray = nil;
	id widget = nil;
	
	widget = [library objectForKey:identifier];

	if(widget) {
		widgetArray = [[NSMutableArray alloc] init];
		[widgetArray addObject:widget];
	}
	
	NSEnumerator* enumerator = [[destinations allValues] objectEnumerator];
	NSMutableDictionary* destination;
	
	while(destination = [enumerator nextObject]) {
		widget = [destination objectForKey:identifier];
		
		if(widget) {
			if(widgetArray == nil)
				widgetArray = [[NSMutableArray alloc] init];

			[widgetArray addObject:widget];
		}
	}
	
	return widgetArray;
}

- (void)import:(NSString*)path passBack:(NSMutableArray*)array releaseLibrary:(BOOL)releaseLibrary
{
	NSPropertyListFormat format;
	NSString* error = nil;
	
	NSData* data = [NSData dataWithContentsOfFile:path];
	NSMutableDictionary* plist = (NSMutableDictionary*) [NSPropertyListSerialization propertyListFromData:data
		mutabilityOption:NSPropertyListMutableContainersAndLeaves
		format:&format
		errorDescription:&error];

	if(plist) {
		NSEnumerator* enumerator = [[plist allKeys] objectEnumerator];
		NSString* identifier;
		NSDictionary* widgetData;
		
		if(releaseLibrary) {
			[library release];
			library = [[NSMutableDictionary alloc] initWithCapacity:[plist count]];
		}
		
		while((identifier = [enumerator nextObject])) {
			widgetData = [plist valueForKey:identifier];
			NSString* code = [widgetData objectForKey:@"code"];
			NSString* title = [widgetData objectForKey:@"title"];
			NSData* imageData = [widgetData objectForKey:@"image"];
			NSString* provider = [widgetData objectForKey:@"provider"];
			NSString* tags = [widgetData objectForKey:@"tags"];
			
			Widget* widget = (releaseLibrary ? nil : [self widgetWithIdentifier:identifier]);
			if(widget == nil) {
				widget = [[[Widget alloc] init] autorelease];
				[widget setTitle:title];
				[widget setCode:code];
				[widget setImage:imageData];
				[widget setIdentifier:identifier];
				[widget setProvider:provider];
				[widget setTags:tags];
				
				if(array)
					[array addObject:widget];
				
				[library setObject:widget forKey:identifier];
			}
		}
	}
	else {
		NSLog(error);
		[error release];
	}
}

- (void)export:(NSString*)path
{
	NSString* error = nil;

	NSMutableDictionary* plist = [NSMutableDictionary dictionaryWithCapacity:[library count]];
	NSEnumerator* enumerator = [[library allValues] objectEnumerator];
	Widget* widget;
	
	while(widget = [enumerator nextObject]) {
		NSString* title = [widget title];
		NSString* provider = [widget provider];
		NSString* tags = [widget tags];
		NSString* code = [widget code];
		NSData* image = [widget image];
		NSString* identifier = [widget identifier];

		NSArray* keys = [NSArray arrayWithObjects:@"title", @"provider", @"tags", @"code", @"image",  nil];
		NSArray* values = [NSArray arrayWithObjects:title, provider, tags, code, image, nil];
		NSMutableDictionary* slimWidget = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
		[plist setObject:slimWidget forKey:identifier];
	}

	NSData* data = [NSPropertyListSerialization dataFromPropertyList:plist
		format:NSPropertyListBinaryFormat_v1_0
		errorDescription:&error];

	if(data)
		[data writeToFile:path atomically:YES];
	else {
		NSLog(error);
		[error release];
	}
}

- (void)importTags:(NSString*)path name:(NSString*)name dictionary:(NSDictionary*)dictionary
{
	NSPropertyListFormat format;
	NSString* error = nil;
	NSData* data = nil;
	NSMutableDictionary* plist = nil;
	
	NSString* dataPath = [NSString stringWithFormat:@"%@/%@", path, name];
	NSFileManager* fm = [NSFileManager defaultManager];

	if([fm fileExistsAtPath:dataPath]) {
		data = [NSData dataWithContentsOfFile:dataPath];
		plist = (NSMutableDictionary*) [NSPropertyListSerialization propertyListFromData:data
			mutabilityOption:NSPropertyListMutableContainersAndLeaves
			format:&format
			errorDescription:&error];

		if(error) {
			NSLog(error);
			[error release];
		}
	}
	
	if(plist == nil || [plist count] == 0 || dictionary == nil || [dictionary count] == 0)
		return;
		
	NSEnumerator* enumerator = [[plist allKeys] objectEnumerator];
	NSString* identifier;
	
	while(identifier = [enumerator nextObject]) {
		Widget* widget = [dictionary objectForKey:identifier];
		if(widget)
			[widget setTags:[plist objectForKey:identifier]];
	}
}

- (void)exportTags:(NSString*)path name:(NSString*)name array:(NSArray*)array 
{
	if(array == nil || [array count] == 0)
		return;
		
	NSPropertyListFormat format;
	NSString* error = nil;
	NSData* data = nil;
	NSMutableDictionary* plist = nil;
	
	NSString* dataPath = [NSString stringWithFormat:@"%@/%@", path, name];
	NSFileManager* fm = [NSFileManager defaultManager];

	if([fm fileExistsAtPath:dataPath]) {
		data = [NSData dataWithContentsOfFile:dataPath];
		plist = (NSMutableDictionary*) [NSPropertyListSerialization propertyListFromData:data
			mutabilityOption:NSPropertyListMutableContainersAndLeaves
			format:&format
			errorDescription:&error];
			
		if(error) {
			NSLog(error);
			[error release];
			error = nil;
		}
	}
	
	if(plist == nil)
		plist = [[[NSMutableDictionary alloc] init] autorelease];
		
	NSEnumerator* enumerator = [array objectEnumerator];
	id widget;
	
	while(widget = [enumerator nextObject]) {
		NSString* tags = [widget tags];
		
		if([tags length])
			[plist setObject:tags forKey:[widget identifier]];
	}
	
	data = [NSPropertyListSerialization dataFromPropertyList:plist
		format:NSPropertyListBinaryFormat_v1_0
		errorDescription:&error];
		
	if(data)
		[data writeToFile:dataPath atomically:YES];
	else {
		NSLog(error);
		[error release];
	}
}

- (NSArray*)importCollection:(NSString*)key
{
	NSMutableArray* widgets = nil;

	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	
	if([fm fileExistsAtPath:libraryDirectory] == NO)
		return widgets;

	NSString* collectionDirectory = [NSString stringWithFormat:@"%@/%@.cube", libraryDirectory, key];
	if([fm fileExistsAtPath:collectionDirectory] == NO)
		return widgets;

	NSString* collectionPath = [NSString stringWithFormat:@"%@/CubeLibrary.plist", collectionDirectory];
	if([fm fileExistsAtPath:collectionPath] == NO)
		return widgets;

	NSPropertyListFormat format;
	NSString* error = nil;
	
	NSData* data = [NSData dataWithContentsOfFile:collectionPath];
	NSMutableArray* plist = (NSMutableArray*) [NSPropertyListSerialization propertyListFromData:data
		mutabilityOption:NSPropertyListMutableContainersAndLeaves
		format:&format
		errorDescription:&error];

	if(plist) {
		NSEnumerator* enumerator = [plist objectEnumerator];
		NSString* identifier;
			
		while((identifier = [enumerator nextObject])) {
			Widget* widget = [self widgetWithIdentifier:identifier];
			if(widget) {
				if(widgets == nil)
					widgets = [[NSMutableArray alloc] init];
					
				[widgets addObject:widget];
			}
		}
	}
	else {
		NSLog(error);
		[error release];
	}
	
	return widgets;
}

- (void)exportCollection:(NSString*)key array:(NSArray*)array
{
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* libraryDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube", NSHomeDirectory()];
	
	if([fm fileExistsAtPath:libraryDirectory]) {
		NSString* collectionDirectory = [NSString stringWithFormat:@"%@/%@.cube", libraryDirectory, key];
		if([fm fileExistsAtPath:collectionDirectory] == NO)
			[fm createDirectoryAtPath:collectionDirectory attributes:nil];

		if([fm fileExistsAtPath:collectionDirectory]) {
			if(array == nil || [array count] == 0)
				return;

			NSString* error = nil;
			NSData* data = nil;
			NSMutableArray* plist = nil;
			
			NSString* dataPath = [NSString stringWithFormat:@"%@/CubeLibrary.plist", collectionDirectory];
			
			if(plist == nil)
				plist = [[[NSMutableArray alloc] init] autorelease];
				
			NSEnumerator* enumerator = [array objectEnumerator];
			id widget;
			
			while(widget = [enumerator nextObject]) {
				[plist addObject:[widget identifier]];
			}
			
			data = [NSPropertyListSerialization dataFromPropertyList:plist
				format:NSPropertyListBinaryFormat_v1_0
				errorDescription:&error];
				
			if(data)
				[data writeToFile:dataPath atomically:YES];
			else {
				NSLog(error);
				[error release];
			}			
		}
	}
}

- (void)importFromAlpha:(NSString*)path
{
	alphaLibrary = [[NSMutableDictionary alloc] init];

	NSPropertyListFormat format;
	NSString* error = nil;
	
	NSData* data = [NSData dataWithContentsOfFile:path];
	NSMutableDictionary* plist = (NSMutableDictionary*) [NSPropertyListSerialization propertyListFromData:data
		mutabilityOption:NSPropertyListMutableContainersAndLeaves
		format:&format
		errorDescription:&error];

	if(plist) {
		NSEnumerator* enumerator = [[plist allValues] objectEnumerator];
		NSDictionary* widgetData;
		
		[library release];
		library = [[NSMutableDictionary alloc] initWithCapacity:[plist count]];
		
		while((widgetData = [enumerator nextObject])) {
			NSString* code = [widgetData objectForKey:@"code"];
			NSString* title = [widgetData objectForKey:@"title"];
			NSData* imageData = [widgetData objectForKey:@"image"];
			
			NSString* identifier = [WidgetManager identifierFromCode:code];
			NSString* provider = [self providerForCode:code];			
			
			NSArray* keys = [plist allKeysForObject:widgetData];
			NSString* alphaIdentifier = [NSString stringWithString:[keys objectAtIndex:0]];
			NSString* betaIdentifier = [NSString stringWithString:identifier];
			[alphaLibrary setObject:betaIdentifier forKey:alphaIdentifier];
			
			Widget* widget = [[[Widget alloc] init] autorelease];
			[widget setTitle:title];
			[widget setCode:code];
			if([imageData length] > 0)
				[widget setImage:imageData];
			[widget setIdentifier:identifier];
						
			if(provider)
				[widget setProvider:provider];
			
			[library setObject:widget forKey:identifier];
		}
	}
	else {
		NSLog(error);
		[error release];
	}
}

- (NSArray*)importFromCube:(NSString*)key
{
	NSMutableArray* widgets = nil;
	
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* cubeDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube/%@.cube", NSHomeDirectory(), key];

	if([fm fileExistsAtPath:cubeDirectory]) {
		NSArray* prefs = [fm directoryContentsAtPath:cubeDirectory];
		NSEnumerator* enumerator = [prefs objectEnumerator];
		NSString* directory;
			
		while((directory = [enumerator nextObject])) {
			if([directory hasSuffix:@".plist"] && [directory isEqualToString:@"CubeSettings.plist"] == NO && [directory isEqualToString:@"CubeLibrary.plist"] == NO) {
				NSString* alphaIdentifier = [directory substringToIndex:[directory length] - 6];
				NSString* betaIdentifier = [alphaLibrary objectForKey:alphaIdentifier];
				Widget* widget = [self widgetWithIdentifier:betaIdentifier];
				if(widget) {
					if(widgets == nil)
						widgets = [[NSMutableArray alloc] init];
						
					[widgets addObject:widget];
				}
			}
		}
	}
	
	return widgets;
		
#if 0
	NSString* plistPath = [NSString stringWithFormat:@"%@/CubeSettings.plist", cubeDirectory];

	NSPropertyListFormat format;
	NSString* error = nil;
	
	NSData* data = [NSData dataWithContentsOfFile:plistPath];
	NSMutableDictionary* plist = (NSMutableDictionary*) [NSPropertyListSerialization propertyListFromData:data
		mutabilityOption:NSPropertyListMutableContainersAndLeaves
		format:&format
		errorDescription:&error];

	if(plist) {
		NSArray* visibleWidgets = [plist objectForKey:@"VisibleWidgets"];

	}
#endif
}

- (void)importFromDashboard
{
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* directory;

	NSString* systemLibrary = @"/Library/Widgets";
	NSArray* systemWidgets = [fm directoryContentsAtPath:systemLibrary];
	NSEnumerator* systemEnumerator = [systemWidgets objectEnumerator];

	NSString* userLibrary = [NSString stringWithFormat:@"%@/Library/Widgets", NSHomeDirectory()];
	NSArray* userWidgets = [fm directoryContentsAtPath:userLibrary];
	NSEnumerator* userEnumerator = [userWidgets objectEnumerator];
	
	[dashboardLibrary release];
	dashboardLibrary = [[NSMutableDictionary alloc] initWithCapacity:[systemWidgets count] + [userWidgets count]];

#if 0
	NSString* offLibrary = [NSString stringWithFormat:@"%@/Library/Widgets (Disabled)", NSHomeDirectory()];
	NSArray* offWidgets = [fm directoryContentsAtPath:offLibrary];
	NSEnumerator* offEnumerator = [offWidgets objectEnumerator];
	
	BOOL hasDisabled = NO;

	while((directory = [offEnumerator nextObject])) {
		if([directory hasSuffix:@".wdgt"]) {
			NSString* widgetPath = [NSString stringWithFormat:@"%@/%@", offLibrary, directory];
			[self importDashboardWidget:widgetPath];
			
			hasDisabled = YES;
		}
	}

	if(hasDisabled)
		[[dashboardLibrary allValues] makeObjectsPerformSelector:@selector(setStatus:) withObject:[NSImage imageNamed:@"IconDisabled"]];
#endif

	while((directory = [systemEnumerator nextObject])) {
		if([directory hasSuffix:@".wdgt"]) {
			NSString* widgetPath = [NSString stringWithFormat:@"%@/%@", systemLibrary, directory];
			[self importDashboardWidget:widgetPath];
		}
	}

	while((directory = [userEnumerator nextObject])) {
		if([directory hasSuffix:@".wdgt"]) {
			NSString* widgetPath = [NSString stringWithFormat:@"%@/%@", userLibrary, directory];
			[self importDashboardWidget:widgetPath];
		}
	}

	NSString* tagDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube/_Tags", NSHomeDirectory()];
	[self importTags:tagDirectory name:@"_Dashboard" dictionary:dashboardLibrary];
}

- (void)importDashboardWidget:(NSString*)path
{
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* plistPath = [NSString stringWithFormat:@"%@/Info.plist", path];
	NSString* imagePath = [NSString stringWithFormat:@"%@/icon.png", path];

	NSPropertyListFormat format;
	NSString* error = nil;
	
	NSData* data = [NSData dataWithContentsOfFile:plistPath];
	NSMutableDictionary* plist = (NSMutableDictionary*) [NSPropertyListSerialization propertyListFromData:data
		mutabilityOption:NSPropertyListMutableContainersAndLeaves
		format:&format
		errorDescription:&error];

	if(plist) {
		NSString* name = [path lastPathComponent];
		NSString* title = [name substringToIndex:[name length] - 5];

		NSString* metaTitle = [plist objectForKey:@"CFBundleName"];
		if(metaTitle)
			title = metaTitle;
			
		NSString* dashIdentifier = [plist objectForKey:@"CFBundleIdentifier"];
		NSString* version = [plist objectForKey:@"CFBundleVersion"];
		NSString* identifier = [NSString stringWithFormat:@"dashboard:%@", dashIdentifier];
		NSImage* image = [[NSImage alloc] initWithContentsOfFile:imagePath];

		NSURL* pathURL = [NSURL fileURLWithPath:path];	
			
		Widget* widget = [[[Widget alloc] init] autorelease];
		[widget setTitle:title];
		[widget setCode:[pathURL path]];
		[widget setImage:[image TIFFRepresentation]];
		[widget setIdentifier:identifier];
		[widget setKey:dashIdentifier];
		[widget setVersion:version];
		[widget setCanEdit:[NSNumber numberWithBool:NO]];
		
		if([identifier hasPrefix:@"dashboard:com.apple.widget"])
			[widget setProvider:@"Apple, Inc."];
		else if([identifier hasPrefix:@"dashboard:com.amnestywidgets.widget"])
			[widget setProvider:@"AmnestyWidgets"];
		else if([identifier hasPrefix:@"dashboard:com.cs.widget"])
			[widget setProvider:@"Clearspring"];
		else if([identifier hasPrefix:@"dashboard:com.netvibes.widget"])
			[widget setProvider:@"Netvibes"];
		else {
			NSString* amnestyPath = [NSString stringWithFormat:@"%@/Generator.widgetplugin", path];
			if([fm fileExistsAtPath:amnestyPath])
				[widget setProvider:[NSString stringWithString:@"AmnestyWidgets"]];
	
			NSString* provider = nil;
			
			NSArray* components = [dashIdentifier componentsSeparatedByString:@"."];
			if([components count] > 1)
				provider = [NSString stringWithFormat:@"%@.%@", [components objectAtIndex:1], [components objectAtIndex:0]];
			else
				provider = [NSString stringWithString:identifier];
		
			[widget setProvider:provider];
		}
		
		[dashboardLibrary setObject:widget forKey:identifier];
	}
	else {
		NSLog(@"%@", error);
		[error release];
	}
}

- (void)importFromYahoo
{
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* directory;

	NSString* userLibrary = [NSString stringWithFormat:@"%@/Documents/Widgets", NSHomeDirectory()];
	NSArray* userWidgets = [fm directoryContentsAtPath:userLibrary];
	NSEnumerator* userEnumerator = [userWidgets objectEnumerator];
	
	[yahooLibrary release];
	yahooLibrary = [[NSMutableDictionary alloc] initWithCapacity:[userWidgets count]];

	while((directory = [userEnumerator nextObject])) {
		if([directory hasSuffix:@".widget"]) {
			NSString* widgetPath = [NSString stringWithFormat:@"%@/%@", userLibrary, directory];
			[self importYahooWidget:widgetPath];
		}
	}

	NSString* tagDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube/_Tags", NSHomeDirectory()];
	[self importTags:tagDirectory name:@"_Yahoo" dictionary:yahooLibrary];
}

- (void)importYahooWidget:(NSString*)path
{
	//NSFileManager* fm = [NSFileManager defaultManager];

	NSString* name = [path lastPathComponent];
	NSString* title = [name substringToIndex:[name length] - 7];
	NSString* identifier = [NSString stringWithFormat:@"yahoo:%@", name];
	NSImage* image = [[NSWorkspace sharedWorkspace] iconForFile:path];

#if 0
	NSString* version = nil;

	NSString* xml = nil;
		
	NSString* contentsPath = [NSString stringWithFormat:@"%@/Contents", path];
	if([fm fileExistsAtPath:contentsPath]) {
		NSString* xmlPath = [NSString stringWithFormat:@"%@/Contents/widget.xml", path];
		NSString* plistPath = [NSString stringWithFormat:@"%@/Contents/Info.plist", path];

		if([fm fileExistsAtPath:xmlPath]) {
			extern SInt32 gMacVersion;
			if(gMacVersion >= 0x1040)
				xml = [NSString stringWithContentsOfFile:xmlPath encoding:NSUTF8StringEncoding error:nil];
			else
				xml = [NSString stringWithContentsOfFile:xmlPath];
		}
		else if([fm fileExistsAtPath:plistPath]) {
		}

	}
	else {
		NSString* blob = nil;

		// load as NSData, seek bytes for metadata marker?
			
		if(blob) {
			NSRange start = [blob rangeOfString:@"<metadata>"];
			NSRange end = [blob rangeOfString:@"</metadata>"];
			
			if(start.location != NSNotFound && end.location != NSNotFound) {
				start.location += 11;
				start.length = (end.location - start.location);
				xml = [blob substringWithRange:start];
			}	
			
			NSLog(@"%d", [blob length]);
		}
	}
	
	if(xml) {
		NSString* metaIdentifier = nil;
		
		NSRange start = [xml rangeOfString:@"<identifier>"];
		NSRange end = [xml rangeOfString:@"</identifier>"];
		if(start.location != NSNotFound && end.location != NSNotFound) {
			start.location += 12;
			start.length = (end.location - start.location);
			metaIdentifier = [xml substringWithRange:start];
		}	
		
		if(metaIdentifier)
			identifier = [NSString stringWithFormat:@"yahoo:%@", metaIdentifier];
	}
#endif
	
	NSURL* pathURL = [NSURL fileURLWithPath:path];	
		
	Widget* widget = [[[Widget alloc] init] autorelease];
	[widget setTitle:title];
	[widget setCode:[pathURL path]];
	[widget setImage:[image TIFFRepresentation]];
	[widget setIdentifier:identifier];
	[widget setCanEdit:[NSNumber numberWithBool:NO]];
		
	[widget setProvider:@"Yahoo! Inc."];

	[yahooLibrary setObject:widget forKey:identifier];
}

- (BOOL)importFromDestinationProvider:(id)provider
{
	id defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];

	NSString* key = [(Provider*)provider key];
	NSString* destination = [key substringFromIndex:1];
	NSString* userKey = [NSString stringWithFormat:@"%@User", destination];	
	NSString* cubeKey = [NSString stringWithFormat:@"%@Cube", destination];	
	NSString* user = [defaults valueForKey:userKey];
	NSString* cube = [defaults valueForKey:cubeKey];
	
	if([user isEqualToString:@""] || [cube isEqualToString:@""])
		return NO;
		
	NSNumber* status = [(Provider*)provider status];
	if([status intValue] == ProviderStatusNeedsToLoad) {
		[provider setStatus:[NSNumber numberWithInt:ProviderStatusLoading]];
		[self importFromDestination:key user:user cube:cube];
	}
	
	return YES;
}

- (void)importFromDestination:(NSString*)destination user:(NSString*)user cube:(NSString*)cube
{
	NSString* urlString;
	NSString* destinationString = [[destination substringFromIndex:1] lowercaseString];
	
	if(
	   [destination isEqualToString:@"_Orkut"] ||
	   [destination isEqualToString:@"_MySpace"] ||
	   [destination isEqualToString:@"_Hi5"]
	)
		urlString = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/deskhost/library.php?dest=opensocial&host=%@.com&user=%@&cube=%@&key=%@",
			destinationString, user, cube, @"nil"];
	else
		urlString = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/deskhost/library.php?dest=%@&user=%@&cube=%@&key=%@",
			destinationString, user, cube, @"nil"];

	NSLog(@"%@", urlString);
	
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
		cachePolicy:NSURLRequestReloadIgnoringCacheData
		timeoutInterval:10.0];
		
	NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[sessionID setObject:[NSString stringWithFormat:@"%@:XML.LIB", destination] forKey:[connection description]];
}

- (void)parseXMLFromDestination:(NSString*)destination xml:(NSData*)xml
{		
	if(xml) {
		NSPropertyListFormat format;
		NSString* error = nil;

		NSMutableDictionary* plist = (NSMutableDictionary*) [NSPropertyListSerialization propertyListFromData:xml
			mutabilityOption:NSPropertyListMutableContainersAndLeaves
			format:&format
			errorDescription:&error];
			
		if(plist) {
			NSEnumerator* enumerator = [[plist allKeys] objectEnumerator];
			id key;
			NSDictionary* providerData;
			
			NSMutableDictionary* widgets = [[NSMutableDictionary alloc] initWithCapacity:[plist count]];
			
			while((key = [enumerator nextObject])) {
				providerData = [plist objectForKey:key];
			
				NSString* title = [providerData objectForKey:@"title"];
				NSString* code = [providerData objectForKey:@"code"];
				NSString* provider = [self providerForCode:code];

				NSString* trimmedCode = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				NSMutableString* cleanedCode = [trimmedCode mutableCopy];
				[cleanedCode replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [cleanedCode length])];
				[cleanedCode replaceOccurrencesOfString:@"synd=amnesty" withString:@"synd=open" options:0 range:NSMakeRange(0, [cleanedCode length])];
				NSString* identifier = [WidgetManager identifierFromCode:cleanedCode];
				
				Widget* widget = [[[Widget alloc] init] autorelease];
				[widget setTitle:title];
				[widget setIdentifier:identifier];
				[widget setKey:key];
				[widget setCode:cleanedCode];
				[widget setCanEdit:[NSNumber numberWithBool:NO]];
								
				if(provider)
					[widget setProvider:provider];
				
				[widgets setObject:widget forKey:identifier];
			}
			
			[destinations setObject:widgets forKey:destination];
			[widgets release];
		}
	}
}

- (NSString*)installToDestination:(NSString*)destination user:(NSString*)user cube:(NSString*)cube title:(NSString*)title code:(NSString*)code
{
	NSString* urlString;
	NSString* destinationString = [[destination substringFromIndex:1] lowercaseString];

	if(
	   [destination isEqualToString:@"_Orkut"] ||
	   [destination isEqualToString:@"_MySpace"] ||
	   [destination isEqualToString:@"_Hi5"]
	)
		urlString = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/deskhost/action.php?create=1&dest=opensocial&host=%@.com&user=%@&cube=%@&key=%@&title=%@&code=%@",
			destinationString, user, cube, @"nil", title, code];
	else
		urlString = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/deskhost/action.php?create=1&dest=%@&user=%@&cube=%@&key=%@&title=%@&code=%@",
			destinationString, user, cube, @"nil", title, code];
	
	return [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
}

- (NSString*)removeFromDestination:(NSString*)destination user:(NSString*)user cube:(NSString*)cube key:(NSString*)key
{
	NSString* urlString;
	NSString* destinationString = [[destination substringFromIndex:1] lowercaseString];
						
	if(
	   [destination isEqualToString:@"_Orkut"] ||
	   [destination isEqualToString:@"_MySpace"] ||
	   [destination isEqualToString:@"_Hi5"]
	)
		urlString = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/deskhost/action.php?remove=%@&dest=opensocial&host=%@.com&user=%@&cube=%@&key=%@",
			key, destinationString, user, cube, @"nil"];
	else
		urlString = [NSString stringWithFormat:@"http://www.amnestywidgets.com/hypercube/deskhost/action.php?remove=%@&dest=%@&user=%@&cube=%@&key=%@",
			key, destinationString, user, cube, @"nil"];
	
	return [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
}

- (void)launchWidgetWithCode:(NSString*)code
{
	NSTask* task = [[NSTask alloc] init];
	
	NSString* clientPath = [NSString stringWithFormat:@"%@/HypercubeClient.app/Contents/MacOS/HypercubeClient", [[NSBundle mainBundle] resourcePath]];
	[task setLaunchPath:clientPath];
	
	extern BOOL gPrivateWebKit;
	if(gPrivateWebKit) {
		NSProcessInfo* processInfo = [NSProcessInfo processInfo];
		NSMutableDictionary* environment = [[processInfo environment] mutableCopy];
		[environment setObject:@"/Library/Application Support/Mesa Dynamics/Frameworks" forKey:@"DYLD_FRAMEWORK_PATH"];
		[environment setObject:@"YES" forKey:@"WEBKIT_UNSET_DYLD_FRAMEWORK_PATH"];
		
		[task setEnvironment:environment];
	}

	NSString* identifier = [WidgetManager identifierFromCode:code];
	
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSDictionary* originalUdEntry = [ud persistentDomainForName:@"com.amnestywidgets.HypercubeWidgets"];
	NSMutableDictionary* udEntry;
	
	if(originalUdEntry) {
		udEntry =  [[NSMutableDictionary alloc] initWithCapacity:[originalUdEntry count] + 1];
		[udEntry addEntriesFromDictionary:originalUdEntry];
	}
	else
		udEntry = [[NSMutableDictionary alloc] initWithCapacity:1];

	if(udEntry) {
		[udEntry setObject:code forKey:identifier];
		
		[ud setPersistentDomain:udEntry forName:@"com.amnestywidgets.HypercubeWidgets"];
		[udEntry release];
		[ud synchronize];
	}

	NSString* widgetID = [NSString stringWithFormat:@"\"%@\"", identifier];
	NSString* widgetKey = [NSString stringWithFormat:@"\"%X\"", [WidgetManager markerFromCode:identifier]];
	[task setArguments:[NSArray arrayWithObjects:@"-widgetID", widgetID, @"-widgetKey", widgetKey, nil]];
																												
	[task launch];
}

- (void)exportWidgetWithCode:(NSString*)code title:(NSString*)title imageData:(NSData*)imageData platform:(NSString*)platform
{
	NSTask* task = [[NSTask alloc] init];
	
	NSString* clientPath = [NSString stringWithFormat:@"%@/HypercubeClient.app/Contents/MacOS/HypercubeClient", [[NSBundle mainBundle] resourcePath]];
	[task setLaunchPath:clientPath];
	
	extern BOOL gPrivateWebKit;
	if(gPrivateWebKit) {
		NSProcessInfo* processInfo = [NSProcessInfo processInfo];
		NSMutableDictionary* environment = [[processInfo environment] mutableCopy];
		[environment setObject:@"/Library/Application Support/Mesa Dynamics/Frameworks" forKey:@"DYLD_FRAMEWORK_PATH"];
		[environment setObject:@"YES" forKey:@"WEBKIT_UNSET_DYLD_FRAMEWORK_PATH"];
		
		[task setEnvironment:environment];
	}

	NSString* identifier = [WidgetManager identifierFromCode:code];
	
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSDictionary* originalUdEntry = [ud persistentDomainForName:@"com.amnestywidgets.HypercubeWidgets"];
	NSMutableDictionary* udEntry;
	
	if(originalUdEntry) {
		udEntry =  [[NSMutableDictionary alloc] initWithCapacity:[originalUdEntry count] + 1];
		[udEntry addEntriesFromDictionary:originalUdEntry];
	}
	else
		udEntry = [[NSMutableDictionary alloc] initWithCapacity:1];

	if(udEntry) {
		[udEntry setObject:code forKey:identifier];
		
		[ud setPersistentDomain:udEntry forName:@"com.amnestywidgets.HypercubeWidgets"];
		[udEntry release];
	}

	if(imageData) {
		NSDictionary* originalUdEntry = [ud persistentDomainForName:@"com.amnestywidgets.HypercubeImages"];
		NSMutableDictionary* udEntry;
		
		if(originalUdEntry) {
			udEntry =  [[NSMutableDictionary alloc] initWithCapacity:[originalUdEntry count] + 1];
			[udEntry addEntriesFromDictionary:originalUdEntry];
		}
		else
			udEntry = [[NSMutableDictionary alloc] initWithCapacity:1];
	
		if(udEntry) {
			[udEntry setObject:imageData forKey:identifier];
			
			[ud setPersistentDomain:udEntry forName:@"com.amnestywidgets.HypercubeImages"];
			[udEntry release];
		}
	}

	[ud synchronize];

	NSString* widgetID = [NSString stringWithFormat:@"\"%@\"", identifier];
	NSString* widgetKey = [NSString stringWithFormat:@"\"%X\"", [WidgetManager markerFromCode:identifier]];
	[task setArguments:[NSArray arrayWithObjects:@"-widgetID", widgetID, @"-widgetKey", widgetKey, @"-widgetExport", platform, @"-widgetName", title, nil]];
													
	[task launch];
}

- (void)importProvidersFromPath:(NSString*)path
{
	NSPropertyListFormat format;
	NSString* error = nil;
	
	NSData* data = [NSData dataWithContentsOfFile:path];
	NSMutableDictionary* plist = (NSMutableDictionary*) [NSPropertyListSerialization propertyListFromData:data
		mutabilityOption:NSPropertyListMutableContainersAndLeaves
		format:&format
		errorDescription:&error];

	if(plist) {
		NSEnumerator* enumerator = [plist keyEnumerator];
		id key;
		NSDictionary* providerData;
		
		[providers release];
		providers = [[NSMutableDictionary alloc] initWithCapacity:[plist count]];
		
		while((key = [enumerator nextObject])) {
			providerData = [plist objectForKey:key];
			
			NSString* identifier = nil;
			NSNumber* hidden = [providerData objectForKey:@"hidden"];
			if([hidden boolValue] == NO)
				identifier = [NSString stringWithFormat:@"publisher:%@", key];
			else
				identifier = [NSString stringWithFormat:@"lookup:%@", key];

			NSString* title = [providerData objectForKey:@"title"];
			NSString* tags = [providerData objectForKey:@"tags"];
			NSString* domain = [providerData objectForKey:@"domain"];
			
			NSString* iconPath = [NSString stringWithFormat:@"%@/Icons/%@.tif", [[NSBundle mainBundle] resourcePath], key];
			NSImage* icon = [[[NSImage alloc] initWithContentsOfFile:iconPath] autorelease];
			
			NSMutableString* cleanTags = [tags mutableCopy];
			[cleanTags replaceOccurrencesOfString:@"custom," withString:@"" options:0 range:NSMakeRange(0, [cleanTags length])];
			[cleanTags replaceOccurrencesOfString:@"," withString:@", " options:0 range:NSMakeRange(0, [cleanTags length])];
		
			Widget* widget = [[[Widget alloc] init] autorelease];
			[widget setTitle:title];
			[widget setIdentifier:identifier];
			[widget setTags:cleanTags];
			[widget setCode:domain];
			[widget setCanEdit:[NSNumber numberWithBool:NO]];
			[widget setCanLaunch:[NSNumber numberWithBool:NO]];
			
			if(icon)
				[widget setStatus:icon];
			
			[providers setObject:widget forKey:identifier];
		}
	}
	else {
		NSLog(@"%@", error);
		[error release];
	}
}

- (void)switchWidgets:(NSArray*)widgets
{
	{
		NSEnumerator* enumerator = [[clients allKeys] objectEnumerator];
		NSString* widgetID;
		
		while(widgetID = [enumerator nextObject]) {
			int index = [widgets indexOfObjectIdenticalTo:widgetID];
			if(index == NSNotFound) {
				NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:widgetID host:nil];
				if(proxy)
					[proxy handleHide:nil];
			}
		}
	}
	
	{
		NSEnumerator* enumerator = [widgets objectEnumerator];
		NSString* widgetID;
		
		while(widgetID = [enumerator nextObject]) {
			NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:widgetID host:nil];
			if(proxy)
				[proxy handleShow:nil];
			else {
				Widget* widget = [self widgetWithIdentifier:widgetID];
				NSString* code = [widget code];
				[self launchWidgetWithCode:code];
			}
		}
	}
}

- (IBAction)showAll:(id)sender
{
	NSEnumerator* enumerator = [[clients allKeys] objectEnumerator];
	NSString* widgetID;
	
	while(widgetID = [enumerator nextObject]) {
		NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:widgetID host:nil];
		if(proxy)
			[proxy handleShow:nil];
	}
}

- (IBAction)hideAll:(id)sender
{
	NSEnumerator* enumerator = [[clients allKeys] objectEnumerator];
	NSString* widgetID;
	
	while(widgetID = [enumerator nextObject]) {
		NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:widgetID host:nil];
		if(proxy)
			[proxy handleHide:nil];
	}
}

- (IBAction)closeAll:(id)sender
{
	NSEnumerator* enumerator = [[clients allKeys] objectEnumerator];
	NSString* widgetID;
	
	[openClients removeAllObjects];
	
	while(widgetID = [enumerator nextObject]) {
		NSString* mode = [clients objectForKey:widgetID];
		if([mode isEqualToString:@"loading"] || [mode isEqualToString:@"showing"]) {
			[openClients addObject:widgetID];
		}
		
		NSProxy* proxy = [NSConnection rootProxyForConnectionWithRegisteredName:widgetID host:nil];
		if(proxy)
			[proxy handleClose:nil];
	}
}

// NSConnection Proxy
- (void)widgetIsLoading:(NSString*)identifier
{
	NSArray* widgets = [self widgetsWithIdentifier:identifier];
	[widgets makeObjectsPerformSelector:@selector(setStatus:) withObject:[NSImage imageNamed:@"IconWebLoading"]];
	
	[clients setObject:@"loading" forKey:identifier];
	
	[self setCanHideAll:[NSNumber numberWithBool:YES]];
	[self setCanCloseAll:[NSNumber numberWithBool:YES]];
}

- (void)widgetIsHiding:(NSString*)identifier
{
	NSArray* widgets = [self widgetsWithIdentifier:identifier];
	[widgets makeObjectsPerformSelector:@selector(setStatus:) withObject:[NSImage imageNamed:@"IconSleeping"]];

	[clients setObject:@"hiding" forKey:identifier];

	[self setCanShowAll:[NSNumber numberWithBool:YES]];

	NSEnumerator* enumerator = [[clients allValues] objectEnumerator];
	NSString* mode;	
	while(mode = [enumerator nextObject]) {
		if([mode isEqualToString:@"loading"] || [mode isEqualToString:@"showing"]) {
			[self setCanHideAll:[NSNumber numberWithBool:YES]];
			return;
		}
	}

	[self setCanHideAll:[NSNumber numberWithBool:NO]];
}

- (void)widgetIsShowing:(NSString*)identifier
{
	NSArray* widgets = [self widgetsWithIdentifier:identifier];
	[widgets makeObjectsPerformSelector:@selector(setStatus:) withObject:[NSImage imageNamed:@"IconRunning"]];
	
	[clients setObject:@"showing" forKey:identifier];

	[self setCanHideAll:[NSNumber numberWithBool:YES]];

	NSEnumerator* enumerator = [[clients allValues] objectEnumerator];
	NSString* mode;
	while(mode = [enumerator nextObject]) {
		if([mode isEqualToString:@"hiding"]) {
			[self setCanShowAll:[NSNumber numberWithBool:YES]];
			return;
		}
	}

	[self setCanShowAll:[NSNumber numberWithBool:NO]];
}

- (void)widgetIsClosing:(NSString*)identifier
{
	[clients removeObjectForKey:identifier];

	NSArray* widgets = [self widgetsWithIdentifier:identifier];
	[widgets makeObjectsPerformSelector:@selector(setStatus:) withObject:[NSImage imageNamed:@"NoImage"]];

	BOOL showAll = NO;
	BOOL hideAll = NO;
	BOOL closeAll = NO;

	if([clients count]) {
		closeAll = YES;

		NSEnumerator* enumerator = [[clients allValues] objectEnumerator];
		NSString* mode;
		while(mode = [enumerator nextObject]) {
			if([mode isEqualToString:@"hiding"]) {
				showAll = YES;
			}
			else if([mode isEqualToString:@"loading"] || [mode isEqualToString:@"showing"]) {
				hideAll = YES;
			}
		}
	}

	[self setCanShowAll:[NSNumber numberWithBool:showAll]];
	[self setCanHideAll:[NSNumber numberWithBool:hideAll]];
	[self setCanCloseAll:[NSNumber numberWithBool:closeAll]];
}

// KVC
- (NSNumber*)canShowAll
{
	return [properties valueForKey:@"canShowAll"];
}

- (void)setCanShowAll:(NSNumber*)newCanShowAll
{
	[properties setValue:newCanShowAll forKey:@"canShowAll"];
}

- (NSNumber*)canHideAll
{
	return [properties valueForKey:@"canHideAll"];
}

- (void)setCanHideAll:(NSNumber*)newCanHideAll
{
	[properties setValue:newCanHideAll forKey:@"canHideAll"];
}

- (NSNumber*)canCloseAll
{
	return [properties valueForKey:@"canCloseAll"];
}

- (void)setCanCloseAll:(NSNumber*)newCanCloseAll
{
	[properties setValue:newCanCloseAll forKey:@"canCloseAll"];
}

// NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSString* description = [connection description];
	NSMutableData* connectionData = [sessionData objectForKey:description];
	if(connectionData == nil) {
		connectionData = [[NSMutableData alloc] initWithCapacity:[data length]];
		[sessionData setObject:connectionData forKey:description];
		[connectionData release];
	}
	
	[connectionData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSString* description = [connection description];
	NSString* connectionID = [sessionID objectForKey:description];
	if(connectionID) {
		if([connectionID hasSuffix:@":XML.LIB"]) {
			MainController* main = (MainController*) [NSApp delegate];
			Provider* provider = [main providerWithKey:[connectionID substringToIndex:[connectionID length] - 8]];
			[provider setStatus:[NSNumber numberWithInt:ProviderStatusNeedsToLoad]];
		}
	}

	[sessionData removeObjectForKey:description];
	[sessionID removeObjectForKey:description];	
	[connection release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString* description = [connection description];
	NSMutableData* connectionData = [sessionData objectForKey:description];
	NSString* connectionID = [sessionID objectForKey:description];
	
 	if(connectionData && [connectionData length] && connectionID) {
		if([connectionID hasSuffix:@":XML.LIB"]) {
			NSString* destination = [connectionID substringToIndex:[connectionID length] - 8];
			MainController* main = (MainController*) [NSApp delegate];
			Provider* provider = [main providerWithKey:destination];
			[provider setStatus:[NSNumber numberWithInt:ProviderStatusNone]];

			[self parseXMLFromDestination:destination xml:connectionData];

			NSMutableDictionary* widgets = [destinations objectForKey:destination];
			if(widgets) {
				[provider setWidgets:[widgets allValues]];

				NSString* tagDirectory = [NSString stringWithFormat:@"%@/Library/Preferences/Amnesty Hypercube/_Tags", NSHomeDirectory()];
				[self importTags:tagDirectory name:destination dictionary:widgets];
			}
		}
	}

	[sessionData removeObjectForKey:description];
	[sessionID removeObjectForKey:description];	
	[connection release];
}

@end


@implementation WidgetCanLaunchTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
	NSString* name = [value name];
    if([name isEqualToString:@"NoImage"])
		return [NSNumber numberWithBool:YES];
		
	return [NSNumber numberWithBool:NO];
}
@end


@implementation WidgetCanCloseTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
	NSString* name = [value name];
    if([name isEqualToString:@"NoImage"])
		return [NSNumber numberWithBool:NO];
		
	return [NSNumber numberWithBool:YES];
}
@end


@implementation WidgetCanHideTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if([[value name] isEqualToString:@"IconWebLoading"] || [[value name] isEqualToString:@"IconRunning"])
		return [NSNumber numberWithBool:YES];
		
	return [NSNumber numberWithBool:NO];
}
@end


@implementation WidgetCanShowTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if([[value name] isEqualToString:@"IconSleeping"])
		return [NSNumber numberWithBool:YES];
		
	return [NSNumber numberWithBool:NO];
}
@end


@implementation WebWidgetTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
	NSRange range = [value rangeOfString:@":"];
    if(range.location == NSNotFound)
		return [NSNumber numberWithBool:YES];
		
	return [NSNumber numberWithBool:NO];
}
@end


@implementation PlatformTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if([value isEqualToString:@"_Dashboard"] || [value isEqualToString:@"_Yahoo"])
		return [NSNumber numberWithBool:YES];
		
	return [NSNumber numberWithBool:NO];
}
@end


@implementation DestinationTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if(
	   [value isEqualToString:@"_Facebook"] ||
	   [value isEqualToString:@"_Friendster"] ||
	   [value isEqualToString:@"_Orkut"] ||
	   [value isEqualToString:@"_MySpace"] ||
	   [value isEqualToString:@"_Hi5"] ||
	   [value isEqualToString:@"_Bebo"]
	   )
		return [NSNumber numberWithBool:YES];
	
	return [NSNumber numberWithBool:NO];
}
@end

@implementation LinkedTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if(
	   [value isEqualToString:@"_Facebook"] ||
	   [value isEqualToString:@"_Friendster"] ||
	   [value isEqualToString:@"_Orkut"] ||
	   [value isEqualToString:@"_MySpace"] ||
	   [value isEqualToString:@"_Hi5"] ||
	   [value isEqualToString:@"_Bebo"]
	) {
		id defaults = [[NSUserDefaultsController sharedUserDefaultsController] values];

		NSString* destination = [value substringFromIndex:1];
		NSString* userKey = [NSString stringWithFormat:@"%@User", destination];	
		NSString* cubeKey = [NSString stringWithFormat:@"%@Cube", destination];
		NSString* user = [defaults valueForKey:userKey];
		NSString* cube = [defaults valueForKey:cubeKey];
		
		if([user isEqualToString:@""] == NO && [cube isEqualToString:@""] == NO)
			return [NSNumber numberWithBool:YES];
	}
	
	return [NSNumber numberWithBool:NO];
}
@end


@implementation SingleSelectionTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if([value intValue] == 1)
		return [NSNumber numberWithBool:YES];
		
	return [NSNumber numberWithBool:NO];
}
@end


@implementation EmptyStringTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if([value length] == 0)
		return [NSNumber numberWithBool:YES];
		
	return [NSNumber numberWithBool:NO];
}
@end
