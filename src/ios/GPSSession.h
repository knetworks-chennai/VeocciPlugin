//
//  GPSSession.h
//  appSample
//
//  Created by Sunilkarthick Sivabalan on 11/01/17.
//
//

@import Foundation;
@import ExternalAccessory;
#import "NSData+hexa.h"
#import "nmeaApi.h"

extern NSString *GPSSessionDataReceivedNotification;
@interface GPSSession : NSObject<EAAccessoryDelegate, NSStreamDelegate>
{
    nmeaINFO info;
    nmeaPARSER parser;
}
+ (GPSSession *)sharedController;

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;

- (BOOL)openSession;
- (void)closeSession;

- (void)writeData:(NSData *)data;

- (NSUInteger)readBytesAvailable;
- (NSData *)readData:(NSUInteger)bytesToRead;

@property (nonatomic, readonly) EAAccessory *accessory;
@property (nonatomic, readonly) NSString *protocolString;

@end
