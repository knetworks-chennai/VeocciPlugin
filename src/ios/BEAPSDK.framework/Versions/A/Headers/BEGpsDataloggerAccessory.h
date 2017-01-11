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

//
//  BEGPSDataloggerAccessory.h
//  BadElfAccessoryProtocol
//
//  Created by Brian Ramirez on 4/9/14.


#import "BEAccessory.h"
#import "BECommonTypes.h"
#import "BEGpsLocation.h"
#import "BEGpsDatalog.h"

@protocol BEGpsDataloggerAccessory;

@protocol BEGpsDataloggerAccessoryDelegate <NSObject>

@end

/**
 The BEGPSDataloggerAccessory is used to control properties specific to the Bad Elf GPS Pro accessories such as the 
 BE-GPS-2200, BE-GPS-2300, and BE-GPS-3300. These properties are specific only to the accessories since they contain 
 datalogging features.
 
 ## Detecting a DataLogger Accessory
 
 When a Bad Elf accessory connects, the SDK determines if the connecting device is a BEGpsDataloggerAccessory object,
 it is recommended that when performing tasks in your app that require a DataLogger accessory, that you first
 check if the connected accessory conforms to the BEGpsDataloggerAccessory protocol to avoid errors in executing calls to
 the APIs.
 
 Example Datalogger Detection:
 
    id<BEGpsDataloggerAccessory> dataLogger = (id<BEGpsDataloggerAccessory>)[[SimpleBadElfGpsManager sharedGpsManager] selectedHardware];
 
    if (dataLogger != nil)
    {
        // Do something here that only a Datalogger accessory can
    }
 
 ## Reading Saved Datalogs
 
 In order to read the datalog from the accessory you must first call to get the datalog list from the accessory. This can be done like so: 
 
    - (BOOL)readLogList
    {
        id<BEGpsDataloggerAccessory> dataLogger = (id<BEGpsDataloggerAccessory>)[[SimpleBadElfGpsManager sharedGpsManager] selectedHardware];
 
        if (dataLogger != nil)
        {
            [dataLogger readLogList];
        }
 
        return YES;
    }
 
 This will query the hardware for a list of all the stored logs in memory. Once it is done a delegate callback is updated with an array of the 
 list of datalogs on the hardware:
 
    - (void)gpsDataloggerAccessory:(id<BEGpsAccessory>)accessory logListUpdated:(NSArray *)list
    {
        // Returns the list of datalogs and do something with them
        NSLog(@"Datalogs on Hardware: %@", list);
    }
 
 These methods are used only to display basic information about the datalog but do not save it to the iOS filesystem since this data is purely
  "metadata" for the logs themselves. Items included in the BEGpsDatalog objects are:
 
 - Total Point Count
 - Start Time
 - End Time
 
 ## BEGpsDatalog Harvesting (Downloading)
 
 Once a datalog list has been read, a specific datalog(s) can now be processed for use in an app. To start the processing of reading a datalog from the
 saved datalog list, you could use a method similar to the example below:
 
    // LogDownloader.h
    @property (nonatomic, strong) id<BEGpsDatalog>log; // The selected BEGpsDatalog from the log list array;
 
    // LogDownloader.m
    - (IBAction)readLogContents:(id)sender
    {
        [_appDelegate readLogContents:self.log];
    }
 
 The SDK does not parse the information stored in a datalog, but the resulting datalog information can be saved to the iOS filesystem for later parsing. 
 The data contained in the files can be then displayed to the UI if needed.
 
 The datalog downloading process has several delegate methods that get called at various points to determine the state of the log being read.
 These provide a good place to perform any needed post-action process such as saving to the iOS filesystem, displaying the contents to the UI, or any other log
 reading function your app needs.
 
    - (void)gpsDataloggerAccessory:(id<BEGpsAccessory>)accessory logRead:(id<BEGpsDatalog>)log progress:(double)percent;
    - (void)gpsDataloggerAccessory:(id<BEGpsAccessory>)accessory logReadComplete:(id<BEGpsDatalog>)log withPoints:(NSArray*)points;
    - (void)gpsDataloggerAccessory:(id<BEGpsAccessory>)accessory logReadFailed:(id<BEGpsDatalog>)log;
 
 ## Deleting a GPS Datalog
 
 If you need to delete a datalog from the Bad Elf GPS Pro, the process is very similar to reading and harvesting the datalog for the first time. 
 You must first get the list of datalogs from the hardware, however it is not required that you read the log's content prior to deleting it. 
 
 You can then call a method similar to the example below:
 
    // LogDownloader.h
    @property (nonatomic, strong) id<BEGpsDatalog>log; // The selected BEGpsDatalog from the log list array;
 
    - (BOOL)deleteLog:(id<BEGpsDatalog>)log
    {
        id <BEGpsDataloggerAccessory>datalogger = (id<BEGpsDataloggerAccessory>)[[SimpleBadElfGpsManager sharedGpsManager] selectedHardware];
        [datalogger deleteLog:log];
 
        // Update the new log list again now that we've deleted a log
        [self readLogList];
 
        return YES;
    }
 
 */

