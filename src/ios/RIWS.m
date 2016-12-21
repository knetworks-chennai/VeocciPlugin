/********* RIWS.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>

@interface RIWS : CDVPlugin {
  // Member variables go here.
}
@property(nonatomic,strong)CDVInvokedUrlCommand *eventCommand;
@property(nonatomic,retain)NSTimer *timer;

-(void)addPolygon:(CDVInvokedUrlCommand*)command;
-(void)clearPolygon:(CDVInvokedUrlCommand*)command;
-(void)RIWSAlert:(CDVInvokedUrlCommand*)command;
@end

@implementation RIWS

- (void)addPolygon:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = @"Add Polygon Called";
    if ([command.arguments count]<2) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:echo];
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)clearPolygon:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = @"Clear called";
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)RIWSAlert:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = @"RIWS Called";
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    [pluginResult setKeepCallbackAsBool:TRUE];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    self.eventCommand = command;
    if (![self.timer isValid]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval: 20.0
                                                          target: self
                                                        selector:@selector(onTick:)
                                                        userInfo: nil repeats:NO];
    }

}

-(void)onTick:(NSTimer *)timer {
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsString : @"RIWS Called"
                                     ];
    [pluginResult setKeepCallbackAsBool:TRUE];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCommand.callbackId];
}

@end
