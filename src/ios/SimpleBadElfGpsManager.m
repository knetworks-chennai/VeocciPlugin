/**************************************************************************
 * Copyright (c) 2010-2014 Bad Elf, LLC.
 * All rights reserved.
 *
 * This source code and any related documentation are confidential materials
 * of Bad Elf, LLC.
 *
 * Binary distribution is subject to written approval by Bad Elf, LLC.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 *************************************************************************/


#import <Foundation/Foundation.h>
#import <BEAPSDK/BEBadElfAccessoryProtocol.h>

// For 1Hz & overriding iOS6 CoreLocation bug
#define GPS_STREAMING_MODE  (BE_GPS_STREAMING_MODE_BINARY + GPS_STREAMING_MODE_GPS_POWER_ON_OVERRIDE)
#define GPS_REFRESH_RATE    (BE_GPS_REFRESH_RATE_1Hz)
#define GPS_INCLUDE_SATELLITE_DATA  (NO)

// For 10Hz binary streaming
//#define GPS_STREAMING_MODE  (BE_GPS_STREAMING_MODE_BINARY_RAW)
//#define GPS_REFRESH_RATE    (BE_GPS_REFRESH_RATE_10Hz)

@protocol BEAccessoryManagerDelegate;
@protocol BEGpsAccessory;

@protocol SimpleBadElfGpsManagerDelegate <BEGpsAccessoryDelegate, BEAccessoryDelegate, NSObject>
@optional
/**
 Optional method for checking if the Bad Elf Accessory connected to the device
 @param accessory A BEGpsAccessory object
 @return nil
 **/
- (void) gpsAccessoryConnected:(id<BEGpsAccessory>)accessory;
/**
 Optional method for checking if the Bad Elf Accessory disconnected to the device
 @param accessory A BEGpsAccessory object
 @return nil
 **/
- (void) gpsAccessoryDisconnected:(id<BEGpsAccessory>)accessory;
@end

/**
 The Bad Elf GPS Manager class is a singleton class that is used to get the selected
 hardware from the BadElf SDK. It is also used to set the default GPS Format, Filtering,
 and reporting rate for the GPS device.
 
 ## Supported Devices
 The current build of the SDK supports the current Bad Elf devices
 
 - GPS-1000
 - GPS-1008
 - GPS-2200
 
 ## Calling the GPS Manager
 The GPS manager is a singleton instance so you can easily call and set the required methods and properties using the syntax below:
 
 [[SimpleBadElfGpsManager sharedGpsManager] start];
 [[SimpleBadElfGpsManager sharedGpsManager] setDefaultGpsFormat:YES];
 [[SimpleBadElfGpsManager sharedGpsManager] setDelegate:self];
 
 This is very useful when talking to the Bad Elf hardware and makes it very easy to get/set properties of the hardware.
 
 ## Datalogging Notes
 The current implementation of the Bad Elf GPS Manager supports toggling datalogging on and off
 for the GPS Pro 2200. This feature will soon be depricated and moved to an internal API.
 
 */

@interface SimpleBadElfGpsManager : NSObject<BEAccessoryManagerDelegate, BEGpsAccessoryDelegate>

/**
 Singleton object for the GPS Manager class
 **/
+ (SimpleBadElfGpsManager *)sharedGpsManager; // Singleton Instance for GPS Manager
/**
 An array of detected Bad Elf GPS devices
 **/
@property (nonatomic, strong) NSArray *detectedHardware; // array of BEGpsAccessory objects
/**
 The first object connected and found in the 'detectedHardware' array becomes the selected hardware.
 **/
@property (nonatomic, strong) id <BEGpsAccessory> selectedHardware;
/**
 Delegate object for the GPS Manager
 **/
@property (nonatomic, strong) id<SimpleBadElfGpsManagerDelegate> delegate;
/**
 AutoOpen Accessories takes the selected hardware and starts reading their byte information
 **/
@property (nonatomic) BOOL autoOpenAccessories;
/**
 The default GPS Format for the selected hardware
 **/
@property (nonatomic) int defaultGpsFormat;
/**
 Value for if SDK should return satellite data from the device
 **/
@property (nonatomic) BOOL defaultSatelliteData;
/**
 The default GPS Reporting rate (resolution) for the selected hardware in Hz
 **/
@property (nonatomic) int defaultGpsReportingRate;
/**
 Weather the GPS Device is currently logging
 @warning *Only supported on the BE-GPS-2200
 **/
@property (nonatomic) BOOL logging;
/**
 An array of the logs found on the GPS Device
 @warning *Only supported on the BE-GPS-2200
 **/
@property (nonatomic, strong) NSArray *logListData;

///---------------------------
/// @name Starting and Stopping GPS Device detection
///---------------------------

/**
 Starts streaming the data from the selected GPS hardware
 @return nil
 **/
- (void)start;
/**
 Stops streaming the data from the selected GPS hardware
 @return nil
 **/
- (void)stop;
/**
 Opens the accessory stream for the selected GPS hardware
 @param gpsAccessory An instance of the BEGpsAccessory
 @return nil
 **/
- (void)openAccessory:(id<BEGpsAccessory>)gpsAccessory;
/**
 Closes the accessory stream for the selected GPS hardware
 @param gpsAccessory An instance of the BEGpsAccessory
 @return nil
 **/
- (void)closeAccessory:(id<BEGpsAccessory>)gpsAccessory;

@end


#import "SimpleBadElfGpsManager.h"

