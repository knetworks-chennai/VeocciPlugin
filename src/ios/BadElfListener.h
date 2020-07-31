//
//  BadElfListener.h
//  TestBluetooth
//
//  Created by Sunilkarthick Sivabalan on 11/01/17.
//  Copyright © 2017 IndMex Aviation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/EAAccessoryManager.h>
#import <ExternalAccessory/EAAccessory.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "GPSSession.h"
#import <Cordova/CDV.h>

@interface BadElfListener : NSObject<EAAccessoryDelegate, NSStreamDelegate, NSURLSessionDelegate>

+ (BadElfListener *)sharedController;

-(void)initConnectedDevices;

@property(nonatomic,retain)NSArray *supportedProtocolsStrings;
@property(nonatomic,retain)NSMutableArray* accessoryList;
@property(nonatomic,retain)CDVInvokedUrlCommand* command;
@property (nonatomic, weak) id <CDVCommandDelegate> commandDelegate;
@property(nonatomic,retain)CDVInvokedUrlCommand* isConectedCommand;
@end
