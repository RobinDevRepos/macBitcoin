//
//  MacBitCoinTests.m
//  MacBitCoinTests
//
//  Created by Myles Grant on 4/7/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "MacBitCoinTests.h"

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

- (void)testVarInt8Bit
{
	uint64_t value = 15;
	uint8_t size = 1;
	
    BitcoinVarInt *varInt1 = [[BitcoinVarInt alloc] initFromValue:value];
	STAssertEquals(varInt1.value, value, @"8bit value1 does not match");
	STAssertEquals(varInt1.size, size, @"8bit size1 does not match");
	
	const char bytes[] = { 0x0f };
	NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinVarInt *varInt2 = [[BitcoinVarInt alloc] initFromBytes:data fromOffset:0];
	STAssertEquals(varInt2.value, value, @"8bit value2 does not match");
	STAssertEquals(varInt2.size, size, @"8bit size2 does not match");

	NSData *dataFromVarInt = [varInt1 getData];
	STAssertEqualObjects(dataFromVarInt, data, @"8bit getData does not match");
}

- (void)testVarInt16Bit
{
	uint64_t value = 65535;
	uint8_t size = 3;
	
    BitcoinVarInt *varInt1 = [[BitcoinVarInt alloc] initFromValue:value];
	STAssertEquals(varInt1.value, value, @"16bit value1 does not match");
	STAssertEquals(varInt1.size, size, @"16bit size1 does not match");
	
	const char bytes[] = { 0xfd, 0xff, 0xff };
	NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinVarInt *varInt2 = [[BitcoinVarInt alloc] initFromBytes:data fromOffset:0];
	STAssertEquals(varInt2.value, value, @"16bit value2 does not match");
	STAssertEquals(varInt2.size, size, @"16bit size2 does not match");
	
	NSData *dataFromVarInt = [varInt1 getData];
	STAssertEqualObjects(dataFromVarInt, data, @"16bit getData does not match");
}

@end
