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
	
    BitcoinVarInt *varInt = [[BitcoinVarInt alloc] initFromValue:value];
	STAssertEquals(varInt.value, value, @"Value does not match");
	STAssertEquals(varInt.size, size, @"Size does not match");
}

@end
