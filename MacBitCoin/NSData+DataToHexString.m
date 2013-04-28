//
//  NSData+DataToHexString.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/27/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "NSData+DataToHexString.h"

@implementation NSData (DataToHexString)

- (NSString *) dataToHexString
{
    NSUInteger          len = [self length];
    char *              chars = (char *)[self bytes];
    NSMutableString *   hexString = [[NSMutableString alloc] init];
	
    for(NSUInteger i = 0; i < len; i++ )
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
	
    return hexString;
}

@end
