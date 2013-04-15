//
//  BitcoinVarInt.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/14/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinVarInt.h"
#import "NSData+Integer.h"

@implementation BitcoinVarInt

+(id) varintFromValue:(uint64_t)value{
	return [[BitcoinVarInt alloc] initFromValue:value];
}

+(id) varintFromBytes:(NSData*)data fromOffset:(int)offset{
	return [[BitcoinVarInt alloc] initFromBytes:data fromOffset:offset];
}

// Creates a varInt from the integer value, so we can encode it to bytes later
-(id)initFromValue:(uint64_t)value{
	if ((self = [super init])){
		_value = value;
		_size = [self sizeOf:value];
	}
	
	return self;
}

// Creates a varInt from NSData bytes (like off the network stream)
-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		uint8_t first = [data offsetToInt8:offset];
		if (first < 253) {
			// 8 bits.
			_value = first;
			_size = 1;
		}
		else if (first == 253) {
			// 16 bits.
			_value = [data offsetToInt16:offset+1];
			_size = 3;
		}
		else if (first == 254) {
			// 32 bits.
			_value = [data offsetToInt32:offset+1];
			_size = 5;
		}
		else {
			// 64 bits.
			_value = [data offsetToInt64:offset+1];
			_size = 9;
		}
	}
	
	return self;
}

// Given an integer value, calculates the "size"
-(uint8_t)sizeOf:(uint64_t)value{
	if (value < 253)
		return 1;
	else if (value < 65536)
		return 3;  // 1 marker + 2 data bytes
	else if (value < 4294967296)
		return 5;  // 1 marker + 4 data bytes
	return 9; // 1 marker + 4 data bytes
}

// Returns the NSData byte representation of a varInt, like for writing over the network
-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	switch (self.size) {
		case 1:
			[data appendData:[NSData dataWithInt8:(uint8_t)self.value]];
			break;
		case 3:
			[data appendData:[NSData dataWithInt8:253]];
			[data appendData:[NSData dataWithInt16:(uint16_t)self.value]];
			break;
		case 5:
			[data appendData:[NSData dataWithInt8:254]];
			[data appendData:[NSData dataWithInt32:(uint32_t)self.value]];
			break;
		case 9:
			[data appendData:[NSData dataWithInt8:255]];
			[data appendData:[NSData dataWithInt64:self.value]];
			break;
	}
	
	return data;
}

@end
