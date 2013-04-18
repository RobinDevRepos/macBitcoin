//
//  BitcoinInventoryVector.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/18/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinInventoryVector.h"

#import "NSData+Integer.h"

@implementation BitcoinInventoryVector

+(id) inventoryVectorFromBytes:(NSData*)data fromOffset:(int)offset{
	return [[BitcoinInventoryVector alloc] initFromBytes:data fromOffset:offset];
}

// Creates a BitcoinInventoryVector from NSData bytes (like off the network stream)
-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		_type = [data offsetToInt32:offset];
		_hash = [data subdataWithRange:NSMakeRange(offset+4, 32)];
	}
	
	return self;
}

// Returns the NSData byte representation of a BitcoinInventoryVector, like for writing over the network
-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[NSData dataWithInt32:[self type]]];
	[data appendData:_hash];
	
	return data;
}

@end
