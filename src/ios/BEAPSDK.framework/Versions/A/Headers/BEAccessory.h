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
 The 'BEAccessoryDelegate' is used to check if the connected Bad Elf GPS Device disconnects from the device at anytime,
 it is also used in the detection and displaying of the manufacturer information on the device.
 
 */

@protocol BEAccessory;

@protocol BEAccessoryDelegate<NSObject>

@optional

///---------------------------
/// @name Handling Disconnection
///---------------------------

/**
 Checks if the accessory disconnects from the device
 
 @param accessory Instance of the BEAccessory
 @return nil
 @see BEAccessory
 */
- (void)accessoryDidDisconnect:(id<BEAccessory>)accessory;
@end

/**
 The 'BEAccessory' class provides basic information about the connected Bad Elf hardware.
 This information is used in displaying basic information to the user about their connected device.
 It is also used in the opening and closing of sessions for the devices.
 
 ## Accessory Information Provided
 
 - Name
 - Manufacturer
 - Model Number
 - Serial Number
 - Firmware Revision
 - Hardware Revision
 
 This information is not specific to just Bad Elf devices, this information is for any connected accessory,
 however only devices that conform to the 'com.bad-elf.gps' identifier will be allowed to open or close sessions.
 
 */

@protocol BEAccessory<NSObject>

@required 
@property (nonatomic, strong) id<BEAccessoryDelegate> delegate;
@property (nonatomic, readonly, getter=isAccessoryConnected) BOOL accessoryConnected;
@property (nonatomic, readonly, getter=isSessionOpen) BOOL sessionOpen;

/**
 The hardware name of the connected accessory
 */
@property(nonatomic, readonly) NSString *name;
/**
 The manufacturer ID of the connected accessory
 */
@property(nonatomic, readonly) NSString *manufacturer;
/**
 The model number of the connected accessory
 */
@property(nonatomic, readonly) NSString *modelNumber;
/**
 The Unique serial number of the connected accessory
 */
@property(nonatomic, readonly) NSString *serialNumber;
/**
 The current revision of firmware on the connected accessory
 */
@property(nonatomic, readonly) NSString *firmwareRevision;
/**
 The current revision of hardware of the connectec accessory
 */
@property(nonatomic, readonly) NSString *hardwareRevision;

///---------------------------
/// @name Handling Sessions
///---------------------------

/**
 Checks if the session has been opened for the connected accessory
 
 @return Boolean if the device session was opened
 */
- (BOOL)openSession;

/**
 Closes the active accessory session
 
 @return nil
 */
- (void)closeSession;

@end
