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

#import "SimpleBadElfGpsManager.h"

@interface SimpleBadElfGpsManager()
@property (nonatomic, strong) BEAccessoryManager *accessoryManager;
@property (nonatomic, strong) id <BEGpsAccessory> selectedHardwareRaw;
@property (nonatomic, strong) NSMutableArray *detectedHardwareRaw;
@property (nonatomic) BOOL started;
@end

@implementation SimpleBadElfGpsManager

//@synthesize detectedHardwareRaw = _detectedHardwareRaw;
//@synthesize accessoryManager = _accessoryManager;
//@synthesize selectedHardwareRaw = _selectedHardwareRaw;
//@synthesize started;

@dynamic selectedHardware;
@dynamic detectedHardware;

//@synthesize delegate;
//@synthesize autoOpenAccessories;
//
//@synthesize defaultGpsFormat;
//@synthesize defaultSatelliteData;
//@synthesize defaultGpsReportingRate;

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
