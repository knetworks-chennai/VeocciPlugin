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
#import "SimpleBadElfGpsManager.h"
#import <CoreLocation/CoreLocation.h>

@protocol BEGpsLocation;

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
