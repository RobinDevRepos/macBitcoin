//
//  NSString+StringToHexData.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/27/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "NSString+StringToHexData.h"

@implementation NSString (StringToHexData)

//
// Decodes an NSString containing hex encoded bytes into an NSData object
//
- (NSData *) stringToHexData
{
    int len = [self length] / 2;    // Target length
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {'\0','\0','\0'};
	
    int i;
    for (i=0; i < [self length] / 2; i++) {
        byte_chars[0] = [self characterAtIndex:i*2];
        byte_chars[1] = [self characterAtIndex:i*2+1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }
	
    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}

@end
