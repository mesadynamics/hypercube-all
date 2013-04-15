//
//  GalleryGrid.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 5/22/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import "GalleryGrid.h"
#import "GalleryCell.h"


@implementation GalleryGrid

- (void)awakeFromNib
{
	featured = NO;
	fTitle = nil;
	oTitle = nil;
	fStroke = nil;
	oStroke = nil;

	[self setCellClass:[GalleryCell class]];
	[self setCellSize:NSMakeSize(100.0, 100.0)];
	[self setIntercellSpacing:NSMakeSize(40.0, 60.0)];
	[self setMode:NSRadioModeMatrix];
	[self setAllowsEmptySelection:YES];
	
	[self setAutoscroll:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:[self window]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];    

	[fTitle release];
 	[oTitle release];
	[fStroke release];
	[oStroke release];

	[super dealloc];
}

- (void)setFeatured:(BOOL)value
{
	featured = value;
}

- (void)drawRect:(NSRect)aRect
{
	[super drawRect:aRect];

	if(featured) {
		NSRect frame = [self frame];
		frame.origin.y = 0;
		frame.size.height = 30;
		//[fTitle drawWithRect:frame options:NSStringDrawingUsesLineFragmentOrigin];
		frame.origin.y = 160;
		//[oTitle drawWithRect:frame options:NSStringDrawingUsesLineFragmentOrigin];
		
		[[NSColor whiteColor] set];
		//[fStroke stroke];
		[oStroke stroke];
	}
}

- (void)resetCursorRects
{
	if([self isHidden]) 
		return;
		
	NSCursor* cursor = [NSCursor pointingHandCursor];
	
	NSArray* cells = [self cells];
	NSEnumerator* enumerator = [cells objectEnumerator];
	GalleryCell* cell;

	while((cell = [enumerator nextObject])) {
		if([cell isEnabled]) {
			NSInteger row, column;
			[self getRow:&row column:&column ofCell:cell];
			NSRect frame = [self cellFrameAtRow:row column:column];
			NSRect clip = NSIntersectionRect(frame, [self visibleRect]);
			if(NSIsEmptyRect(clip) == NO)
				[self addCursorRect:clip cursor:cursor];
		}
	}
}

// Notifications
- (void)windowDidResize:(NSNotification *)aNotification
{
	NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle alloc] init];
	[paraStyle autorelease];

    [paraStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
 	[paraStyle setAlignment:NSLeftTextAlignment];
	[paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
	[paraStyle setMaximumLineHeight:16.0];
	
	NSDictionary* txtDict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont fontWithName:@"Arial" size:15.0], NSFontAttributeName,
		[NSColor colorWithDeviceWhite:.90 alpha:1.0], NSForegroundColorAttributeName,
		paraStyle, NSParagraphStyleAttributeName,
		nil];

	[fTitle release];
	fTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"FeaturedProvider", @"") attributes:txtDict];

 	[oTitle release];
	oTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"OtherProvider", @"") attributes:txtDict];

	NSRect frame = [self frame];
	frame.origin.y = 0;
	frame.size.height = 30;
	
	[fStroke release];
	fStroke = [NSBezierPath bezierPath];
    [fStroke moveToPoint:NSMakePoint(frame.origin.x, frame.origin.y + 18.0)];
	[fStroke lineToPoint:NSMakePoint(frame.origin.x + frame.size.width, frame.origin.y + 18.0)];
	[fStroke setLineWidth:1.0];
	[fStroke retain];
	
	frame.origin.y = 144;

	[oStroke release];
	oStroke = [NSBezierPath bezierPath];
    [oStroke moveToPoint:NSMakePoint(frame.origin.x, frame.origin.y + 18.0)];
	[oStroke lineToPoint:NSMakePoint(frame.origin.x + frame.size.width, frame.origin.y + 18.0)];
	[oStroke setLineWidth:1.0];
	[oStroke retain];
}

@end
