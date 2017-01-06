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
 The BEAccessoryManagerDelegate checks if the device disconnects or connects to the iOS Devices
 
 */

@protocol BEAccessory;

@protocol BEAccessoryManagerDelegate <NSObject>

///---------------------------
/// @name Device Connection and Disconnection
///---------------------------

/**
 Checks if the accessory did connect
 
 @param accessory The connecting BEAccessory instance
 @return nil
 
 */
- (void)accessoryDidConnect:(id<BEAccessory>)accessory;

/**
 Checks if the accessory disconnected
 
 @param accessory The disconnecting BEAccessory instance
 @return nil
 
 */
- (void)accessoryDidDisconnect:(id<BEAccessory>)accessory;
@end

/**
 The 'BEAccessoryManager' class provides methods to detect the connected Bad Elf devices and compare their hardware/firmware revisions
 
 */

@interface BEAccessoryManager : NSObject 

/**
 An Array of the BEAccessory objects
 */
@property (nonatomic, readonly) NSArray *connectedAccessories; // array of BEAccessory objects

/**
 Instance of the 'BEAccessoryManagerDelegate'
 */
@property (nonatomic, strong) id<BEAccessoryManagerDelegate> delegate;

///---------------------------
/// @name Hardware/Firmware Revisions
///---------------------------

/**
 Compares revisions of the hardware and firmware
 
 @param revision String value of the revision
 @param baseline String value of the baseline revision
 @return int Int value of the revisions
 */
+ (int) compareRevision: (NSString *)revision baseline: (NSString *) baseline;

@end


