//
//  NSData+Integer.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/14/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "NSData+Integer.h"

@implementation NSData (Integer)

-(uint8_t)offsetToInt8:(NSUInteger)offset{
	uint8_t *buf = (uint8_t *)[self bytes];
	
	return buf[offset];
}

-(uint16_t)offsetToInt16:(NSUInteger)offset{
	uint8_t *buf = (uint8_t *)[self bytes];
	
	return buf[offset++]
		| ((uint16_t)buf[offset] << 8 );
}

-(uint32_t)offsetToInt32:(NSUInteger)offset{
	uint8_t *buf = (uint8_t *)[self bytes];
	
	return buf[offset++]
		| ((uint16_t)buf[offset++] << 8 )
		| ((uint32_t)buf[offset++] << 16)
		| ((uint32_t)buf[offset]   << 24);
}

-(uint64_t)offsetToInt48:(NSUInteger)offset{
	uint8_t *buf = (uint8_t *)[self bytes];
	
	return buf[offset++]
		| ((uint16_t)buf[offset++] << 8 )
		| ((uint32_t)buf[offset++] << 16)
		| ((uint32_t)buf[offset++] << 24)
		| ((uint64_t)buf[offset++] << 32)
		| ((uint64_t)buf[offset++] << 40);
}

-(uint64_t)offsetToInt64:(NSUInteger)offset{
	uint8_t *buf = (uint8_t *)[self bytes];
	
	return buf[offset++]
		| ((uint16_t)buf[offset++] << 8 )
		| ((uint32_t)buf[offset++] << 16)
		| ((uint32_t)buf[offset++] << 24)
		| ((uint64_t)buf[offset++] << 32)
		| ((uint64_t)buf[offset++] << 40)
		| ((uint64_t)buf[offset++] << 48)
		| ((uint64_t)buf[offset]   << 56);
}

+(id)dataWithInt8:(uint8_t)value{
	unsigned char buffer[1];
	
	buffer[0] = (uint8_t)value;
	
	return [NSData dataWithBytes:buffer length:sizeof(buffer)];
}

+(id)dataWithInt16:(uint16_t)value{
	unsigned char buffer[2];
	
	buffer[0] = (uint8_t)value;
	buffer[1] = (uint8_t)(value >> 8);
	
	return [NSData dataWithBytes:buffer length:sizeof(buffer)];
}

+(id)dataWithInt32:(uint32_t)value{
	unsigned char buffer[4];
	
	buffer[0] = (uint8_t)value;
	buffer[1] = (uint8_t)(value >> 8 );
	buffer[2] = (uint8_t)(value >> 16);
	buffer[3] = (uint8_t)(value >> 24);
	
	return [NSData dataWithBytes:buffer length:sizeof(buffer)];
}

+(id)dataWithInt64:(uint64_t)value{
	unsigned char buffer[8];
	
	buffer[0] = (uint8_t)value;
	buffer[1] = (uint8_t)(value >> 8 );
	buffer[2] = (uint8_t)(value >> 16);
	buffer[3] = (uint8_t)(value >> 24);
	buffer[4] = (uint8_t)(value >> 32);
	buffer[5] = (uint8_t)(value >> 40);
	buffer[6] = (uint8_t)(value >> 48);
	buffer[7] = (uint8_t)(value >> 56);
	
	return [NSData dataWithBytes:buffer length:sizeof(buffer)];
}

@end
