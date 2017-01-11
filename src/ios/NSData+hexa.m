//
//  NSData+hexa.m
//  EADataEnt
//
//  Created by SG on 16/04/2015.
//  Copyright (c) 2015 Aman Enterprises Inc. All rights reserved.
//

#import "NSData+hexa.h"

@implementation NSData (hexa)

- (NSString *)hexadecimalString {
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger dataLength  = [self length];
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i) {
        // We only deal with ASCII, 0..127 so char is good
        char byte = dataBuffer[i];
        [hexString appendString:[NSString stringWithFormat:@"%c", byte]];
    }
    
    return [NSString stringWithString:hexString];
}


@end
