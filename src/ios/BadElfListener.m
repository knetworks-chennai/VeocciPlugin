//
//  BadElfListener.m
//  TestBluetooth
//
//  Created by Sunilkarthick Sivabalan on 11/01/17.
//  Copyright © 2017 IndMex Aviation. All rights reserved.
//

#import "BadElfListener.h"

@implementation BadElfListener

static BadElfListener *sessionController = nil;

+ (BadElfListener *)sharedController
{
    
    static dispatch_once_t comToken;
    dispatch_once(&comToken, ^{
        if (sessionController == nil) {
            sessionController = [[BadElfListener alloc] init];
            sessionController.accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
            NSBundle *mainBundle = [NSBundle mainBundle];
            sessionController.supportedProtocolsStrings = [mainBundle objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
            [[NSNotificationCenter defaultCenter] addObserver:sessionController selector:@selector(_accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:sessionController selector:@selector(_accessoryDidDisConnect:) name:EAAccessoryDidDisconnectNotification object:nil];
            [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
        }
        
    });
    return sessionController;
}

-(void)initConnectedDevices{
    for (EAAccessory *connectedAccessory in sessionController.accessoryList) {
        [self initSessionfor:connectedAccessory];
    }
}

- (void)_accessoryDidConnect:(NSNotification *)notification {
    EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    [self initSessionfor:connectedAccessory];
}

- (void)_accessoryDidDisConnect:(NSNotification *)notification {
    [[GPSSession sharedController]closeSession];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
                       for (int i=0; i < 72; i++) {
                           NSDictionary *incrusion = @{
                                                       @"IncursionEventID" : [NSString stringWithFormat:@"%d",i],
                                                       @"Time" : [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]]
                                                       };
                           CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:incrusion];
                           [pluginResult setKeepCallbackAsBool:TRUE];
                           [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
                       }
                       CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@""];
                       [pluginResult setKeepCallbackAsBool:TRUE];
                       [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
                       
                   });
    
}


-(void)initSessionfor:(EAAccessory*)connectedAccessory{
    NSArray* protocolStrings = [connectedAccessory protocolStrings];
    BOOL  matchFound = FALSE;
    for(NSString *protocolString in protocolStrings)
    {
        for ( NSString *item in sessionController.supportedProtocolsStrings)
        {
            if ([item compare: protocolString] == NSOrderedSame)
            {
                matchFound = TRUE;
                NSLog(@"match found - protocolString %@", protocolString);
            }
        }
        if (matchFound) {
            [[GPSSession sharedController]setupControllerForAccessory:connectedAccessory withProtocolString:protocolString];
            [[GPSSession sharedController]openSession];
        }
        
    }
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
}


@end
