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

/**
 The SimpleBadElfGpsManagerDelegate class handles the communication between connecting and disconnecting
 Bad Elf GPS hardware.
 
 ## Accessory Detection
 A Bad Elf device can be in two states on the users iOS Device: Connected or Disconnected
 The SDK looks at all the devices connected to the users device and finds the ones that conform
 to the specific Bad Elf protocol identifier before informing if the hardware Connected or Disconnected.
 
 ## Supported Bad Elf Hardware
 
 - Bad Elf GPS 1000 (30-Pin Dock connector)
 - Bad Elf GPS 1008 (Lightning Connector)
 - Bad Elf GPS 2200 (Pro Bluetooth)
 
 */

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
@protocol BEAccessoryDelegate;
@protocol BEGpsAccessoryDelegate;

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

@interface SimpleBadElfGpsManagers : NSObject<BEAccessoryManagerDelegate, BEGpsAccessoryDelegate>

/**
 Singleton object for the GPS Manager class
 **/
+ (SimpleBadElfGpsManagers *)sharedGpsManager; // Singleton Instance for GPS Manager
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
@property (nonatomic) BOOL logging1;
/**
 An array of the logs found on the GPS Device
 @warning *Only supported on the BE-GPS-2200
 **/
@property (nonatomic, strong) NSArray *logListData1;

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