@protocol BEGpsDataloggerAccessory <BEGpsAccessory, BEAccessory, NSObject>

@property (nonatomic) BOOL isLogging;
@property (nonatomic) int unitsDegree;
@property (nonatomic) int unitsSpeed;
@property (nonatomic) int unitsDistance;
@property (nonatomic) int unitsAltitude;
@property (nonatomic) int unitsHeadingNorth;

@property (nonatomic) int bluetoothParing;
@property (nonatomic) BOOL cygnusFeaturesUnlocked;
@property (nonatomic) int cygnusFlightSimulationMode;
@property (nonatomic) int cygnusFlightSimulationBluetoothName;
@property (nonatomic) int cygnusFlightSimulationPairingMode;
@property (nonatomic) int cygnustFlightSimulationConfig;
@property (nonatomic) double deviceFreeSpace;
@property (nonatomic) BEGpsRefreshRate_t dataLoggerGpsResoution;
@property (nonatomic) int lcdContrastConfig;
@property (nonatomic) int lcdBacklightConfig;
@property (nonatomic) int lcdTimezoneOffsetConfig;
@property (nonatomic) int lcdDaylightSavingsConfig;
@property (nonatomic) int dataLoggerSmartFilterConfig;
@property (nonatomic) int dataLoggerAutoBehaviorConfig;
@property (nonatomic) BOOL autoOnWithExternalPower;
@property (nonatomic) int batterySaverShutdownInMins;
@property (nonatomic) int bluetoothEnabledOnStartup;
@property (nonatomic) BOOL enableMultiUserBluetooth;
@property (nonatomic) int enableBluetoothSimplePinConfig;
@property (nonatomic) int optimizeForThisManyClientsConfig;
@property (nonatomic, strong) id<BEGpsDataloggerAccessoryDelegate> dataloggerDelegate;
@property (nonatomic, readonly) BOOL passcodeFeatureEnabled;
@property (nonatomic, readonly) BOOL passcodeCurrentlyLocked;
@property (nonatomic) BOOL passcodeRequiredForDatalogRead;
@property (nonatomic) BOOL passcodeRequiredForDatalogDelete;
@property (nonatomic) BOOL passcodeRequiredForFirmwareUpdate;
@property (nonatomic) BOOL passcodeRequiredForConfigurationChanges;
@property (nonatomic) int elfPortBaudRateConfig;
@property (nonatomic) int elfPortOverrideConfiguration;
@property (nonatomic) NSString *nickname;

///---------------------------
/// @name Start and Stop Datalogging
///---------------------------

/**
 Starts the device to log GPS data
 
 @return BOOL
 */
- (BOOL)startLogging;
/**
 Stops the device from logging data
 
 @return BOOL
 */
- (BOOL)stopLogging;

///---------------------------
/// @name Read & Modify Data Log files
///---------------------------

/**
 Reads the device's log list
 
 @return BOOL
 */
- (BOOL)readLogList;
/**
 Reads the contents of the data-log from the device.
 
 @param log Instance of BEGPSDatalog
 @return BOOL
 */
- (BOOL)readLogContents:(id<BEGpsDatalog>)log;
/**
 Deletes a log from the device
 
 @param log Instance of BEGPSDatalog
 @return BOOL
 */
- (BOOL)deleteLog:(id<BEGpsDatalog>)log;
/**
 Cancels the transfer of the log from the device to the app
 
 @return nil
 */
- (BOOL)cancelLogTransferInProgress;



///---------------------------
/// @name Passcode functions: enable, disable, change passcode, unlock, and lock
///---------------------------

/**
 Enables the passcode lock feature on the hardware using the specified numeric passcode
 
 @param log Instance of BEGPSDatalog
 @return BOOL returns true if the password feature was successfully enabled
 */
-(BOOL) enablePasscodeFeature:(NSString*)passcode;
/**
 Disables the passcode feature on the hardware.  This assumes the hardware is already unlocked.
 
 @return BOOL
 */
-(BOOL) disablePasscodeFeature;
/**
 Changes the passcode used to lock the device.  The device must be unlocked.
 
@param NSString The desired new passcode
 @return BOOL returns TRUE if the passcode was successfully changed.
 */
-(BOOL) changePasscode:(NSString*)newPasscode;
/**
 Attempts to unlock the device using the given passcode
 
 @param NSString The passcode used to lock the device
 @return BOOL
 */
-(BOOL) unlockPasscode:(NSString*)passcode;
/**
 Locks the device using the existing passcode stored in the hardware.
 
 @return BOOL returns TRUE if device is successfully locked.
 */
-(BOOL) lockPasscode;

@end