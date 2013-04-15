//
//  BitcoinVarInt.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/14/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinVarInt.h"

@implementation BitcoinVarInt

// Creates a varInt from the integer value, so we can encode it to bytes later
-(id)initFromValue:(uint64_t)value{
	if ((self = [super init])){
		self.value = value;
		self.size = [self sizeOf:value];
	}
	
	return self;
}

// Creates a varInt from NSData bytes (like off the network stream)
// TODO: Turn this conversion code into general byte array conversion code
-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		uint64_t *buf = (uint64_t *)[data bytes];
		
		uint8_t first = (uint8_t)buf[offset];
		if (first < 253) {
			// 8 bits.
			self.value = first;
			self.size = 1;
		}
		else if (first == 253) {
			// 16 bits.
			self.value =
				((uint16_t)buf[offset + 1] << 0 ) |
				((uint16_t)buf[offset + 2] << 8 );
			self.size = 3;
		}
		else if (first == 254) {
			// 32 bits.
			self.value =
				((uint16_t)buf[offset + 1] << 0 ) |
				((uint16_t)buf[offset + 2] << 8 ) |
				((uint32_t)buf[offset + 3] << 16) |
				((uint32_t)buf[offset + 4] << 24);
			self.size = 5;
		}
		else {
			// 64 bits.
			self.value =
				((uint16_t)buf[offset + 1] << 0 ) |
				((uint16_t)buf[offset + 2] << 8 ) |
				((uint32_t)buf[offset + 3] << 16) |
				((uint32_t)buf[offset + 4] << 24) |
				((uint64_t)buf[offset + 5] << 32) |
				((uint64_t)buf[offset + 6] << 40) |
				((uint64_t)buf[offset + 7] << 48) |
				((uint64_t)buf[offset + 8] << 56);
			self.size = 9;
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
			buffer[0] = self.value;
			data = [NSData dataWithBytes:buffer length:1];
			break;
		case 3:
			buffer[0] = 253; // 0xfd
			buffer[1] = (uint16_t)self.value;
			buffer[2] = (uint16_t)self.value >> 8;
			data = [NSData dataWithBytes:buffer length:3];
			break;
		case 5:
			buffer[0] = 254; // 0xfe
			buffer[1] = (uint32_t)self.value;
			buffer[2] = (uint32_t)self.value >> 8;
			buffer[3] = (uint32_t)self.value >> 16;
			buffer[4] = (uint32_t)self.value >> 24;
			data = [NSData dataWithBytes:buffer length:5];
			break;
		case 9:
			buffer[0] = 255; // 0xff
			buffer[1] = self.value;
			buffer[2] = self.value >> 8;
			buffer[3] = self.value >> 16;
			buffer[4] = self.value >> 24;
			buffer[5] = self.value >> 32;
			buffer[6] = self.value >> 40;
			buffer[7] = self.value >> 48;
			buffer[8] = self.value >> 56;
			data = [NSData dataWithBytes:buffer length:9];
			break;
	}
	
	return data;
}

@end
