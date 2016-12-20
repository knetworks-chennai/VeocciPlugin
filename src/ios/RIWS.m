/********* RIWS.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>

@interface RIWS : CDVPlugin {
  // Member variables go here.
}
@property(nonatomic,strong)CDVInvokedUrlCommand *eventCommand;
@property(nonatomic,retain)NSTimer *timer;

- (void)addPolygon:(CDVInvokedUrlCommand*)command;
@end

@implementation RIWS

- (void)addPolygon:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = @"Ok";
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    
    [pluginResult setKeepCallbackAsBool:TRUE];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    self.eventCommand = command;
    if (![self.timer isValid]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                                      target: self
                                                    selector:@selector(onTick:)
                                                    userInfo: nil repeats:YES];
    }
}

-(void)onTick:(NSTimer *)timer {
    //do smth
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsString : @"Ok"
                                     ];
    
    // Execute sendPluginResult on this plugin's commandDelegate, passing in the ...
    // ... instance of CDVPluginResult
    [pluginResult setKeepCallbackAsBool:TRUE];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCommand.callbackId];
}

@end
