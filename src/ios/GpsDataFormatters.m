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

@interface GpsDataFormatters : NSObject

@property (nonatomic, strong) NSNumberFormatter *locationFormatter;

- (BOOL) validLocation: (id<BEGpsLocation>) location;
- (NSString *) formatDegree: (double) degrees direction: (NSString *) direction degreeFormat: (int) degreeFormat;
- (NSString *) latitudeStringFromDegree: (double) degrees;
- (NSString *) longitudeStringFromDegree: (double) degrees;
- (NSString *) latitudeStringFromDegree: (double) degrees degreeFormat: (int) degreeFormat;
- (NSString *) longitudeStringFromDegree: (double) degrees degreeFormat: (int) degreeFormat;
- (NSString *) gpsLockFromLocation: (id<BEGpsLocation>) location;
- (NSString *) stringDateFromLocation: (id<BEGpsLocation>) location;

@end

#import "GpsDataFormatters.h"
#import "SimpleBadElfGpsManager.h"
#import <CoreLocation/CoreLocation.h>

@implementation GpsDataFormatters

- (NSString *) formatDegree: (double) degrees direction: (NSString *) direction degreeFormat: (int) degreeFormat {
    
    double adegrees = fabs(degrees);
    if (degreeFormat == 1) {
        int idegree = adegrees;
        double mdegree = (adegrees - idegree) * 60;
        int iminutes = mdegree;
        double sdegree = (mdegree - iminutes) * 60;
        int iseconds = sdegree;
        NSString *string = [NSString stringWithFormat: @"%d°%02d'%02d\" %@", idegree, iminutes, iseconds, direction];
        return string;
    } else {
        NSNumberFormatter *formatter = self.locationFormatter;
        // initialize if needed
        if (formatter == nil) {
            formatter = [NSNumberFormatter new];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            formatter.maximumFractionDigits = 6;
            formatter.minimumFractionDigits = 6;
            self.locationFormatter = formatter;
        }
        NSNumber *number = [[NSNumber alloc] initWithDouble: adegrees];
        NSString *svalue = [formatter stringFromNumber: number];
        NSString *string = [NSString stringWithFormat: @"%@° %@", svalue, direction];
        return string;
    }
}

- (NSString *) latitudeStringFromDegree: (double) degrees {
    NSString *direction = (degrees < 0) ? @"S" : @"N";
    //int degreeFormat = self.unitsDegree;
    return [self formatDegree: degrees direction: direction degreeFormat: 0];
}

- (NSString *) longitudeStringFromDegree: (double) degrees {
    NSString *direction = (degrees < 0) ? @"W" : @"E";
    //int degreeFormat = self.unitsDegree;
    return [self formatDegree: degrees direction: direction degreeFormat: 0];
}

- (NSString *) latitudeStringFromDegree: (double) degrees degreeFormat: (int) degreeFormat {
    NSString *direction = (degrees < 0) ? @"S" : @"N";
    return [self formatDegree: degrees direction: direction degreeFormat: 0];
}

- (NSString *) longitudeStringFromDegree: (double) degrees degreeFormat: (int) degreeFormat {
    NSString *direction = (degrees < 0) ? @"W" : @"E";
    return [self formatDegree: degrees direction: direction degreeFormat: 0];
}

- (NSString *) gpsLockFromLocation: (id<BEGpsLocation>) location {
    NSString *string= @"Searching";
    if (location != nil) {
        BEGpsLockType_t ivalue = location.gpsLockType;
        switch (ivalue) {
            case 	BE_GPS_LOCK_TYPE_OFF_OR_SEARCHING: {
                string =   @"Searching";
            }
                break;
            case BE_GPS_LOCK_TYPE_GPS: {
                string =   @"Locked";
                if (location.GLONASS) {
                    string = [string stringByAppendingString: @" + GLONASS"];
                }
            }
                break;
            case BE_GPS_LOCK_TYPE_WAAS: {
                CLLocationDegrees longitude = location.longitudeDegrees;
                if (location.GLONASS) {
                    string = @"WAAS + GLONASS";
                    if ((longitude >= 80.0) && (longitude <= 160.0)) {
                        string = @"MSAS + GLONASS";
                    } else if ((longitude >= -40.0) && (longitude <= 80.0)) {
                        string = @"EGNOS + GLONASS";
                    }
                } else {
                    string = @"WAAS Lock";
                    if ((longitude >= 80.0) && (longitude <= 160.0)) {
                        string = @"MSAS Lock";
                    } else if ((longitude >= -40.0) && (longitude <= 80.0)) {
                        string = @"EGNOS Lock";
                    }                 }
            }
                break;
            default:
                break;
        }
    }
    return string;
}

- (BOOL) validLocation: (id<BEGpsLocation>) location {
    if (location == nil) {
        return NO;
    }
    if (location.gpsLockType > BE_GPS_LOCK_TYPE_OFF_OR_SEARCHING) {
        CLLocationDegrees latitude = location.latitudeDegrees;
        if ((latitude <= 90.0) && (latitude >= -90.0)) {
            CLLocationDegrees longitude = location.longitudeDegrees;
            if ((longitude <= 180.0) && (longitude >= -180.0)) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSString *) stringDateFromLocation: (id<BEGpsLocation>) location {
    //<time>2002-02-10T21:01:29.250Z</time>
    //    [self appendString: @"<time>"];
    int year = 2000 + location.year;
    NSMutableString *buffer = [NSMutableString new];
    [buffer appendString: [NSString stringWithFormat: @"%04d" , year]];
    [buffer appendString: @"-"];
    [buffer appendString: [NSString stringWithFormat: @"%02d" , location.month]];
    [buffer appendString: @"-"];
    [buffer appendString: [NSString stringWithFormat: @"%02d" , location.day]];
    [buffer appendString: @"T"];
    [buffer appendString: [NSString stringWithFormat: @"%02d" , location.hours]];
    [buffer appendString: @":"];
    [buffer appendString: [NSString stringWithFormat: @"%02d" , location.minutes]];
    
    int second = location.seconds;
    //if (second != 0) {
    [buffer appendString: @":"];
    [buffer appendString: [NSString stringWithFormat: @"%02d" , second]];
    //}
    int milliseconds = location.milliseconds;
    if (milliseconds != 0) {
        [buffer appendString: @"."];
        [buffer appendString: [NSString stringWithFormat: @"%03d" , milliseconds]];
    }
    [buffer appendString: @"Z"];
    return buffer;
}

@end
