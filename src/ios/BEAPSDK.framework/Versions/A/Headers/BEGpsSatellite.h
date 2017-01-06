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
 The Bad Elf GPS Satellite class provides information on the satellites in use by the connected GPS accessory. 
 This information is used primarily in aiding in accuracy and detecting the type of lock the GPS accessory has.
 */

@protocol BEGpsSatellite <NSObject>

/**
 Checks if satellites are in use by the GPS
 */
@property(readonly, nonatomic) BOOL inUse;
/**
 The 1023 bit code from the satellite
 */
@property(readonly, nonatomic) uchar prn;

/**
 Elevation of the satellite in Degrees
 */
@property(readonly, nonatomic) uchar elevationInDegrees;

/**
 The position of the GPS in the sky (azimuth)
 */
@property(readonly, nonatomic) ushort azimuth;

/**
 The GPS' Signal to Noise Ratio
 */
@property(readonly, nonatomic) uchar SNR;

/**
 Checks if GLONASS is in use by the satellite
 */
@property(readonly, nonatomic) BOOL GLONASS;

@end
