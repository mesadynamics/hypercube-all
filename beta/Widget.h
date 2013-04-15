//
//  Widget.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/27/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


extern NSString* CopiedRowsType;

@interface Widget : NSObject {
	NSMutableDictionary* properties;
}

- (id)initWithWidget:(Widget*)widget;

- (NSMutableDictionary*)properties;
- (void)setProperties:(NSDictionary*)newProperties;

- (NSString*)title;
- (void)setTitle:(NSString*)newTitle;

- (NSString*)provider;
- (void)setProvider:(NSString*)newProvider;

- (NSString*)tags;
- (void)setTags:(NSString*)newTags;

- (NSString*)code;
- (void)setCode:(NSString*)newCode;

- (NSData*)image;
- (void)setImage:(NSData*)newImage;

- (NSString*)identifier;
- (void)setIdentifier:(NSString*)newIdentifier;

- (NSString*)key;
- (void)setKey:(NSString*)newKey;

- (NSString*)version;
- (void)setVersion:(NSString*)newVersion;

- (NSImage*)status;
- (void)setStatus:(NSImage*)newStatus;

- (NSNumber*)canEdit;
- (void)setCanEdit:(NSNumber*)newCanEdit;

- (NSNumber*)canLaunch;
- (void)setCanLaunch:(NSNumber*)newCanLaunch;

@end


@interface NSImage (CompareAdditions)
- (NSComparisonResult)compare:(id)anImage;
@end;
