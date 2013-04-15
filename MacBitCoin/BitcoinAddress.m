//
//  BitcoinAddress.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/14/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinAddress.h"

@implementation BitcoinAddress


-(id) initFromAddress:(NSData*)address{
	if ((self = [super init])){
		self.address = [NSData dataWithData:address];
	}
	
	return self;
}

-(id) initFromBytes:(NSData*)data fromOffset:(int)offset{
	if ((self = [super init])){
		uint8_t *buf = (uint8_t *)[data bytes];
	}
	
	return self;
}

-(NSData*) getData{
	NSMutableData *data;
	return data;
}

@end
