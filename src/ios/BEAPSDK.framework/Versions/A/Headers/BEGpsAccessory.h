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
 The GPS Accessory class provides information from the GPS Device such as:
 
 - Location Updates
 - Type of Device
 - Refresh Rate (Resolution)
 - Charging/Power Status
 - GPS Filtering
 - GPS Data Streaming
 - Reading Datalogs
 
 This information is optional to display information to a UI
 
 */

@protocol BEAccessory;
@protocol BEGpsLocation;
@protocol BEGpsDatalog;

typedef enum BEInternalBtGpsProState {
	AccessoryNotConnected = 0,
	AccessoryClosingSession,
	AccessoryOpeningSession,
	ReadingVersionInfo,
	ReadingEpoVersionInfo,
    ConfigureGpsReportingMode,
	AccessoryConnected,
    ReadDatalogList,
    ReadDatalogContents,
    CancelLogTransfer
} BEInternalGpsState_t;

typedef enum {
    BE_HARDWARE_GPSDONGLE                   = 1,
	BE_HARDWARE_GPSDONGLE_SIMULATOR         = 2,		// standard dongle hardware, but with USB-FTDI cable instead of real GPS module
    BE_HARDWARE_BTGPSPRO                    = 3,        // BE-GPS-2200
    BE_HARDWARE_GPS_SIMULATOR_CABLE_600AS   = 4,
    BE_HARDWARE_BTGPSPRO_2000               = 5,
    BE_HARDWARE_BTGPSPRO_2100               = 6,
    BE_HARDWARE_GPSDONGLE_1008              = 7,
    BE_HARDWARE_BTGPSPRO_2300               = 8,
    BE_HARDWARE_BTGPSPRO_3300               = 9,
    BE_HARDWARE_SLX_IPAD4_1008              = 10,
    
    BE_HARDWARE_UNRECOGNIZED_GPS = 255
} BEGpsAccessoryModels_t;

typedef enum {
	BE_GPS_STREAMING_MODE_OFF                   = 0x00,
	BE_GPS_STREAMING_MODE_BINARY                = 0x01,  // Supported by ALL Bad Elf GPS accessories and firmware versions
	BE_GPS_STREAMING_MODE_ASCII                 = 0x02,  // Not supported by all Bad Elf GPS accessories and firmware versions
    BE_GPS_STREAMING_MODE_ASCII_RAW             = 0x04,
    
	GPS_STREAMING_MODE_GPS_POWER_ON_OVERRIDE	= 0x10, // GPS power ON regardless of Location Lingo status (allows bypassing LL if disabled systemwide or for our app)
} BEGpsStreamingMode_t;

typedef enum {
	BEAP2_GPS_STREAMING_FILTER__NONE            = 0,
	BEAP2_GPS_STREAMING_FILTER__BASIC           = 1,  // Supported by ALL Bad Elf GPS accessories and firmware versions
	BEAP2_GPS_STREAMING_FILTER__EXTENDED        = 2,  // Not supported by all Bad Elf GPS accessories and firmware versions
} BEGpsStreamingFilter_t;

typedef enum {
	BE_GPS_RESOLUTION_DEFAULT = 0,
	BE_GPS_REFRESH_RATE_1Hz = 1,
	BE_GPS_REFRESH_RATE_2Hz = 2,		
	BE_GPS_REFRESH_RATE_4Hz = 4,		
	BE_GPS_REFRESH_RATE_5Hz = 5, 	
	BE_GPS_REFRESH_RATE_10Hz = 10
} BEGpsRefreshRate_t;

typedef enum {
	GPS_DATA_SOURCE_INTERNAL_RECEIVER = 0,
    GPS_DATA_SOURCE_EXTERNAL_PUCK = 1,
    GPS_DATA_SOURCE_CYGNUS_FLIGHT_SIMULATOR = 3
} BEGpsDataSource_t;

typedef enum {
	CHARGE_STATUS_NOT_CHARGING = 0,
    CHARGE_STATUS_COMPLETE,
    CHARGE_STATUS_IN_PROGRESS,
    CHARGE_STATUS_FAULT,
    CHARGE_STATUS_DISABLED,
    
    CHARGE_STATUS_NOT_SUPPORTED = 0xFE,
    CHARGE_STATUS_UNKNOWN = 0xFF
} BEGpsChargeStatus_t;


@protocol BEGpsAccessory;
@protocol BEAccessoryDelegate;

@protocol BEGpsAccessoryDelegate<BEAccessoryDelegate,NSObject>
@optional

///---------------------------
/// @name GPS Device Updates
///---------------------------

/**
 Checks if the GPS Location was updated
 @param accessory The accessory instance
 @param location The GPS Location instance that was updated
 @return nil
 */
- (void)gpsAccessory:(id<BEGpsAccessory>)accessory locationUpdated:(id<BEGpsLocation>)location;

/**
 Checks if the GPS Satellite count was updated
 @param accessory The accessory instance
 @param satellites An array of the updated satellites
 @return nil
 */
- (void)gpsAccessory:(id<BEGpsAccessory>)accessory satellitesUpdated:(NSArray*)satellites;

/**
 Checks if the GPS ASCII data was updated
 @param accessory The accessory instance
 @param ascii String of the updated ascii data
 @return nil
 */
- (void)gpsAccessory:(id<BEGpsAccessory>)accessory asciiUpdated:(NSString*)ascii;

