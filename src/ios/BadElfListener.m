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
    [self sendLog:[NSString stringWithFormat:@
    "BadElf DidConnect"]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
                       CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:TRUE];
                       [pluginResult setKeepCallbackAsBool:TRUE];
                       [self.commandDelegate sendPluginResult:pluginResult callbackId:self.isConectedCommand.callbackId];
                   });
}

- (void)_accessoryDidDisConnect:(NSNotification *)notification {
    [[GPSSession sharedController]closeSession];
    [self sendLog:[NSString stringWithFormat:@
    "BadElf DidDisconnect"]];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
                       CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:FALSE];
                       [pluginResult setKeepCallbackAsBool:TRUE];
                       [self.commandDelegate sendPluginResult:pluginResult callbackId:self.isConectedCommand.callbackId];
                   });
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
//                   {
//                       for (int i=0; i < 72; i++) {
//                           NSDictionary *incrusion = @{
//                                                       @"IncursionEventID" : [NSString stringWithFormat:@"%d",i],
//                                                       @"Time" : [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]]
//                                                       };
//                           CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:incrusion];
//                           [pluginResult setKeepCallbackAsBool:TRUE];
//                           [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
//                       }
//                       CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@""];
//                       [pluginResult setKeepCallbackAsBool:TRUE];
//                       [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
//
//                   });
    
}


-(void)initSessionfor:(EAAccessory*)connectedAccessory{
    NSArray* protocolStrings = [connectedAccessory protocolStrings];
    [self sendLog:[NSString stringWithFormat:@
                   "Protocols : %@",[protocolStrings componentsJoinedByString:@","]]];
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
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                           {
                               CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:TRUE];
                               [pluginResult setKeepCallbackAsBool:TRUE];
                               [self.commandDelegate sendPluginResult:pluginResult callbackId:self.isConectedCommand.callbackId];
                           });
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


-(void)sendLog:(NSString*)msg{
//    NSError *error;

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"https://common.airbossclient.com/indmexLogger/logData"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

//    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [request setHTTPMethod:@"POST"];
//    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys: @"TEST IOS", @"name", @"IOS TYPE", @"typemap",  nil];
//    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    NSData *postData =[msg dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];


    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Error %@",error);
    }];

    [postDataTask resume];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"common.airbossclient.com"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

@end
