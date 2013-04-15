//
//  WidgetManager.h
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 11/26/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WidgetManager : NSObject {
	NSMutableDictionary* library;
	
	NSMutableDictionary* alphaLibrary;
	
	NSMutableDictionary* dashboardLibrary;
	NSMutableDictionary* yahooLibrary;
	NSMutableDictionary* destinations;
	NSMutableDictionary* providers;	
	NSMutableDictionary* clients;

	NSMutableDictionary* properties;

	NSMutableDictionary* sessionData;
	NSMutableDictionary* sessionID;
	
	NSMutableArray* openClients;
}

+ (int)markerFromCode:(NSString*)code;
+ (NSString*)domainFromCode:(NSString*)code;
+ (NSString*)identifierFromCode:(NSString*)code;

- (NSMutableDictionary*)library;
- (NSMutableDictionary*)dashboardLibrary;
- (NSMutableDictionary*)yahooLibrary;
- (NSMutableDictionary*)destinations;
- (NSMutableDictionary*)providers;
- (NSMutableDictionary*)clients;

- (NSMutableArray*)openClients;

- (NSArray*)visibleProviders;
- (NSString*)providerForCode:(NSString*)code;

- (id)widgetWithIdentifier:(NSString*)identifier;
- (NSArray*)widgetsWithIdentifier:(NSString*)identifier;

- (void)import:(NSString*)path passBack:(NSMutableArray*)array releaseLibrary:(BOOL)releaseLibrary;
- (void)export:(NSString*)path;

- (void)importTags:(NSString*)path name:(NSString*)name dictionary:(NSDictionary*)dictionary;
- (void)exportTags:(NSString*)path name:(NSString*)name array:(NSArray*)array;

- (NSArray*)importCollection:(NSString*)key;
- (void)exportCollection:(NSString*)key array:(NSArray*)array;

- (void)importFromAlpha:(NSString*)path;
- (NSArray*)importFromCube:(NSString*)key;

- (void)importFromDashboard;
- (void)importDashboardWidget:(NSString*)path;
- (void)importFromYahoo;
- (void)importYahooWidget:(NSString*)path;

- (BOOL)importFromDestinationProvider:(id)provider;
- (void)importFromDestination:(NSString*)destination user:(NSString*)user cube:(NSString*)cube;
- (void)parseXMLFromDestination:(NSString*)destination xml:(NSData*)xml;
- (NSString*)installToDestination:(NSString*)destination user:(NSString*)user cube:(NSString*)cube title:(NSString*)title code:(NSString*)code;
- (NSString*)removeFromDestination:(NSString*)destination user:(NSString*)user cube:(NSString*)cube key:(NSString*)key;

- (void)importProvidersFromPath:(NSString*)path;

- (void)launchWidgetWithCode:(NSString*)code;
- (void)exportWidgetWithCode:(NSString*)code title:(NSString*)title imageData:(NSData*)imageData platform:(NSString*)platform;

- (void)switchWidgets:(NSArray*)widgets;

- (IBAction)showAll:(id)sender;
- (IBAction)hideAll:(id)sender;
- (IBAction)closeAll:(id)sender;

- (NSNumber*)canShowAll;
- (void)setCanShowAll:(NSNumber*)newCanShowAll;
- (NSNumber*)canHideAll;
- (void)setCanHideAll:(NSNumber*)newCanHideAll;
- (NSNumber*)canCloseAll;
- (void)setCanCloseAll:(NSNumber*)newCanCloseAll;

@end

@interface NSProxy (HypercubeClient)
- (id)handleHide:(id)sender;
- (id)handleShow:(id)sender;
- (id)handleClose:(id)sender;
@end


@interface WidgetCanLaunchTransformer: NSValueTransformer {}
@end

@interface WidgetCanCloseTransformer: NSValueTransformer {}
@end

@interface WidgetCanHideTransformer: NSValueTransformer {}
@end

@interface WidgetCanShowTransformer: NSValueTransformer {}
@end

@interface WebWidgetTransformer: NSValueTransformer {}
@end

@interface PlatformTransformer: NSValueTransformer {}
@end

@interface DestinationTransformer: NSValueTransformer {}
@end

@interface LinkedTransformer: NSValueTransformer {}
@end

@interface SingleSelectionTransformer: NSValueTransformer {}
@end

@interface EmptyStringTransformer: NSValueTransformer {}
@end





