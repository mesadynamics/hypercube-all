//
//  WidgetManager.m
//  HypercubeClient
//
//  Created by Danny Espinoza on 12/11/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "WidgetManager.h"
#import "WidgetController.h"


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

+ (void)exportToDashboard:(NSString*)code title:(NSString*)name image:(NSImage*)image identifier:(NSString*)identifier dashboard:(NSString*)dashboardID width:(int)width height:(int)height
{
	NSString* widgetName = nil;
	
	{
		NSString* tempBlock1 = [NSString stringWithFormat:@"%@%@", identifier, @"Generator"];
		int version1 = [WidgetManager markerFromCode:tempBlock1];

		NSString* tempBlock2 = [NSString stringWithFormat:@"%@%@", @"widgetplugin", identifier];
		int version2 = [WidgetManager markerFromCode:tempBlock2];
	
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

	if(widgetName == nil)
		return;

	NSString* userWidgetFolder = [NSString stringWithFormat:@"%@/Library/Widgets", NSHomeDirectory()];

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

- (id)init
{
	if(self = [super init]) {
		widget = nil;
	}
	
	return self;
}

- (id)initWithController:(NSWindowController*)controller
{
	if(self = [super init])
		widget = [controller retain];

	return self;
}

- (void)dealloc
{
	[widget release];
	[super dealloc];
}

- (IBAction)handleHide:(id)sender
{
	[(WidgetController*)widget handleHide:sender];
}

- (IBAction)handleShow:(id)sender
{
	[(WidgetController*)widget handleShow:sender];
}

- (IBAction)handleClose:(id)sender
{
	[(WidgetController*)widget handleClose:sender];
}

@end
