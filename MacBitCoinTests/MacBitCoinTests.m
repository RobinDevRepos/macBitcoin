//
//  MacBitCoinTests.m
//  MacBitCoinTests
//
//  Created by Myles Grant on 4/7/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "MacBitCoinTests.h"

#import "NSData+Integer.h"
#import "BitcoinVarInt.h"

@implementation MacBitCoinTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testNSData16Bit
{
	uint16_t value1 = 65535;
	NSData *data1 = [NSData dataWithInt16:value1];
	
	const char bytes[] = { 0xff, 0xff };
	NSData *data2 = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	uint16_t value2 = [data2 offsetToInt16:0];
	
	STAssertEqualObjects(data1, data2, @"16bit NSData objects do not match");
	STAssertEquals(value1, value2, @"16bit NSData values do not match");
}

- (void)testNSData32Bit
{
	uint32_t value1 = 4000000000;
	NSData *data1 = [NSData dataWithInt32:value1];
	
	const char bytes[] = { 0x00, 0x28, 0x6b, 0xee };
	NSData *data2 = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	uint32_t value2 = [data2 offsetToInt32:0];
	
	STAssertEqualObjects(data1, data2, @"32bit NSData objects do not match");
	STAssertEquals(value1, value2, @"32bit NSData values do not match");
}

- (void)testNSData64Bit
{
	uint64_t value1 = 4294967296;
	NSData *data1 = [NSData dataWithInt64:value1];
	
	const char bytes[] = { 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00 };
	NSData *data2 = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	uint64_t value2 = [data2 offsetToInt64:0];
	
	STAssertEqualObjects(data1, data2, @"64bit NSData objects do not match");
	STAssertEquals(value1, value2, @"64bit NSData values do not match");
}

- (void)testVarInt8Bit
{
	uint64_t value = 15;
	uint8_t size = 1;
	
    BitcoinVarInt *varInt1 = [BitcoinVarInt varintFromValue:value];
	STAssertEquals(varInt1.value, value, @"8bit value1 does not match");
	STAssertEquals(varInt1.size, size, @"8bit size1 does not match");
	
	const char bytes[] = { 0x0f };
	NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinVarInt *varInt2 = [BitcoinVarInt varintFromBytes:data fromOffset:0];
	STAssertEquals(varInt2.value, value, @"8bit value2 does not match");
	STAssertEquals(varInt2.size, size, @"8bit size2 does not match");

	NSData *dataFromVarInt = [varInt1 getData];
	STAssertEqualObjects(dataFromVarInt, data, @"8bit getData does not match");
}

- (void)testVarInt16Bit
{
	uint64_t value = 65535;
	uint8_t size = 3;
	
    BitcoinVarInt *varInt1 = [BitcoinVarInt varintFromValue:value];
	STAssertEquals(varInt1.value, value, @"16bit value1 does not match");
	STAssertEquals(varInt1.size, size, @"16bit size1 does not match");
	
	const char bytes[] = { 0xfd, 0xff, 0xff };
	NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinVarInt *varInt2 = [BitcoinVarInt varintFromBytes:data fromOffset:0];
	STAssertEquals(varInt2.value, value, @"16bit value2 does not match");
	STAssertEquals(varInt2.size, size, @"16bit size2 does not match");
	
	NSData *dataFromVarInt = [varInt1 getData];
	STAssertEqualObjects(dataFromVarInt, data, @"16bit getData does not match");
}

- (void)testVarInt32Bit
{
	uint64_t value = 4000000000;
	uint8_t size = 5;
	
    BitcoinVarInt *varInt1 = [BitcoinVarInt varintFromValue:value];
	STAssertEquals(varInt1.value, value, @"32bit value1 does not match");
	STAssertEquals(varInt1.size, size, @"32bit size1 does not match");
	
	const char bytes[] = { 0xfe, 0x00, 0x28, 0x6b, 0xee };
	NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinVarInt *varInt2 = [BitcoinVarInt varintFromBytes:data fromOffset:0];
	STAssertEquals(varInt2.value, value, @"32bit value2 does not match");
	STAssertEquals(varInt2.size, size, @"32bit size2 does not match");
	
	NSData *dataFromVarInt = [varInt1 getData];
	STAssertEqualObjects(dataFromVarInt, data, @"32bit getData does not match");
}

- (void)testVarInt64Bit
{
	uint64_t value = 4294967296;
	uint8_t size = 9;
	
    BitcoinVarInt *varInt1 = [BitcoinVarInt varintFromValue:value];
	STAssertEquals(varInt1.value, value, @"64bit value1 does not match");
	STAssertEquals(varInt1.size, size, @"64bit size1 does not match");
	
	const char bytes[] = { 0xff, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00 };
	NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinVarInt *varInt2 = [BitcoinVarInt varintFromBytes:data fromOffset:0];
	STAssertEquals(varInt2.value, value, @"64bit value2 does not match");
	STAssertEquals(varInt2.size, size, @"64bit size2 does not match");
	
	NSData *dataFromVarInt = [varInt1 getData];
	STAssertEqualObjects(dataFromVarInt, data, @"64bit getData does not match");
}

@end
