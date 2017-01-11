/********* RIWS.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <RIWSFramework/RIWSFramework.h>
#import "BadElfListener.h"


@interface riws : CDVPlugin <RIWSDelegate>{
    
}

@property(nonatomic,strong)CDVInvokedUrlCommand *eventCommand;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, assign) double speed;
@property (nonatomic, assign) double heading;
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, retain) NSString* lastRemovedID;
@property (nonatomic, retain) NSString* lastShownID;
@property (nonatomic, assign) BOOL isLastOnRunway;

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
    if (![[NSUserDefaults standardUserDefaults]stringForKey:@"isFirst"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"True" forKey:@"isFirst"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadPolygons];
    }
    
    self.eventCommand = command;
    [[RIWS sharedManager]setDelegate:self];
    [[RIWS sharedManager]initializes];
//    [[GPSSession sharedController]setPlugin:self];
//    [[GPSSession sharedController]setCommand:command];
    [[BadElfListener sharedController]initConnectedDevices];
    
//        [NSTimer scheduledTimerWithTimeInterval:1.0
//                                         target:self
//                                       selector:@selector(simulateN2S)
//                                       userInfo:nil
//                                        repeats:NO];
    
}
-(void)simulateN2S{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
                       NSString *n2s = @"-77.42150244187999,39.0228742919202,0 -77.42160484620246,39.02286974297433,0 -77.42163045178441,39.02286861030525,0 -77.42167128650239,39.02286680752272,0 -77.42172577689561,39.02286440268998,0 -77.42177441809552,39.02286225168715,0 -77.42181744387666,39.02286188727877,0 -77.42188240628222,39.02285895533722,0 -77.42193394321212,39.02285662762361,0 -77.42198244857924,39.02285725277748,0 -77.4220365027393,39.02285472900995,0 -77.42210824924604,39.02285137438871,0 -77.42218808824009,39.0228451588434,0 -77.42222631547716,39.02284343162182,0 -77.42226028845938,39.02284190041315,0 -77.42229674760891,39.02284025685182,0 -77.42231627922803,39.02283937568538,0 -77.42235711831155,39.02283422403918,0 -77.42238249173364,39.02283530263501,0 -77.42241659336298,39.02283167846699,0 -77.4224617339413,39.02282875259296,0 -77.42248258605186,39.02282587642751,0 -77.42249139371371,39.02282552325049,0 ";
                       
                       NSArray* tArr = [n2s componentsSeparatedByString:@" "];
                       for (; ; ) {
                           
                       
                       for (int i =0; i < [tArr count]; i++) {
                           NSArray *ttArr= [[tArr objectAtIndex:i]componentsSeparatedByString:@","];
                           //        if (i==8) {
                           //            break;
                           //        }
                           if ([ttArr count]<2) {
                               continue;
                           }
                           NSString *tlongi = [ttArr objectAtIndex:0];
                           NSString *tLati = [ttArr objectAtIndex:1];
                           [[RIWS sharedManager]checkPointinPolygonLatitude:[tLati doubleValue] Longitude:[tlongi doubleValue] Speed:10 Heading:10];
//                           [NSThread sleepForTimeInterval:1.0f];
                       }
                       }
                       
//                       [NSTimer scheduledTimerWithTimeInterval:10.0
//                                                        target:self
//                                                      selector:@selector(simulateS2N)
//                                                      userInfo:nil
//                                                       repeats:NO];
                   });
}
-(void)simulateS2N{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
                       NSString *n2s = @"-77.42257052812694,39.02284480198515,0 -77.42254558479432,39.02284244506717,0 -77.42252119416209,39.02284380230371,0 -77.42249286089645,39.02284438116254,0 -77.42246610332147,39.02284483688361,0 -77.42242412031267,39.02284710599888,0 -77.42240267125928,39.02284827181609,0 -77.42235821450147,39.02285072320451,0 -77.4223151906977,39.02285307943477,0 -77.42227974196446,39.02285618574153,0 -77.42220286074063,39.02286045870276,0 -77.4221490315704,39.02286345802722,0 -77.42209604094924,39.02285983128024,0 -77.42202081922059,39.02286783686071,0 -77.42193838570988,39.02287228138474,0 -77.42183032274932,39.02288423156463,0 -77.42174025770582,39.02289096785093,0 -77.42164994549609,39.02290120903151,0 -77.42158635942157,39.02291021661701,0 ";
                       NSArray* tArr = [n2s componentsSeparatedByString:@" "];
                       for (int i =0; i < [tArr count]; i++) {
                           NSArray *ttArr= [[tArr objectAtIndex:i]componentsSeparatedByString:@","];
                           if ([ttArr count]<2) {
                               continue;
                           }
                           //       if (i==9) {
                           //           break;
                           //        }
                           NSString *tlongi = [ttArr objectAtIndex:0];
                           NSString *tLati = [ttArr objectAtIndex:1];
                           [[RIWS sharedManager]checkPointinPolygonLatitude:[tLati doubleValue] Longitude:[tlongi doubleValue] Speed:10 Heading:10];
                           [NSThread sleepForTimeInterval:1.0f];
                       }
                   });
}

#pragma mark - GPS Accessory Delegate methods

#pragma mark RIWS Delegates
-(void)RunwayIncrusionOccurredAtRunway:(NSString *)runwayName RunwayID:(NSString *)runwayID isTargetOnRunway:(BOOL)onRunway{
    BOOL toSend = FALSE;
    if (![self.lastShownID isEqualToString:runwayID]) {
        toSend = TRUE;
        self.lastShownID = runwayID;
        self.isLastOnRunway = onRunway;
    }else{
        if (self.isLastOnRunway != onRunway) {
            toSend = TRUE;
            self.isLastOnRunway = onRunway;
        }
    }
    if (!toSend) {
        return;
    }
    self.lastRemovedID = @"";
    NSString *textColor = @"e9f612";
    NSString *message = [NSString stringWithFormat:@"Vehicle is predicted to hit %@",runwayName];
    if (onRunway) {
        textColor = @"b20707";
        message = [NSString stringWithFormat:@"Vehicle is inside %@",runwayName];
    }
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
    
                       NSDictionary *incrusion = @{
                                                   @"IncursionEventID" : runwayID,
                                                   @"IncursionText" : message,
                                                   @"TextColor" : textColor,
                                                   @"AudioFile" : @"1.mp3",
                                                   @"Time" : [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]]
                                                   };
                       NSLog(@"Found : %@",incrusion);
                       CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:incrusion];
                       [pluginResult setKeepCallbackAsBool:TRUE];
                       [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCommand.callbackId ];
                   });
}

-(void)RunwayIncrusionRemovededFromRunway:(NSString *)runwayName RunwayID:(NSString *)runwayID{
    
    if (!runwayID) {
        runwayID = @"Started initially";
    }
    self.lastShownID = @"";
    self.isLastOnRunway = false;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
                       if ( [self.lastRemovedID isEqualToString:runwayID]) {
                           return;
                       }
                       self.lastRemovedID = runwayID;
                       NSDictionary *incrusion = @{
                                                   @"IncursionEventID" : runwayID,
                                                   @"Time" : [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]]
                                                   };
                       CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:incrusion];
                       [pluginResult setKeepCallbackAsBool:TRUE];
                       [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCommand.callbackId];
                   });
}

#pragma mark init predefined polygons

-(void)loadPolygons{
    
    BOOL canForceReplace = false;
    NSString *coordinates = @"-72.92690893597252,41.30645977867278,0 -72.92684150861093,41.30643110420776,0 -72.92680316438411,41.30648359755416,0 -72.92686850399156,41.30651235357643,0 -72.92690893597252,41.30645977867278,0 ";
    NSString *polygonGuid = @"1";
    NSString *polygonName = @"HOLD SHORT RSA 1 AT N";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-72.92605932891887,41.30610523352306,0 -72.92596164805151,41.30622472497294,0 -72.92674442876699,41.30656094359865,0 -72.92684356085593,41.30642954391565,0 -72.92605932891887,41.30610523352306,0 ";
    polygonGuid = @"2";
    polygonName = @"RSA Veoci 1";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-72.92628832909706,41.30749805977707,0 -72.92626522435289,41.30752638343166,0 -72.9263696833015,41.30756751964594,0 -72.92639174564724,41.30753935992261,0 -72.92628832909706,41.30749805977707,0 ";
    polygonGuid = @"3";
    polygonName = @"HOLD SHORT RSA 3";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-72.9260206131205,41.30614943462584,0 -72.9259341505182,41.30611370205123,0 -72.92587861129452,41.30618936331027,0 -72.92596065992656,41.30622480261703,0 -72.9260206131205,41.30614943462584,0 ";
    polygonGuid = @"4";
    polygonName = @"HOLD SHORT RSA 1 AT S";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-72.92677461662981,41.3070012970728,0 -72.9266728629832,41.30696397252252,0 -72.92628977363211,41.30749843374021,0 -72.92639235561154,41.30753859256003,0 -72.92677461662981,41.3070012970728,0 ";
    polygonGuid = @"5";
    polygonName = @"RSA Veoci 3";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-72.92522838436356,41.30695987856587,0 -72.9250736094253,41.30689605086667,0 -72.9249812463115,41.30702798471476,0 -72.92513365981949,41.30709453166839,0 -72.92522838436356,41.30695987856587,0 ";
    polygonGuid = @"6";
    polygonName = @"HOLD SHORT RSA 2";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-72.92513523249056,41.30709335182129,0 -72.92497960678955,41.30702722610935,0 -72.92450981856524,41.30768007927221,0 -72.92467420546311,41.30773751419669,0 -72.92513523249056,41.30709335182129,0 ";
    polygonGuid = @"7";
    polygonName = @"RSA Veoci 2";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
}

@end
