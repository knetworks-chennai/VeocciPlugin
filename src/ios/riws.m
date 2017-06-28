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

@property (nonatomic, retain) NSMutableArray* parentArray;
@property (nonatomic, retain) NSMutableArray* childArray;
@property (nonatomic, retain) NSMutableArray* disabledParentArray;

-(void)addPolygon:(CDVInvokedUrlCommand*)command;
-(void)removePolygon:(CDVInvokedUrlCommand*)command;
-(void)removeAll:(CDVInvokedUrlCommand*)command;
-(void)initRIWS:(CDVInvokedUrlCommand*)command;
-(void)disableLayers:(CDVInvokedUrlCommand*)command;
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

- (void)disableLayers:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = @"Successfully disabled polygon";
    if ([command.arguments count]<1) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error while disabling polygon"];
    }else{
        NSString *disabledPoly = [command.arguments objectAtIndex:0];
        self.disabledParentArray =(NSMutableArray*) [disabledPoly componentsSeparatedByString:@","];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void)initGrouping{
    self.parentArray =  [[NSMutableArray alloc] initWithObjects: @"PDX01", @"PDX02", @"PDX03", @"PDX04", @"PDX05", nil];
    self.childArray = [[NSMutableArray alloc]init];
    [self.childArray addObject:[@"HOLD SHORT LINE 10R AT B1,HOLD SHORT LINE 10R/28L AT B2,HOLD SHORT LINE 10R/28L AT E (NORTH),HOLD SHORT LINE 10R/28L AT B3,HOLD SHORT LINE 10R/28L AT B4,HOLD SHORT LINE 10R/28L AT B5,HOLD SHORT LINE 10R/28L AT B6,HOLD SHORT LINE 10R/28L AT B8,HOLD SHORT LINE 10R/28L AT C8,HOLD SHORT LINE 10R/28L AT C6,HOLD SHORT LINE 10R/28L AT F,HOLD SHORT LINE 10R/28L AT E (SOUTH),HOLD SHORT LINE 10R AT C1" componentsSeparatedByString:@","]];
    [self.childArray addObject:[@"HOLD SHORT LINE 10L AT K1,HOLD SHORT LINE 10L/28R AT E,RSA 10L/28R BETWEEN E AND T,HOLD SHORT LINE 10L/28R AT T,HOLD SHORT LINE 10L/28R AT A6,HOLD SHORT LINE 10L/28R AT A5,HOLD SHORT LINE 10L/28R AT A4,HOLD SHORT LINE 10L/28R AT A3,HOLD SHORT LINE 10L/28R AT A2,HOLD SHORT LINE 28R AT A1" componentsSeparatedByString:@","]];
    [self.childArray addObject:[@"HOLD SHORT LINE 21 AT K (EAST),HOLD SHORT LINE 3/21 AT M (EAST),HOLD SHORT LINE 3/21 AT B (EAST),HOLD SHORT LINE 3/21 AT C (EAST),HOLD SHORT LINE 3/21 AT E4,HOLD SHORT LINE 3 AT E6,HOLD SHORT LINE 3/21 AT G,HOLD SHORT LINE 3/21 AT C (WEST),HOLD SHORT LINE 3/21 AT B (WEST),HOLD SHORT 3/21 AT M (WEST),HOLD SHORT LINE 3/21 AT H,HOLD SHORT LINE 21 AT K (WEST)" componentsSeparatedByString:@","]];
    [self.childArray addObject:[@"HOLD SHORT ILS GS 28L AT C,ILS GS AREA 28R,ILS GS AREA 10L,ILS GS AREA 28L,ILS GS AREA 10R,HOLD SHORT ILS GS 10R @ C" componentsSeparatedByString:@","]];
    [self.childArray addObject:[@"Test Runway, Vish Home, Vish Actual Home, TEST RSA ILS SA, HOLD SHORT LINE - INDMEX - AT  - TEST, TerragoOffice" componentsSeparatedByString:@","]];
}
-(void)initRIWS:(CDVInvokedUrlCommand*)command{
    if (![[NSUserDefaults standardUserDefaults]stringForKey:@"isFirst"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"True" forKey:@"isFirst"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadPolygons];
    }
    self.disabledParentArray = [[NSMutableArray alloc]init];
    [self initGrouping];
    
    self.eventCommand = command;
    [[RIWS sharedManager]setDelegate:self];
    [[RIWS sharedManager]initializes];
    
    [[RIWS sharedManager]initStompwithServer:@"surfpad.ddns.net" Port:61626 Login:@"indmex" Password:@"9jrk4d1!" withSSL:TRUE forPublishingat:@"/topic/IndMEXADSBTopic"];
    [[RIWS sharedManager]initSTOMP];
    
    
    //    [[GPSSession sharedController]setPlugin:self];
    //    [[GPSSession sharedController]setCommand:command];
    [[BadElfListener sharedController]initConnectedDevices];
    [[BadElfListener sharedController]setCommand:command];
    [[BadElfListener sharedController]setCommandDelegate:self.commandDelegate];
    //        [NSTimer scheduledTimerWithTimeInterval:1.0
    //                                         target:self
    //                                       selector:@selector(simulateN2S)
    //                                       userInfo:nil
    //                                        repeats:NO];
    
}

