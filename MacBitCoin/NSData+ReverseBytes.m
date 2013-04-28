//
//  NSData+ReverseBytes.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/27/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "NSData+ReverseBytes.h"

@implementation NSData (ReverseBytes)

-(NSData*) reverseBytes{
	
	const char *bytes = [self bytes];
	int idx = [self length] - 1;
	char *reversedBytes = calloc(sizeof(char), [self length]);
	for (int i=0; i< [self length]; i++){
		reversedBytes[idx--] = bytes[i];
	}
	
	NSData *reversedData = [NSData dataWithBytes:reversedBytes length:[self length]];
	free(reversedBytes);
	return reversedData;
}

@end