/**
 Updates the GPS Device's status
 @param accessory The accessory instance
 @return nil
 */
- (void)gpsAccessoryStatusUpdated:(id<BEGpsAccessory>)accessory;
/**
 Updates GPS device with the log data stored on the GPS hardware
 @param accessory A BEGpsAccessory object
 @param list An array of logs found on the GPS hardware
 @return nil
 */
- (void)gpsDataloggerAccessory:(id<BEGpsAccessory>)accessory logListUpdated:(NSArray*)list;
/**
 Starts the reading of the selected datalog's contents and produces a progress
 @param accessory A BEGpsAccessory object
 @param log The BEGpsDatalog object to read
 @param percent A double value of the overall read progress
 @return nil
 */
- (void)gpsDataloggerAccessory:(id<BEGpsAccessory>)accessory logRead:(id<BEGpsDatalog>)log progress:(double)percent;
/**
 Method for when the device is done reading the log list contents
 @param accessory A BEGpsAccessory object
 @param log the BEGpsDatlog object to read
 @param points An array of the points contained within the log
 @return nil
 */
- (void)gpsDataloggerAccessory:(id<BEGpsAccessory>)accessory logReadComplete:(id<BEGpsDatalog>)log withPoints:(NSArray*)points;
/**
 Method for detecting if the reading of log contents failed
 @param accessory A BEGpsAccessory object
 @param log The BEGpsDatalog that was attempted to be read
 @return nil
 */
- (void)gpsDataloggerAccessory:(id<BEGpsAccessory>)accessory logReadFailed:(id<BEGpsDatalog>)log;

@end

/**
 The BEGpsAccessory is a subclass of BEAccessory with methods to update the various methods to update the connected Bad Elf GPS Devices
 as well as read their status information.
 
 ## Hardware Information
 
 E When the Bad Elf Device connects to iOS, the first information it recieves is basic hardware information about the device. It will then
 pass more information to iOS such as:
 
 - Hardware Type
 - Current Location (Not CoreLocation)
 - Satellites in Use
 - Streaming Mode
 - Refresh Rate
 - GPS Data Source
 - Charge/Power Status
 - External Power
 - Battery Level
 
 ## Satellite Data
 
 In order to see the VDOP, PDOP and Satellites in View, 'includeSatelliteData' must be set to YES. If your app does not require all the GPS data,
 it is suggested that you do not enable satellite data since it will be more bits of data to parse, however it does give you more information
 to display to the user.
 
 */

@protocol BEGpsAccessory<BEAccessory>

@required

///---------------------------
/// @name Hardware Information
///---------------------------

/**
 The Model of the connected Bad Elf GPS Device
 */
@property (nonatomic, readonly) BEGpsAccessoryModels_t hardwareType;
/**
 The Accessory Delegate
 */
@property (nonatomic, strong) id<BEGpsAccessoryDelegate> delegate;
/**
 The GPS Device's Current BEGpsLocation object
 */
@property (nonatomic, readonly) id<BEGpsLocation> currentLocation;
/**
 The array of BEGpsSatellite objects in view
 */
@property (nonatomic, strong, readonly) NSArray *satellitesInView; // of BEGpsSatellite objects
/**
 The GPS Streaming Mode (Binary, ASCII, ASCII RAW, None)
 */
@property (nonatomic, readonly) BEGpsStreamingMode_t streamingMode;
/**
 Current Refresh rate of the Bad Elf Device (Hz), the higher the Hz, the higher the resolution of data
 */
@property (nonatomic, readonly) BEGpsRefreshRate_t refreshRate;
/**
 The current flag indicating if extended satellite data will flow from the connected accessory
 */
@property (nonatomic, readonly) BOOL satDataIncluded;
/**
 The source of the GPS Data
 */
@property (nonatomic, readonly) BEGpsDataSource_t gpsDataSource;
/**
 The Charging status of the GPS Device
 */
@property (nonatomic, readonly) BEGpsChargeStatus_t chargeStatus;
/**
 Property for if the device has external power as an option for use
 */
@property (nonatomic, readonly) BOOL externalPowerAvailable;
/**
 Checks the current battery level of the device
 
 @warning *Only supported on the BE-GPS-2200, BE-GPS-2300 and BE-GPS-3300
 */
@property (nonatomic, readonly) double batteryLevel;
/**
 Enables SBAS on the selected device
 
 @warning Not supported by all Bad Elf devices
 */
@property (nonatomic) BOOL enableSbas;

///---------------------------
/// @name Data Streaming and Extended Data
///---------------------------

/**
 Sets the default GPS resolution in Hz, standard is 1Hz
 
 @param streamingMode The type of data to be streamed
 @param rate The refresh rate in Hz
 @return nil
 */
- (void)enableGpsDataStreaming:(BEGpsStreamingMode_t)streamingMode atRefreshRate:(BEGpsRefreshRate_t)rate;

/** Sets the default GPS resolution and optionally includes satellite data updates
 
 @param streamingMode The type of data to be streamed from the device
 @param rate The refresh rate in Hz
 @param satelliteData BOOL value if satellite data updates should be included
 @return nil
 */
- (void)enableGpsDataStreaming:(BEGpsStreamingMode_t)streamingMode atRefreshRate:(BEGpsRefreshRate_t)rate includeSatelliteData:(BOOL)satelliteData;

/**
 Disables GPS Streaming
 
 @return nil
 */
- (void)disableGpsDataStreaming;

@end
