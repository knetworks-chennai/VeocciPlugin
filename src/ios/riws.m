/********* RIWS.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "GpsDataFormatters.h"
#import <RIWSFramework/RIWSFramework.h>


@interface riws : CDVPlugin <SimpleBadElfGpsManagerDelegate, BEGpsAccessoryDelegate, CLLocationManagerDelegate,RIWSDelegate>{
    
}

@property(nonatomic,strong)CDVInvokedUrlCommand *eventCommand;
@property (strong, nonatomic) SimpleBadElfGpsManagers *badElfGpsManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GpsDataFormatters *gpsDataFormatter;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, assign) double speed;
@property (nonatomic, assign) double heading;
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, retain) NSString* lastRemovedID;

-(void)addPolygon:(CDVInvokedUrlCommand*)command;
-(void)removePolygon:(CDVInvokedUrlCommand*)command;
-(void)removeAll:(CDVInvokedUrlCommand*)command;
-(void)initRIWS:(CDVInvokedUrlCommand*)command;
@end

@implementation riws

double DegreesToRadians(double degrees) {return degrees * M_PI / 180;};
double RadiansToDegrees(double radians) {return radians * 180/M_PI;};

- (void)addPolygon:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = @"Successfully added polygon";
    if ([command.arguments count]<4) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error while adding polygon"];
    }else{
        BOOL canForceReplace = [[command.arguments objectAtIndex:0]boolValue];
        NSString *coordinates = [command.arguments objectAtIndex:1];
        NSString *polygonGuid = [command.arguments objectAtIndex:2];
        NSString *polygonName = [command.arguments objectAtIndex:3];
        if([[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace]){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
        }else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error while adding polygon"];
        }
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)removePolygon:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = @"Successfully removed polygon";
    if ([command.arguments count]<1) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error while removing polygon"];
    }else{
        NSString *polygonGuid = [command.arguments objectAtIndex:0];
        if([[RIWS sharedManager]removePolygon:polygonGuid]){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
        }else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error while removing polygon"];
        }
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)removeAll:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = @"Successfully removed all polygon";
    BOOL error = false;
    if (error) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error while removing some or all polygon"];
    }else{
        if([[RIWS sharedManager]removeAllPolygons]){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
        }else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error while removing some or all polygon"];
        }
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)initRIWS:(CDVInvokedUrlCommand*)command{
    self.eventCommand = command;
    [[RIWS sharedManager]setDelegate:self];
    [[RIWS sharedManager]initializes];
    [self initializes];
    
}

-(void)initializes{
    [[SimpleBadElfGpsManagers sharedGpsManager] setDelegate:self];
    [[SimpleBadElfGpsManagers sharedGpsManager] setAutoOpenAccessories:YES];
    [[SimpleBadElfGpsManagers sharedGpsManager] start];
    self.gpsDataFormatter = [[GpsDataFormatters alloc] init];
    [self startLocationManagerUpdates];
    [self refresh];
}

#pragma mark - CoreLocation Methods

- (void)checkLocationServicesAuthorizationStatus
{
    /**
     ## Location Services Authorization
     Starting with iOS 8 you have to specifcially check for the user's privacy settings with Location Services
     
     User's can specify that an app be allowed to use their location always or only some of the time.
     It is important when designing your app to check and verify when and if the user has authorized
     iOS Location Services, otherwise your app may not be providing accurate location data to the user.
     
     */
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        NSLog(@"Status Check: Location Services Not Determined");
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        NSLog(@"Status Check: Location Services Restricted");
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        NSLog(@"Status Check: Location Services Denined");
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) // Used by iOS 7
    {
        NSLog(@"Status Check: Location Services Authorized");
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        NSLog(@"Status Check: Location Services Always Authorized");
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        NSLog(@"Status Check: Location Services Authorized When In Use");
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined)
    {
        NSLog(@"Status Changed: Not Determined");
    }
    else if (status == kCLAuthorizationStatusRestricted)
    {
        NSLog(@"Status Changed: Location Services Restricted");
    }
    else if (status == kCLAuthorizationStatusDenied)
    {
        NSLog(@"Status Changed: Location Services Denied");
    }
    else if (status == kCLAuthorizationStatusAuthorized) // Used by iOS 7
    {
        NSLog(@"Status Changed: Location Services Authorized");
    }
    else if (status == kCLAuthorizationStatusAuthorizedAlways)
    {
        NSLog(@"Status Changed: Location Services Always Authorized");
    }
    else if (status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        NSLog(@"Status Changed: Location Services Authorized When In Use");
    }
}

