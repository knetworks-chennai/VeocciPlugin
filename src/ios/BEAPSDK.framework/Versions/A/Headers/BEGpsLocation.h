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

#import "BECommonTypes.h"

/**
 The GPS Location class provides location information from the connected Bad Elf GPS. The information is collected internally from the Bad Elf GPS devices and used in substitue of the CoreLocation information where possible.
 
 */

typedef enum {
	BE_GPS_LOCK_TYPE_OFF_OR_SEARCHING = 0,
	BE_GPS_LOCK_TYPE_GPS = 1,
	BE_GPS_LOCK_TYPE_WAAS = 2	
} BEGpsLockType_t;

@protocol BEGpsLocation <NSObject>

///---------------------------
/// @name Latitude and Longitude
///---------------------------

/**
 Latitude in degrees from the GPS
 */
@property(readonly, nonatomic) double latitudeDegrees;
/**
 Longitude in degrees from the GPS
 */
@property(readonly, nonatomic) double longitudeDegrees;

///---------------------------
/// @name Speed
///---------------------------

/**
 Measured speed in knots
 */
@property(readonly, nonatomic) double speedKnots;
/**
 Measured speed in kilometers/hour
 */
@property(readonly, nonatomic) double speedKph;
/**
 Measured speed in MPH
 */
@property(readonly, nonatomic) double speedMph;

///---------------------------
/// @name Altitude
///---------------------------

/**
 Measured Altitude in Meters
 */
@property(readonly, nonatomic) double altitudeMeters;
/**
 Measured Altitude in Feet
 */
@property(readonly, nonatomic) double altitudeFeet;
/**
 Time stamp of the recieved data
 */
@property (readonly, nonatomic) NSDate *timestamp;

///---------------------------
/// @name GPS Data Accuracy
///---------------------------

/**
 GPS Device's Horizontal Accuracy in meters
 */
@property(readonly, nonatomic) double horizontalAccuracyMeters;
/**
 GPS Device's Horizontal Accuracy in feet
 */
@property(readonly, nonatomic) double horizontalAccuracyFeet;
/**
 GPS Device's Vertical Accuracy in meters
 */
@property(readonly, nonatomic) double verticalAccuracyMeters;
/**
 GPS Devices Vertical Accuracy in feet
 */
@property(readonly, nonatomic) double verticalAccuracyFeet;
/**
 GPS Device's 3D Position Accuracy in Meters
 */
@property(readonly, nonatomic) double positionAccuracyMeters;
/**
 GPS Device's 3D Position Accuracy in feet
 */
@property(readonly, nonatomic) double positionAccuracyFeet;

///---------------------------
/// @name GPS Lock Types
///---------------------------

/**
 The type of GPS lock based on position and interferance
 */
@property(readonly, nonatomic) BEGpsLockType_t gpsLockType;
/**
 Check if GLONASS is enabled and in use
 */
@property(readonly, nonatomic) bool GLONASS;

@property(readonly, nonatomic) uchar hours;
@property(readonly, nonatomic) uchar minutes;
@property(readonly, nonatomic) uchar seconds;
@property(readonly, nonatomic) ushort milliseconds;
@property(readonly, nonatomic) uchar day;
@property(readonly, nonatomic) uchar month;
@property(readonly, nonatomic) uchar year;
@property(readonly, nonatomic) long latitude;
@property(readonly, nonatomic) long longitude;
@property(readonly, nonatomic) long altitudeDeciMeters;
@property(readonly, nonatomic) ushort speedDeciKnots;
@property(readonly, nonatomic) ushort trackDeciDegrees;
@property(readonly, nonatomic) uchar satellitesInUseCount;
@property(readonly, nonatomic) ushort deciHdop;
@property(readonly, nonatomic) ushort deciVdop;
@property(readonly, nonatomic) ushort deciPdop;

@end

