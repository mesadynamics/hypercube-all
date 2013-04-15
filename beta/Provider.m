//
//  Provider.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/27/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "Provider.h"


NSString* MovedRowsType = @"HypercubeMovedProvider";

@implementation Provider

- (id)init
{
	if(self = [super init]) {
		NSString* title = NSLocalizedString(@"Untitled", @"");
		NSString* widgetType = NSLocalizedString(@"Widgets", @"");
		
		NSArray* keys = [NSArray arrayWithObjects:@"title", @"key", @"type", @"icon", @"canEdit", @"canSelect", @"canDrop", @"canLink", @"status", nil];
		NSArray* values = [NSArray arrayWithObjects:title, @"", widgetType, [NSImage imageNamed:@"IconCube"], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], [NSNumber numberWithInt:ProviderStatusNone], nil];
		properties = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];

		widgets = [[NSMutableArray alloc] init];
	}

	return self;
}

- (void)dealloc
{
    [properties release];
    [widgets release];
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

- (NSMutableArray*)widgets
{
    return widgets;
}

- (void)setWidgets:(NSArray*)newWidgets
{
    if(widgets != newWidgets) {
        [widgets autorelease];
        widgets = [[NSMutableArray alloc] initWithArray:newWidgets];
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

- (NSString*)key
{
	return [properties valueForKey:@"key"];
}

- (void)setKey:(NSString*)newKey
{
	[properties setValue:newKey forKey:@"key"];
}

- (NSString*)type
{
	return [properties valueForKey:@"type"];
}

- (void)setType:(NSString*)newType
{
	[properties setValue:newType forKey:@"type"];
}

- (NSImage*)icon
{
	return [properties valueForKey:@"icon"];
}

- (void)setIcon:(NSImage*)newIcon
{
	[properties setValue:newIcon forKey:@"icon"];
}

- (NSNumber*)canEdit
{
	return [properties valueForKey:@"canEdit"];
}

- (void)setCanEdit:(NSNumber*)newCanEdit
{
	[properties setValue:newCanEdit forKey:@"canEdit"];
}

- (NSNumber*)canSelect
{
	return [properties valueForKey:@"canSelect"];
}

- (void)setCanSelect:(NSNumber*)newCanSelect
{
	[properties setValue:newCanSelect forKey:@"canSelect"];
}

- (NSNumber*)canDrop
{
	return [properties valueForKey:@"canDrop"];
}

- (void)setCanDrop:(NSNumber*)newCanDrop
{
	[properties setValue:newCanDrop forKey:@"canDrop"];
}

- (NSNumber*)canLink
{
	return [properties valueForKey:@"canLink"];
}

- (void)setCanLink:(NSNumber*)newCanLink
{
	[properties setValue:newCanLink forKey:@"canLink"];
}

- (NSNumber*)status
{
	return [properties valueForKey:@"status"];
}

- (void)setStatus:(NSNumber*)newStatus
{
	[properties setValue:newStatus forKey:@"status"];
}

@end
