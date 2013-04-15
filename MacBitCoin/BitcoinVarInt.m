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
// TODO: Turn this conversion code into general byte array conversion code
-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		uint8_t *buf = (uint8_t *)[data bytes];
		
		uint8_t first = buf[offset++];
		if (first < 253) {
			// 8 bits.
			_value = first;
			_size = 1;
		}
		else if (first == 253) {
			// 16 bits.
			_value = buf[offset++]
				| ((uint16_t)buf[offset] << 8 );
			_size = 3;
		}
		else if (first == 254) {
			// 32 bits.
			_value = buf[offset++]
				| ((uint16_t)buf[offset++] << 8 )
				| ((uint32_t)buf[offset++] << 16)
				| ((uint32_t)buf[offset]   << 24);
			_size = 5;
		}
		else {
			// 64 bits.
			_value = buf[offset++]
				| ((uint16_t)buf[offset++] << 8 )
				| ((uint32_t)buf[offset++] << 16)
				| ((uint32_t)buf[offset++] << 24)
				| ((uint64_t)buf[offset++] << 32)
				| ((uint64_t)buf[offset++] << 40)
				| ((uint64_t)buf[offset++] << 48)
				| ((uint64_t)buf[offset]   << 56);
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
// TODO: Turn this conversion code into general byte array conversion code
-(NSData*) getData{
	NSMutableData *data;
	unsigned char buffer[9];
	switch (self.size) {
		case 1:
			buffer[0] = (uint8_t)self.value;
			data = [NSData dataWithBytes:buffer length:1];
			break;
		case 3:
			buffer[0] = 253; // 0xfd
			buffer[1] = (uint8_t)self.value;
			buffer[2] = (uint8_t)(self.value >> 8);
			data = [NSData dataWithBytes:buffer length:3];
			break;
		case 5:
			buffer[0] = 254; // 0xfe
			buffer[1] = (uint8_t)self.value;
			buffer[2] = (uint8_t)(self.value >> 8 );
			buffer[3] = (uint8_t)(self.value >> 16);
			buffer[4] = (uint8_t)(self.value >> 24);
			data = [NSData dataWithBytes:buffer length:5];
			break;
		case 9:
			buffer[0] = 255; // 0xff
			buffer[1] = (uint8_t)self.value;
			buffer[2] = (uint8_t)(self.value >> 8 );
			buffer[3] = (uint8_t)(self.value >> 16);
			buffer[4] = (uint8_t)(self.value >> 24);
			buffer[5] = (uint8_t)(self.value >> 32);
			buffer[6] = (uint8_t)(self.value >> 40);
			buffer[7] = (uint8_t)(self.value >> 48);
			buffer[8] = (uint8_t)(self.value >> 56);
			data = [NSData dataWithBytes:buffer length:9];
			break;
	}
	
	return data;
}

@end