- (void)startLocationManagerUpdates {
    CLLocationManager *locationManager = self.locationManager;
    if (locationManager == nil) {
        locationManager = [CLLocationManager new];
        self.locationManager = locationManager;
        self.locationManager.delegate = self;
        
        // Check for iOS 8 CoreLocation Framework, if not just start location updates
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    [locationManager startUpdatingLocation];
}

- (void)stopLocationManagerUpdates {
    CLLocationManager *locationManager = self.locationManager;
    if (locationManager != nil) {
        [locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self refresh];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        // Handle Location Services Denied
    } else {
        // Handle any other Location Services error
    }
}

- (CLLocationCoordinate2D)currentCoordinate {
    id<BEGpsAccessory> hardware = self.badElfGpsManager.selectedHardware;
    if (hardware != nil) {
        id<BEGpsLocation> location = hardware.currentLocation;
        if (location.gpsLockType > BE_GPS_LOCK_TYPE_OFF_OR_SEARCHING) {
            if (location != nil) {
                CLLocationDegrees latitude = location.latitudeDegrees;
                CLLocationDegrees longitude = location.longitudeDegrees;
                
                latitude = MIN(90.0, latitude);
                latitude = MAX(-90.0, latitude);
                longitude = MIN(180.0, longitude);
                longitude = MAX(-180.0, longitude);
                
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                return coordinate;
            }
        }
    }
    CLLocationManager *locationManager = self.locationManager;
    if (locationManager != nil) {
        CLLocation *location = locationManager.location;
        if (location != nil) {
            return location.coordinate;
        }
    }
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0, 0);
    return coordinate;
}


#pragma mark - GPS Accessory Delegate methods

/**
 The GPS Accessory Delegate methods are the key to being notified when updates from the SDK and Bad Elf
 come through. Updates come through on each refresh cycle (1Hz to 10Hz)
 
 */

- (void)gpsAccessory:(id<BEGpsAccessory>)accessory locationUpdated:(id<BEGpsLocation>)location {
    [self refresh];
}

- (void)gpsAccessory:(id<BEGpsAccessory>)accessory satellitesUpdated:(NSArray*)satellites {
    [self refresh];
}

- (void)gpsAccessory:(id<BEGpsAccessory>)accessory asciiUpdated:(NSString*)ascii {
    [self refresh];
}

- (void)gpsAccessoryStatusUpdated:(id<BEGpsAccessory>)accessory {
    [self refresh];
}

- (void)gpsAccessoryConnected:(id<BEGpsAccessory>)accessory {
    
    //[self.badElfGpsManager openAccessory:accessory]; // only needed if autoOpen not enabled on BadElfGpsManager
    [self refresh];
}
- (void) gpsAccessoryDisconnected:(id<BEGpsAccessory>)accessory {
    
    [self refresh];
}


- (void) refresh {
    if (self.isProcessing) {
        return;
    }
    self.isProcessing = TRUE;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
                       id<BEGpsAccessory> gps = [[SimpleBadElfGpsManagers sharedGpsManager] selectedHardware];
                       id <BEGpsLocation> location = gps.currentLocation;
                       if (gps) {
                           if (location) {
                               BOOL locked = (location.gpsLockType != BE_GPS_LOCK_TYPE_OFF_OR_SEARCHING);
                               if (locked) {
                                   double latitude =[[self.gpsDataFormatter customlatitudeStringFromDegree:(location.latitudeDegrees)]doubleValue];
                                   double longitude =[[self.gpsDataFormatter customlongitudeStringFromDegree:(location.longitudeDegrees)]doubleValue];
                                   self.speed = location.speedKph;
                                   self.heading =  (int)(location.trackDeciDegrees / 10.0);
                                   [[RIWS sharedManager]checkPointinPolygonLatitude:latitude Longitude:longitude Speed:self.speed Heading:self.heading];
                               }
                           }
                       }
                       self.isProcessing = FALSE;
                   });
}

#pragma mark RIWS Delegates
-(void)RunwayIncrusionOccurredAtRunway:(NSString *)runwayName RunwayID:(NSString *)runwayID isTargetOnRunway:(BOOL)onRunway{
    
    NSString *textColor = @"e9f612";
    NSString *message = [NSString stringWithFormat:@"Vehicle is predicted to hit %@",runwayName];
    if (onRunway) {
        textColor = @"b20707";
        message = [NSString stringWithFormat:@"Vehicle is inside %@",runwayName];
    }
    
    NSDictionary *incrusion = @{
                                @"IncursionEventID" : runwayID,
                                @"IncursionText" : message,
                                @"TextColor" : textColor,
                                @"AudioFile" : @"1.mp3"
                                };
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:incrusion];
    [pluginResult setKeepCallbackAsBool:TRUE];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCommand.callbackId];
}

-(void)RunwayIncrusionRemovededFromRunway:(NSString *)runwayName RunwayID:(NSString *)runwayID{
    if (!runwayID) {
        runwayID = @"Started initially";
    }
    if ( [self.lastRemovedID isEqualToString:runwayID]) {
        return;
    }
    self.lastRemovedID = runwayID;
    NSDictionary *incrusion = @{
                                @"IncursionEventID" : runwayID
                                };
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:incrusion];
    [pluginResult setKeepCallbackAsBool:TRUE];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCommand.callbackId];
}
@end