@interface SimpleBadElfGpsManager()
@property (nonatomic, strong) BEAccessoryManager *accessoryManager;
@property (nonatomic, strong) id <BEGpsAccessory> selectedHardwareRaw;
@property (nonatomic, strong) NSMutableArray *detectedHardwareRaw;
@property (nonatomic) BOOL started;
@end

@implementation SimpleBadElfGpsManager

@synthesize detectedHardwareRaw = _detectedHardwareRaw;
@synthesize accessoryManager = _accessoryManager;
@synthesize selectedHardwareRaw = _selectedHardwareRaw;
@synthesize started;

@dynamic selectedHardware;
@dynamic detectedHardware;

@synthesize delegate;
@synthesize autoOpenAccessories;

@synthesize defaultGpsFormat;
@synthesize defaultSatelliteData;
@synthesize defaultGpsReportingRate;

+ (SimpleBadElfGpsManager *)sharedGpsManager
{
    static SimpleBadElfGpsManager *sharedGpsManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGpsManager = [[self alloc] init];
    });
    
    return sharedGpsManager;
}

- (id)init {
    
    if (self != nil)
    {
        self = [super init];
        self.selectedHardware = nil;
        self.detectedHardware = [NSMutableArray arrayWithCapacity: 3];
        self.accessoryManager = [BEAccessoryManager new];
        self.started = NO;
        self.autoOpenAccessories = YES;
        
        self.defaultGpsFormat = GPS_STREAMING_MODE;
        self.defaultGpsReportingRate = GPS_REFRESH_RATE;
        self.defaultSatelliteData = GPS_INCLUDE_SATELLITE_DATA;
    }
    
    return self;
}

-(void)start {
    self.started = YES;
    self.accessoryManager.delegate = self;
    [self reconnectAllExistingAccessories];
}

-(void)stop {
    self.accessoryManager.delegate = nil;
    self.started = NO;
    [self closeAllAccessories];
}

- (void)openAccessory:(id<BEGpsAccessory>)gpsAccessory {
    gpsAccessory.delegate = self.delegate;
    [gpsAccessory openSession];
    [gpsAccessory enableGpsDataStreaming:self.defaultGpsFormat atRefreshRate:self.defaultGpsReportingRate includeSatelliteData:self.defaultSatelliteData];
    
}
- (void)closeAccessory:(id<BEGpsAccessory>)gpsAccessory {
    gpsAccessory.delegate = nil;
    [gpsAccessory closeSession];
}

#pragma mark - BEAccessory Delegate Methods

- (void)accessoryDidConnect:(id<BEAccessory>)accessory {
    if (!self.started) {
        return; // early return; can happen when running in background
    }
    id<BEGpsAccessory> gpsAccessory = (id<BEGpsAccessory>) accessory;
    [self addDetectedAccessory: gpsAccessory];
    if (self.autoOpenAccessories) {
        [self openAccessory:gpsAccessory];
    }
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:(@selector(gpsAccessoryConnected:))])) {
        [self.delegate gpsAccessoryConnected:gpsAccessory];
    }
}

- (void)accessoryDidDisconnect: (id<BEAccessory>)accessory {
    id<BEGpsAccessory> gpsAccessory = (id<BEGpsAccessory>) accessory;
    gpsAccessory.delegate = nil;
    if (gpsAccessory == self.selectedHardwareRaw) {
        self.selectedHardwareRaw = nil;
    }
    [self removeDetectedAccessory:gpsAccessory];
    [self closeAccessory: gpsAccessory];
    
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:(@selector(gpsAccessoryDisconnected:))])) {
        [self.delegate gpsAccessoryDisconnected:gpsAccessory];
    }
}

#pragma mark - Internal Methods

- (void)reconnectAllExistingAccessories {
    BEAccessoryManager *accessoryManager = self.accessoryManager;
    NSArray *connectedAccessories = accessoryManager.connectedAccessories;
    for (id<BEGpsAccessory> accessory in connectedAccessories) {
        [self accessoryDidConnect:accessory];
    }
}

- (NSMutableArray *)detectedHardware {
    return self.detectedHardwareRaw;
}

- (void)addDetectedAccessory: (id<BEGpsAccessory>) accessory {
    
    NSMutableArray *newArray = [NSMutableArray arrayWithArray: self.detectedHardware];
    
    if (![newArray containsObject:accessory])
    {
        [newArray addObject: accessory];
    }
    
    self.detectedHardware = newArray;
}

- (void)removeDetectedAccessory: (id<BEGpsAccessory>) accessory {
    NSMutableArray *newArray = [NSMutableArray arrayWithArray: self.detectedHardware];
    [newArray removeObject: accessory];
    self.detectedHardware = newArray;
}

- (void)setDetectedHardware:(NSMutableArray *)detectedHardware {
    self.detectedHardwareRaw = [NSMutableArray arrayWithArray: detectedHardware];
}

- (void)closeAllAccessories {
    NSArray *detectedHardware = [self.detectedHardware copy];
    for (id <BEGpsAccessory> gpsAccessory in detectedHardware) {
        [self closeAccessory: gpsAccessory];
    }
}

- (id <BEGpsAccessory>) selectedHardware {
    id <BEGpsAccessory> selectedHardware = self.selectedHardwareRaw;
    if (selectedHardware == nil) {
        NSArray *detectedHardware = self.detectedHardware;
        if (detectedHardware.count == 0) {
            return nil;
        }
        selectedHardware = [detectedHardware objectAtIndex: 0];
    }
    return selectedHardware;
}

- (void)setSelectedHardware:(id <BEGpsAccessory>)selectedHardware {
    self.selectedHardwareRaw = selectedHardware;
}

@end