-(void)initIsConnected:(CDVInvokedUrlCommand*)command{
    [[BadElfListener sharedController]setIsConectedCommand:command];
    [[BadElfListener sharedController]setCommandDelegate:self.commandDelegate];
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

-(NSString*)getGroupName:(NSString*)polygon{
    NSString *retval = @"";
    BOOL isFound = false;
    for (int i=0; i< [self.parentArray count]; i++) {
        NSString *parent = [self.parentArray objectAtIndex:i];
        NSArray *tempArray = [self.childArray objectAtIndex:i];
        for (NSString *child in tempArray) {
            if ([child rangeOfString:polygon options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                isFound = TRUE;
                break;
            }
        }
        if (isFound) {
            retval = parent;
            break;
        }
    }
    return retval;
}

-(BOOL)isDisabledGroup:(NSString*)group {
    if ([group isEqualToString:@""]) {
        return FALSE;
    }
    for (NSString *grp in [self disabledParentArray]) {
        if ([grp isEqualToString:group]) {
            return TRUE;
        }
    }
    return FALSE;
}

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
    NSString *groupName = [self getGroupName:runwayName];
    if ([self isDisabledGroup:groupName]) {
        return;
    }
    [[RIWS sharedManager]playAudio:onRunway];
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
                                                   @"GroupName" : groupName,
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
    
    
    //PDX
    
    coordinates = @"-122.5810077476778,45.57856694542191,0 -122.5809368992649,45.57865781912249,0 -122.580213976447,45.57836364925681,0 -122.5793906114007,45.57851225541213,0 -122.5791131171946,45.57887161116479,0 -122.5793313318572,45.57943973996588,0 -122.5800837657545,45.57973933641782,0 -122.5800194419345,45.5797882970932,0 -122.5800819946411,45.57983760457338,0 -122.5823082426939,45.5807111527535,0 -122.5824165185993,45.58075696495906,0 -122.5824668805274,45.58081868671366,0 -122.5831659378831,45.581085773921,0 -122.5833270657479,45.58114419528703,0 -122.5833139637271,45.58115981607665,0 -122.5836124398948,45.58127838394382,0 -122.5841524319719,45.58136882872867,0 -122.584140851662,45.58145681665578,0 -122.5911765202958,45.58423365700291,0 -122.5924201428785,45.58470939398787,0 -122.5964139495069,45.58626441379546,0 -122.5979863629738,45.58688407027028,0 -122.5999314499963,45.58763602867158,0 -122.6009840781547,45.58804772147309,0 -122.6017088163599,45.58832889390112,0 -122.602800771428,45.58875469255649,0 -122.6031317273544,45.58888063735661,0 -122.6038726684948,45.58916968896344,0 -122.6051470330704,45.58967122874797,0 -122.605155921549,45.58966454275544,0 -122.6050861095069,45.58961067432577,0 -122.6051213341459,45.58958644333597,0 -122.6056975844407,45.58981091057774,0 -122.6064930456001,45.59012679222117,0 -122.608383135325,45.590871162625,0 -122.6084157260784,45.59086301599751,0 -122.6125985493833,45.59250135848515,0 -122.6126753883323,45.59256327356673,0 -122.6128871018305,45.59264349035682,0 -122.6128616580774,45.59267173895406,0 -122.6137862839801,45.5930287850947,0 -122.6138096687197,45.59300119374317,0 -122.6152639517284,45.59357469880979,0 -122.6152829228479,45.59354736370697,0 -122.6202828614402,45.59550902126464,0 -122.6202508760711,45.59554631113275,0 -122.6212018514971,45.59592509298906,0 -122.6243832214973,45.59717462012878,0 -122.6245141423546,45.5970120900806,0 -122.6264856186274,45.5977823915502,0 -122.6272378457138,45.59763383773004,0 -122.6273860448083,45.59743845981707,0 -122.6275070227591,45.59727184295334,0 -122.6272149139924,45.59665789311359,0 -122.6253375974634,45.59594703347032,0 -122.6254387388811,45.59582790867276,0 -122.6231958881733,45.5949914362081,0 -122.6231543636091,45.59491114948039,0 -122.6222762230948,45.59458174438418,0 -122.621571821156,45.59430904172315,0 -122.6168063302631,45.59245942807825,0 -122.6167852058797,45.59249089629566,0 -122.6114909359263,45.59042212017351,0 -122.611428517265,45.59036017932313,0 -122.6080388538174,45.58903979798734,0 -122.6079404827266,45.58909301008836,0 -122.6076475839894,45.58888415413475,0 -122.6071989337766,45.58870690585202,0 -122.6067829789829,45.58854408115723,0 -122.6054366282626,45.58801850537866,0 -122.60198555116,45.58666061011326,0 -122.600278939696,45.58599399981623,0 -122.5934321759675,45.58334103795424,0 -122.5921221173425,45.58282675856047,0 -122.5852157581481,45.58013818063426,0 -122.5842347454757,45.57975542953245,0 -122.5834935882943,45.57946774257923,0 -122.5832911179352,45.57945135684666,0 -122.5810077476778,45.57856694542191,0 ";
    polygonGuid = @"20";
    polygonName = @"RSA RUNWAY 10R/28L";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    
    coordinates = @"-122.6211288946047,45.59599264200293,0 -122.6211869416581,45.59592028390303,0 -122.6202545044246,45.59554737288328,0 -122.6201945910838,45.59561603987164,0 -122.6211288946047,45.59599264200293,0 ";
    polygonGuid = @"21";
    polygonName = @"HOLD SHORT LINE 10R AT B1";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6137861054264,45.59302858399361,0 -122.6128621908118,45.59267283385519,0 -122.6128062458632,45.59273977539581,0 -122.6137263920974,45.59310281340404,0 -122.6137861054264,45.59302858399361,0 ";
    polygonGuid = @"22";
    polygonName = @"HOLD SHORT LINE 10R/28L AT B2";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6038710274422,45.589169052296,0 -122.6038172604499,45.58923359349794,0 -122.6050563713168,45.58973484139948,0 -122.6051470330704,45.58967122874797,0 -122.6038710274422,45.589169052296,0 ";
    polygonGuid = @"23";
    polygonName = @"HOLD SHORT LINE 10R/28L AT E (NORTH)";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6013651450389,45.58819339639179,0 -122.6013112560659,45.58825771805098,0 -122.6030641759697,45.58895012388144,0 -122.6031260187832,45.58887667543387,0 -122.6013651450389,45.58819339639179,0 ";
    polygonGuid = @"24";
    polygonName = @"HOLD SHORT LINE 10R/28L AT B3";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5995667938649,45.58749618140502,0 -122.5995111624681,45.58755678312589,0 -122.6013075669428,45.58825657001851,0 -122.6013612569,45.58819310205218,0 -122.5995667938649,45.58749618140502,0 ";
    polygonGuid = @"25";
    polygonName = @"HOLD SHORT LINE 10R/28L AT B4";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5962205709132,45.58619186758091,0 -122.5961618044598,45.58626147577982,0 -122.597699028712,45.58686784260282,0 -122.597761183942,45.58679524265348,0 -122.5962205709132,45.58619186758091,0 ";
    polygonGuid = @"26";
    polygonName = @"HOLD SHORT LINE 10R/28L AT B5";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5911752865434,45.5842341457405,0 -122.5911150459392,45.5843068147889,0 -122.5923571911146,45.58478386941891,0 -122.5924207462574,45.58470808457177,0 -122.5911752865434,45.5842341457405,0 ";
    polygonGuid = @"27";
    polygonName = @"HOLD SHORT LINE 10R/28L AT B6";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5836143967496,45.58127920688391,0 -122.5833137295125,45.5811605469151,0 -122.5832505137448,45.5812339570308,0 -122.5835715924156,45.58135606599983,0 -122.5841412001807,45.58145630314657,0 -122.5841513053733,45.58136936063203,0 -122.5836143967496,45.58127920688391,0 ";
    polygonGuid = @"28";
    polygonName = @"HOLD SHORT LINE 10R/28L AT B8";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5852196730004,45.58013821516796,0 -122.5852820332417,45.58006434822529,0 -122.5843051462834,45.57968054565147,0 -122.5842410934429,45.57975565180561,0 -122.5852196730004,45.58013821516796,0 ";
    polygonGuid = @"29";
    polygonName = @"HOLD SHORT LINE 10R/28L AT C8";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5934445798749,45.58334521826045,0 -122.5935074818421,45.58327376857211,0 -122.5921749422015,45.58275096942163,0 -122.5921170222439,45.58282483732156,0 -122.5934445798749,45.58334521826045,0 ";
    polygonGuid = @"30";
    polygonName = @"HOLD SHORT LINE 10R/28L AT C6";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6019879202497,45.58666173997011,0 -122.6020509390164,45.5865850591497,0 -122.6003368777316,45.58591857830518,0 -122.6002782313252,45.58599161160918,0 -122.6019879202497,45.58666173997011,0 ";
    polygonGuid = @"31";
    polygonName = @"HOLD SHORT LINE 10R/28L AT F";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6066610330046,45.58849460617772,0 -122.6067511104234,45.58843242309868,0 -122.6054439026612,45.58793222962053,0 -122.6053852013925,45.58799638686261,0 -122.6066610330046,45.58849460617772,0 ";
    polygonGuid = @"32";
    polygonName = @"HOLD SHORT LINE 10R/28L AT E (SOUTH)";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6222784440931,45.59457699861282,0 -122.6223390669798,45.59450461914088,0 -122.6216536985406,45.59423352926846,0 -122.6215873793452,45.59431000531505,0 -122.6222784440931,45.59457699861282,0 ";
    polygonGuid = @"33";
    polygonName = @"HOLD SHORT LINE 10R AT C1";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5632442791463,45.58282899473804,0 -122.5633718625276,45.58292193364867,0 -122.5645103301616,45.58334901426043,0 -122.5644518833266,45.58342357830529,0 -122.5660817892954,45.58406388082394,0 -122.5677864052614,45.58484385381741,0 -122.5918069963042,45.5941402637643,0 -122.5947078833771,45.59526748237754,0 -122.596436781517,45.59590141332692,0 -122.5973527717052,45.59627778413898,0 -122.60023624543,45.59740560215747,0 -122.6003457762287,45.59749371227225,0 -122.6008850078317,45.59770816446331,0 -122.6009980065359,45.59757768760146,0 -122.6026913342467,45.59824224273149,0 -122.603466572817,45.59803073262382,0 -122.6037004067559,45.59776761337761,0 -122.6035114260528,45.59718946566578,0 -122.6018312746109,45.59654740338456,0 -122.6019644314778,45.59638491881854,0 -122.6007651145945,45.5959199872221,0 -122.6000179940679,45.59562856487561,0 -122.5976739189086,45.59472037619635,0 -122.5976001650762,45.59477699601732,0 -122.5970550913111,45.59439337826161,0 -122.5969701703041,45.59443915957717,0 -122.5963067794607,45.59418640223307,0 -122.595304338241,45.59379531470049,0 -122.5913866666479,45.59226698178425,0 -122.5910004137454,45.59211875618305,0 -122.59099479949,45.59194616018151,0 -122.5904872875723,45.5919170518382,0 -122.5867790875685,45.59046817486436,0 -122.5863928606244,45.5903226952539,0 -122.5863857417186,45.59014214495495,0 -122.585888639838,45.59012699464819,0 -122.5826058485455,45.58884718505672,0 -122.5818012666161,45.5885319026932,0 -122.5769156170054,45.58662530485871,0 -122.5759033990582,45.58623115079385,0 -122.5696079403104,45.58377926946923,0 -122.5684773089167,45.58333714581456,0 -122.5677090813989,45.58303984468003,0 -122.5676008932221,45.58307994024973,0 -122.5668994174986,45.58265352479597,0 -122.5668528737384,45.58270870963873,0 -122.5654239649103,45.58214181865209,0 -122.5653036169146,45.58229394582959,0 -122.5638746050319,45.58173025777133,0 -122.5629586411869,45.58190482459694,0 -122.5627620971177,45.58214388575743,0 -122.5628432413666,45.58235172212123,0 -122.5629482288772,45.58271456884449,0 -122.5632442791463,45.58282899473804,0 ";
    polygonGuid = @"34";
    polygonName = @"RSA RWY 10L/28R";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6008070503034,45.59593507216797,0 -122.6008650428261,45.59586462327431,0 -122.6000845738581,45.59555709121647,0 -122.6000233469867,45.59562999624771,0 -122.6008070503034,45.59593507216797,0 ";
    polygonGuid = @"35";
    polygonName = @"HOLD SHORT LINE 10L AT K1";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5976857595193,45.59472059646328,0 -122.5971436539301,45.59433766675085,0 -122.5970525982027,45.59439401380922,0 -122.5975993297779,45.59477894147439,0 -122.5976857595193,45.59472059646328,0 ";
    polygonGuid = @"36";
    polygonName = @"HOLD SHORT LINE 10L/28R AT E";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5964479485104,45.59423738597064,0 -122.5969720135063,45.59443632296144,0 -122.5970737926563,45.59438001338484,0 -122.5965169511341,45.59416733480941,0 -122.5964479485104,45.59423738597064,0 ";
    polygonGuid = @"37";
    polygonName = @"RSA 10L/28R BETWEEN E AND T";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"HOLD SHORT LINE 10L/28R AT T";
    polygonGuid = @"38";
    polygonName = @"-122.5964479485104,45.59423738597064,0 -122.5965130180925,45.59416733258877,0 -122.5956867554389,45.59384469117591,0 -122.5956233815139,45.5939203732923,0 -122.5964479485104,45.59423738597064,0 ";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.591468958904,45.59229860908498,0 -122.5915280367297,45.59222701557285,0 -122.5911196819312,45.59206376283783,0 -122.5911131833729,45.59194963925687,0 -122.5909970952216,45.59194621276829,0 -122.5910038369227,45.59211747975189,0 -122.591468958904,45.59229860908498,0 ";
    polygonGuid = @"39";
    polygonName = @"HOLD SHORT LINE 10L/28R AT A6";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5868928976605,45.59051287988441,0 -122.5869514219512,45.59044040225389,0 -122.5865086302425,45.59026424670648,0 -122.5865037170354,45.59015186451294,0 -122.5863871815879,45.59014305760907,0 -122.586391178185,45.59032322160643,0 -122.5868928976605,45.59051287988441,0 ";
    polygonGuid = @"40";
    polygonName = @"HOLD SHORT LINE 10L/28R AT A5";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5826662733498,45.58877462138271,0 -122.5818606902395,45.58845928151827,0 -122.5817992284201,45.58853103394392,0 -122.5826058755985,45.58884668609482,0 -122.5826662733498,45.58877462138271,0 ";
    polygonGuid = @"41";
    polygonName = @"HOLD SHORT LINE 10L/28R AT A4";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5769176230514,45.58662521962647,0 -122.5769781162371,45.5865529006273,0 -122.5759646213,45.58615529763672,0 -122.5759007707685,45.58622857496386,0 -122.5769176230514,45.58662521962647,0 ";
    polygonGuid = @"42";
    polygonName = @"HOLD SHORT LINE 10L/28R AT A3";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5696066519119,45.58377830136534,0 -122.5696659183258,45.5837069361698,0 -122.5685344924888,45.58326203528677,0 -122.5684743182676,45.58333422182209,0 -122.5696066519119,45.58377830136534,0 ";
    polygonGuid = @"43";
    polygonName = @"HOLD SHORT LINE 10L/28R AT A2";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5676026176624,45.58307941932634,0 -122.5677038753556,45.58303569642263,0 -122.5669948302324,45.5826018648945,0 -122.5669011943126,45.58265451084474,0 -122.5676026176624,45.58307941932634,0 ";
    polygonGuid = @"44";
    polygonName = @"HOLD SHORT LINE 28R AT A1";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6198288459684,45.5813017531832,0 -122.619887211169,45.58057904130656,0 -122.6194766663771,45.5802957549008,0 -122.6184925913257,45.58030085637855,0 -122.6184233780342,45.58034422553651,0 -122.6183541254508,45.58029323367408,0 -122.6161568881367,45.58182364642438,0 -122.6162388455139,45.58188087092224,0 -122.6156153097132,45.58231489858021,0 -122.6155397012701,45.58225760785016,0 -122.6099950555165,45.5861524802932,0 -122.6100742293306,45.58621140020438,0 -122.6092103705779,45.58681503365561,0 -122.6091321361865,45.5867628569805,0 -122.6074869311738,45.58791801415082,0 -122.60756710674,45.58797428361912,0 -122.6067650302392,45.58853573782438,0 -122.6066610354927,45.58849544952723,0 -122.6050864786821,45.58961111459504,0 -122.6051575643048,45.58966430873444,0 -122.6042483747323,45.59029984725537,0 -122.6041574023966,45.5902421245535,0 -122.6028364784605,45.5911855097064,0 -122.6024029207812,45.59120055415939,0 -122.6024057820127,45.59161321766841,0 -122.6021943542062,45.59163304638554,0 -122.5995469026683,45.59349247800572,0 -122.599594764157,45.59352421513614,0 -122.5985284926915,45.59427803800713,0 -122.5984719166866,45.59424319233671,0 -122.5980725597682,45.5945235522161,0 -122.5967401793903,45.59546794965767,0 -122.5975031187661,45.59600389589345,0 -122.598271075735,45.59653279319762,0 -122.6003666224007,45.59509522655532,0 -122.6002955921055,45.59505307561716,0 -122.6011333746294,45.59446840411617,0 -122.6011792566836,45.59440315194486,0 -122.6012090491791,45.59441295985326,0 -122.6012882296024,45.59444150256155,0 -122.6038856257157,45.59261808022362,0 -122.6038928674595,45.5923611626075,0 -122.604257915786,45.59235504691774,0 -122.605281515623,45.5916382684452,0 -122.6054603093972,45.59150955714927,0 -122.6054559043516,45.59127899690747,0 -122.6057716682298,45.59129127487316,0 -122.6059834433395,45.59114094835859,0 -122.6058954655919,45.59108471041701,0 -122.6062229235218,45.59085457681893,0 -122.6063178011082,45.59090394077293,0 -122.6087484420862,45.58919427417389,0 -122.6086446528468,45.5891546046367,0 -122.6091184006532,45.58882477426586,0 -122.609215514954,45.58886563332326,0 -122.6120381314796,45.58688442990137,0 -122.6119726901778,45.58686044106472,0 -122.6121290189403,45.5866632140298,0 -122.6122731749977,45.58671902261707,0 -122.6189830397385,45.58200474968964,0 -122.6198980273713,45.58135014307197,0 -122.6198288459684,45.5813017531832,0 ";
    polygonGuid = @"45";
    polygonName = @"RSA RWY 3/21";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.599593150753,45.59352593120233,0 -122.5995445502335,45.59349206285559,0 -122.598473287145,45.59424246867705,0 -122.5985281030111,45.59427776426989,0 -122.599593150753,45.59352593120233,0 ";
    polygonGuid = @"46";
    polygonName = @"HOLD SHORT LINE 21 AT K (EAST)";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6024054565547,45.59161452657872,0 -122.6024018687502,45.59119976793,0 -122.6022818545888,45.59119974842771,0 -122.6022766588533,45.59162446039993,0 -122.6024054565547,45.59161452657872,0 ";
    polygonGuid = @"47";
    polygonName = @"HOLD SHORT LINE 3/21 AT M (EAST)";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6050554125246,45.58973381524083,0 -122.6049442418531,45.589690684289,0 -122.6041613030234,45.59024011616952,0 -122.6042480997816,45.59029731213572,0 -122.6050554125246,45.58973381524083,0 ";
    polygonGuid = @"48";
    polygonName = @"HOLD SHORT LINE 3/21 AT B (EAST)";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6067659586223,45.58853378741217,0 -122.6075648161064,45.58797406455196,0 -122.6074865204218,45.58791863932237,0 -122.6066628904753,45.58849479877631,0 -122.6067659586223,45.58853378741217,0 ";
    polygonGuid = @"49";
    polygonName = @"HOLD SHORT LINE 3/21 AT C (EAST)";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6100731775854,45.58621200963939,0 -122.6099942960516,45.58615342174051,0 -122.6091307382962,45.58676180518916,0 -122.6092123963032,45.58681321533208,0 -122.6100731775854,45.58621200963939,0 ";
    polygonGuid = @"50";
    polygonName = @"HOLD SHORT LINE 3/21 AT E4";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6162362236034,45.58188134612963,0 -122.6161563683163,45.58182484177944,0 -122.6155412656671,45.58225538595179,0 -122.6156162996661,45.58231357103774,0 -122.6162362236034,45.58188134612963,0 ";
    polygonGuid = @"51";
    polygonName = @"HOLD SHORT LINE 3 AT E6";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6121319565999,45.5866635326112,0 -122.6119774878125,45.58686002063407,0 -122.6120759810665,45.58689631994891,0 -122.6122104736481,45.58674536117524,0 -122.6122710982827,45.58671989738819,0 -122.6121319565999,45.5866635326112,0 ";
    polygonGuid = @"52";
    polygonName = @"HOLD SHORT LINE 3/21 AT G";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6092123724285,45.58886728687113,0 -122.6091190163004,45.5888252486003,0 -122.6086474399208,45.5891534308271,0 -122.6087510548888,45.58919338203284,0 -122.6092123724285,45.58886728687113,0 ";
    polygonGuid = @"53";
    polygonName = @"HOLD SHORT LINE 3/21 AT C (WEST)";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6058973686013,45.59108326712164,0 -122.6059834925147,45.59114050885576,0 -122.6063150677183,45.59090850779256,0 -122.6062217929139,45.59085523950252,0 -122.6058973686013,45.59108326712164,0 ";
    polygonGuid = @"54";
    polygonName = @"HOLD SHORT LINE 3/21 AT B (WEST)";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6055807463778,45.59153729402651,0 -122.6055808935368,45.59128337101711,0 -122.6054602678345,45.59128350227103,0 -122.6054602309192,45.59150592794327,0 -122.6052824447943,45.59163752649775,0 -122.605374446201,45.59169167394559,0 -122.6055807463778,45.59153729402651,0 ";
    polygonGuid = @"55";
    polygonName = @"HOLD SHORT 3/21 AT M (WEST)";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6038921224503,45.59236016921896,0 -122.6038918252179,45.59243900074551,0 -122.6042591406187,45.59243678135397,0 -122.6042604608126,45.5923541502298,0 -122.6038921224503,45.59236016921896,0 ";
    polygonGuid = @"56";
    polygonName = @"HOLD SHORT LINE 3/21 AT H";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6012427345977,45.59450595342999,0 -122.6012869940892,45.59444333063855,0 -122.6011797954933,45.59440429991584,0 -122.6011365275667,45.59446796545014,0 -122.6002942560287,45.59505030934579,0 -122.6003885761716,45.59510591856073,0 -122.6012427345977,45.59450595342999,0 ";
    polygonGuid = @"57";
    polygonName = @"HOLD SHORT LINE 21 AT K (WEST)";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5886334893046,45.58146733012937,0 -122.5891245444819,45.58084257472954,0 -122.5890192304101,45.58080573271067,0 -122.5885280128739,45.58142616419239,0 -122.5886334893046,45.58146733012937,0 ";
    polygonGuid = @"58";
    polygonName = @"HOLD SHORT ILS GS 28L AT C";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5687656069293,45.58522065777316,0 -122.5685177034337,45.58554798683335,0 -122.5688035182747,45.5857221732591,0 -122.5711638135449,45.58664901437592,0 -122.5714714698527,45.5862765521472,0 -122.5687656069293,45.58522065777316,0 ";
    polygonGuid = @"59";
    polygonName = @"ILS GS AREA 28R";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5918897263108,45.59422093207388,0 -122.5915136724105,45.59463846422901,0 -122.5917625022379,45.59503374985493,0 -122.5957970632744,45.59666724192868,0 -122.5963905714379,45.5959436493432,0 -122.5947216271137,45.59528891685187,0 -122.5944842382915,45.59523948679829,0 -122.5918897263108,45.59422093207388,0 ";
    polygonGuid = @"60";
    polygonName = @"ILS GS AREA 10L";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.5842933485711,45.57897466977864,0 -122.5837854786121,45.57957781307873,0 -122.5842390053171,45.57975612233001,0 -122.5843041043192,45.57967981959403,0 -122.5852842777658,45.58006442460514,0 -122.5852222997253,45.58013875464362,0 -122.5885270356822,45.58142543417397,0 -122.5890163308504,45.58080657655419,0 -122.5855692108246,45.57946436442147,0 -122.5847237096136,45.57915297219316,0 -122.5842933485711,45.57897466977864,0 ";
    polygonGuid = @"61";
    polygonName = @"ILS GS AREA 28L";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.6215863588297,45.5943066103046,0 -122.6216503396944,45.59423077145501,0 -122.6223400680671,45.59450298100693,0 -122.6222809776849,45.59457538114739,0 -122.6227845390926,45.59477798844433,0 -122.6233917488132,45.59400498177941,0 -122.6227443277911,45.59378578952071,0 -122.6228276572306,45.59366583640944,0 -122.6228600357712,45.59355398327314,0 -122.6228666121393,45.59346181761537,0 -122.6228410384515,45.5933305064329,0 -122.622787982911,45.59321375402537,0 -122.6226510556188,45.59306624304557,0 -122.6224725210885,45.5929447122254,0 -122.6224632540548,45.59285708195744,0 -122.6224215332748,45.59283762381813,0 -122.6220325066515,45.59333232617723,0 -122.6219154283336,45.59347517084947,0 -122.6197949845223,45.59271990122842,0 -122.6186665394083,45.59265681574015,0 -122.6183298096442,45.59303777646562,0 -122.6215863588297,45.5943066103046,0 ";
    polygonGuid = @"62";
    polygonName = @"ILS GS AREA 10R";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-122.622422056841,45.59283705316044,0 -122.6223207267731,45.5927982906743,0 -122.621810955226,45.59343514488922,0 -122.6219151840125,45.59347217612684,0 -122.622422056841,45.59283705316044,0 ";
    polygonGuid = @"63";
    polygonName = @"HOLD SHORT ILS GS 10R @ C";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    
    
    //PDX
    
    
    //Test Area Polygons
    
    coordinates = @"-84.43099155700767,33.64750627984748,0 -84.4309255441916,33.64757267628729,0 -84.43135369896308,33.64778809655347,0 -84.43176531098209,33.64757265238111,0 -84.43169805323389,33.64750630173182,0 -84.43134492338479,33.64769275391303,0 -84.43099155700767,33.64750627984748,0 ";
    polygonGuid = @"64";
    polygonName = @"Test Runway";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    
    coordinates = @"-77.61644592929922,38.81987027802619,0 -77.61663869047862,38.81991122644997,0 -77.61673982134874,38.8195310469888,0 -77.61654776571432,38.81950437671276,0 -77.61644592929922,38.81987027802619,0 ";
    polygonGuid = @"65";
    polygonName = @"Vish Home";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    
    coordinates = @"-77.61632729921553,38.82026654554055,0 -77.61608412373033,38.82021751716387,0 -77.61603536626623,38.82038807795139,0 -77.6163120260053,38.82042823412356,0 -77.61632729921553,38.82026654554055,0 ";
    polygonGuid = @"66";
    polygonName = @"Vish Actual Home";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"-77.486023146267,39.0691445740366,0 -77.48603878061161,39.06898259451713,0 -77.48593872618392,39.06891857498337,0 -77.48597702588474,39.06830693932571,0 -77.48570292171772,39.06829446351423,0 -77.48566881709341,39.06889164495146,0 -77.48558039695317,39.06902896095986,0 -77.48558770613522,39.06912220285323,0 -77.486023146267,39.0691445740366,0 ";
    polygonGuid = @"67";
    polygonName = @"TEST RSA ILS SA";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    
    coordinates = @"-77.48612740632728,39.06911939522435,0 -77.48614355333713,39.06898565294091,0 -77.48604077898466,39.06898208933311,0 -77.48602654760288,39.06913176370202,0 -77.48612740632728,39.06911939522435,0  ";
    polygonGuid = @"68";
    polygonName = @"HOLD SHORT LINE - INDMEX - AT  - TEST";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    
    coordinates = @"-77.42229456292533,39.02275638471243,0 -77.42184158498611,39.02276636101656,0 -77.42186567400647,39.02294373290463,0 -77.42233312516014,39.02292131725324,0 -77.42229456292533,39.02275638471243,0 ";
    polygonGuid = @"69";
    polygonName = @"TerragoOffice";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    
    coordinates = @"76.95000131514489,11.02157634197544,0 76.95183032085941,11.0220645043448,0 76.95161697260122,11.02333792656345,0 76.94970297682437,11.02307074099046,0 76.95000131514489,11.02157634197544,0  ";
    polygonGuid = @"70";
    polygonName = @"MyHome";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
    
    coordinates = @"76.95072301447094,11.00469919188415,0 76.95217015808014,11.00481413749866,0 76.95192896991979,11.00616738796572,0 76.95059453863988,11.00602824241446,0 76.95072301447094,11.00469919188415,0 ";
    polygonGuid = @"71";
    polygonName = @"CBE Office";
    [[RIWS sharedManager]addPolygons:coordinates forPolygonGUID:polygonGuid PolygonName:polygonName isforceReplace:canForceReplace];
}

@end
