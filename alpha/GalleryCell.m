//
//  GalleryCell.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/23/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "GalleryCell.h"
#import "NSString+Paths.h"
#import "NSImage+ScaleReflect.h"


@implementation GalleryCell

+ (NSImage*)getMirroredImage:(NSImage*)image scale:(BOOL)scale
{
	NSImage* scaledImage = image;
	if(scale)
		scaledImage = [NSImage scaleImage:image toSize:NSMakeSize(64.0, 64.0) alignX:0 alignY:-1];
		
	NSImage* reflection = [NSImage reflectImage:scaledImage];
	
	NSRect frame = NSMakeRect(0.0, 0.0, 100.0, 100.0);
	NSImage* mirror = [[NSImage alloc] initWithSize:frame.size];
	[mirror lockFocus];
		[scaledImage drawAtPoint:NSMakePoint(18.0, 36.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		[reflection drawAtPoint:NSMakePoint(18.0, -28.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.50];
	[mirror unlockFocus]; 

	return [mirror autorelease];
}

- (id)init
{
	if(self = [super init]) {
		identifier = nil;
		featured = NO;

		[self setBordered:NO];
		[self setBezeled:NO];
			
		[self setHighlightsBy:NSNoCellMask];
		[self setShowsStateBy:NSNoCellMask];
		[self setButtonType:NSMomentaryChangeButton];
		[self setImagePosition:NSImageAbove];

		SInt32 macVersion = 0;
		Gestalt(gestaltSystemVersion, &macVersion);
		
		if(macVersion >= 0x1040)
			[self setBackgroundColor:[NSColor colorWithDeviceWhite:0.05 alpha:1.0]];     
		
		[self setWraps:YES];
	}
	
	return self;
}

- (void)dealloc
{
	[identifier release];
	[super dealloc];
}

- (NSString*)getIdentifier
{
	return identifier;
}

- (void)setIdentifier:(NSString*)name
{
	[identifier release];
	identifier = [name copy];
}

- (void)setFeatured:(BOOL)value
{
	featured = value;
}

- (void)setGalleryImage:(NSImage*)image
{
	[self setImage:image];
}

- (void)setGalleryTitle:(NSString*)string
{
	NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle alloc] init];
	[paraStyle autorelease];

    [paraStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
 	[paraStyle setAlignment:NSCenterTextAlignment];
	[paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
	[paraStyle setMaximumLineHeight:16.0];
	
	NSColor* color = (featured ? [NSColor colorWithDeviceWhite:.90 alpha:1.0] : [NSColor colorWithDeviceWhite:.80 alpha:1.0]);
	
	NSDictionary* txtDict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont fontWithName:@"Arial" size:14.0], NSFontAttributeName,
		color, NSForegroundColorAttributeName,
		paraStyle, NSParagraphStyleAttributeName,
		nil];
		
	NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:string attributes:txtDict];
	[self setAttributedTitle:attrStr];
	[attrStr release];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if([self isEnabled]) {
		[super drawWithFrame:cellFrame inView:controlView];

		/*if(featured) {
			NSRect frame = NSMakeRect(cellFrame.size.width - 42.0, 2.0, 40.0, 40.0);
			frame.origin.x += cellFrame.origin.x;
			frame.origin.y += cellFrame.origin.y;
			[[NSImage imageNamed:@"Featured"] drawInRect:frame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		}*/
	}
}

- (void)drawImage:(NSImage*)image withFrame:(NSRect)frame inView:(NSView*)controlView
{
	frame.origin.y += 20.0;
	[super drawImage:image withFrame:frame inView:controlView];
}

- (NSRect)drawTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView
{
	if(title) {
		if(controlView)
			[controlView lockFocus];
			
		frame.size.height = 48;	
		[title drawWithRect:frame options:NSStringDrawingUsesLineFragmentOrigin];
		
		if(controlView)
			[controlView unlockFocus];
	}
	
	return frame;
}

@end
