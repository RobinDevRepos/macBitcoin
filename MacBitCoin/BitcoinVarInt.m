//
//  BitcoinVarInt.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/14/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinVarInt.h"

@implementation BitcoinVarInt

-(id)initFromValue:(uint64_t)value{
	if ((self = [super init])){
		self.value = value;
		self.size = [self sizeOf:value];
	}
	
	return self;
}

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

-(uint8_t)sizeOf:(uint64_t)value{
	if (value < 253)
		return 1;
	else if (value < 65536)
		return 3;  // 1 marker + 2 data bytes
	else if (value < 4294967296)
		return 5;  // 1 marker + 4 data bytes
	return 9; // 1 marker + 4 data bytes
}

@end
