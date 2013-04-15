//
//  Provider.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/27/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef enum {
    ProviderStatusNone = 0,
    ProviderStatusNeedsToLoad = 1,
	ProviderStatusLoading = 2
} ProviderStatus;

extern NSString* MovedRowsType;

@interface Provider : NSObject {
	NSMutableDictionary* properties;
	NSMutableArray* widgets;
}

- (NSMutableDictionary*)properties;
- (void)setProperties:(NSDictionary*)newProperties;

- (NSMutableArray*)widgets;
- (void)setWidgets:(NSArray*)newWidgets;

- (NSString*)title;
- (void)setTitle:(NSString*)newTitle;

- (NSString*)key;
- (void)setKey:(NSString*)newKey;

- (NSString*)type;
- (void)setType:(NSString*)newType;

- (NSImage*)icon;
- (void)setIcon:(NSImage*)newIcon;

- (NSNumber*)canEdit;
- (void)setCanEdit:(NSNumber*)newCanEdit;

- (NSNumber*)canSelect;
- (void)setCanSelect:(NSNumber*)newCanSelect;

- (NSNumber*)canDrop;
- (void)setCanDrop:(NSNumber*)newCanDrop;

- (NSNumber*)canLink;
- (void)setCanLink:(NSNumber*)newCanLink;

- (NSNumber*)status;
- (void)setStatus:(NSNumber*)newStatus;

@end
