//
//  Widget.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/27/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "Widget.h"


NSString* CopiedRowsType = @"HypercubeCopiedWidgets";

@implementation Widget

- (id)init
{
	if(self = [super init]) {
		NSString* title = NSLocalizedString(@"UntitledWidget", @"");
		NSString* identifier = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
		
		NSArray* keys = [NSArray arrayWithObjects:@"title", @"provider", @"tags", @"code", @"image", @"identifier", @"key", @"version", @"status", @"canEdit", @"canLaunch",  nil];
		NSArray* values = [NSArray arrayWithObjects:title, @"", @"", @"", [NSData data], identifier, @"", @"", [NSImage imageNamed:@"NoImage"], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], nil];
		properties = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
	}

	return self;
}

- (id)initWithWidget:(Widget*)widget
{
	if(self = [super init]) {
		NSString* title = [[widget title] copy];
		NSString* provider = [[widget provider] copy];
		NSString* tags = [[widget tags] copy];
		NSString* code = [[widget code] copy];
		NSData* image = [[widget image] copy];
		NSString* identifier = [[widget identifier] copy];
		NSString* index = [[widget key] copy];
		NSString* version = [[widget version] copy];
		
		NSString* statusName = [[widget status] name];
		NSImage* status = [NSImage imageNamed:statusName];
		
		NSArray* keys = [NSArray arrayWithObjects:@"title", @"provider", @"tags", @"code", @"image", @"identifier", @"key", @"version", @"status", @"canEdit", @"canLaunch", nil];
		NSArray* values = [NSArray arrayWithObjects:title, provider, tags, code, image, identifier, index, version, status, [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES], nil];
		properties = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
	}

	return self;
}

- (void)dealloc
{
    [properties release];
    [super dealloc];
}

- (NSMutableDictionary*)properties
{
    return properties;
}

- (void)setProperties:(NSDictionary*)newProperties
{
    if(properties != newProperties) {
        [properties autorelease];
        properties = [[NSMutableDictionary alloc] initWithDictionary:newProperties];
    }
}

- (NSString*)title
{
	return [properties valueForKey:@"title"];
}

- (void)setTitle:(NSString*)newTitle
{
	[properties setValue:newTitle forKey:@"title"];
}

- (NSString*)provider
{
	return [properties valueForKey:@"provider"];
}

- (void)setProvider:(NSString*)newProvider
{
	[properties setValue:newProvider forKey:@"provider"];
}

- (NSString*)tags
{
	return [properties valueForKey:@"tags"];
}

- (void)setTags:(NSString*)newTags
{
	[properties setValue:newTags forKey:@"tags"];
}

- (NSString*)code
{
	return [properties valueForKey:@"code"];
}

- (void)setCode:(NSString*)newCode
{
	[properties setValue:newCode forKey:@"code"];
}

- (NSData*)image
{
	return [properties valueForKey:@"image"];
}

- (void)setImage:(NSData*)newImage
{
	[properties setValue:newImage forKey:@"image"];
}

- (NSString*)identifier
{
	return [properties valueForKey:@"identifier"];
}

- (void)setIdentifier:(NSString*)newIdentifier
{
	[properties setValue:newIdentifier forKey:@"identifier"];
}

- (NSString*)key
{
	return [properties valueForKey:@"key"];
}

- (void)setKey:(NSString*)newKey
{
	[properties setValue:newKey forKey:@"key"];
}

- (NSString*)version
{
	return [properties valueForKey:@"version"];
}

- (void)setVersion:(NSString*)newVersion
{
	[properties setValue:newVersion forKey:@"version"];
}

- (NSImage*)status
{
	return [properties valueForKey:@"status"];
}

- (void)setStatus:(NSImage*)newStatus
{
	[properties setValue:newStatus forKey:@"status"];
}

- (NSNumber*)canEdit
{
	return [properties valueForKey:@"canEdit"];
}

- (void)setCanEdit:(NSNumber*)newCanEdit
{
	[properties setValue:newCanEdit forKey:@"canEdit"];
}

- (NSNumber*)canLaunch
{
	return [properties valueForKey:@"canLaunch"];
}

- (void)setCanLaunch:(NSNumber*)newCanLaunch
{
	[properties setValue:newCanLaunch forKey:@"canLaunch"];
}

@end


@implementation NSImage (CompareAdditions)

- (NSComparisonResult)compare:(id)anImage
{
	return [[self name] compare:[anImage name]];
}

@end