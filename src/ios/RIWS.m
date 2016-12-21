/********* RIWS.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>

@interface RIWS : CDVPlugin {
  // Member variables go here.
}
@property(nonatomic,strong)CDVInvokedUrlCommand *eventCommand;
@property(nonatomic,retain)NSTimer *timer;

-(void)addPolygon:(CDVInvokedUrlCommand*)command;
-(void)removePolygon:(CDVInvokedUrlCommand*)command;
-(void)removeAll:(CDVInvokedUrlCommand*)command;
-(void)initRIWS:(CDVInvokedUrlCommand*)command;
@end

@implementation RIWS

- (void)addPolygon:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = @"Successfully added polygon";
    if ([command.arguments count]<2) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error while adding polygon"];
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)removePolygon:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = @"Successfully removed polygon";
    if ([command.arguments count]<2) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error while removing polygon"];
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
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
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)initRIWS:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    NSDictionary *incrusion = @{
                             @"IncursionEventID" : @"guid"
                             @"IncursionText" : @"Vehicle is inside Test Polygon",
                             @"TextColor" : @"ff12de",
                             @"AudioFile" : @"1.mp3"
                             };
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:incrusion];
    [pluginResult setKeepCallbackAsBool:TRUE];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    self.eventCommand = command;
    if (![self.timer isValid]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval: 60.0
                                                          target: self
                                                        selector:@selector(onIncrusion:)
                                                        userInfo: nil repeats:YES];
    }

}

-(void)onIncrusion:(NSTimer *)timer {
    NSDictionary *incrusion = @{
                                @"IncursionEventID" : @"guid"
                                @"IncursionText" : @"Vehicle is inside Test Polygon",
                                @"TextColor" : @"ff12de",
                                @"AudioFile" : @"1.mp3"
                                };
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:incrusion];
    [pluginResult setKeepCallbackAsBool:TRUE];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCommand.callbackId];
    [NSTimer scheduledTimerWithTimeInterval: 20.0
                                     target: self
                                   selector:@selector(onIncrusionEnd:)
                                   userInfo: nil repeats:NO];
}

-(void)onIncrusionEnd:(NSTimer *)timer {
    NSDictionary *incrusion = @{
                                @"IncursionEventID" : @"guid"
                                @"IncursionText" : @"Vehicle is inside Test Polygon",
                                @"TextColor" : @"ff12de",
                                @"AudioFile" : @"1.mp3"
                                };
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:incrusion];
    [pluginResult setKeepCallbackAsBool:TRUE];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCommand.callbackId];
}

@end
