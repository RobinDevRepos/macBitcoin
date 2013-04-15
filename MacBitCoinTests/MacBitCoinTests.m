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

- (void)testVarInt
{
	uint64_t value = 15;
	uint8_t size = 1;
	
    BitcoinVarInt *varInt1 = [[BitcoinVarInt alloc] initFromValue:value];
	STAssertEquals(varInt1.value, value, @"Value1 does not match");
	STAssertEquals(varInt1.size, size, @"Size1 does not match");
	
	const char bytes[] = { value };
	NSData *data = [NSData dataWithBytes:bytes length:size];
	BitcoinVarInt *varInt2 = [[BitcoinVarInt alloc] initFromBytes:data fromOffset:0];
	STAssertEquals(varInt2.value, value, @"Value2 does not match");
	STAssertEquals(varInt2.size, size, @"Size2 does not match");

	NSData *dataFromVarInt = [varInt1 getData];
	STAssertEqualObjects(dataFromVarInt, data, @"getData does not match");

}

@end
