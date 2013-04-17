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
#import "BitcoinAddress.h"
#import "BitcoinMessageHeader.h"
#import "BitcoinVersionMessage.h"

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

- (void)testNSData8Bit
{
	uint8_t value1 = 15;
	NSData *data1 = [NSData dataWithInt8:value1];
	
	const char bytes[] = { 0x0f };
	NSData *data2 = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	uint8_t value2 = [data2 offsetToInt8:0];
	
	STAssertEqualObjects(data1, data2, @"8bit NSData objects do not match");
	STAssertEquals(value1, value2, @"8bit NSData values do not match");
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

- (void)testBitcoinAddress
{
	//uint32_t time = 1366044839;
	uint64_t services = 1;
	NSString *address = @"::ffff:10.0.0.1";
	uint16_t port = 8333;
	NSUInteger length = 26;
	
	char bytes[] = {
		//0xA7, 0x30, 0x6C, 0x51, // Time 1366044839
		0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 1 (NODE_NETWORK)
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x0A, 0x00, 0x00, 0x01, // IPv6: ::ffff:10.0.0.1 or IPv4: 10.0.0.1
		0x20, 0x8D // Port 8333
	};
	NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinAddress *address1 = [BitcoinAddress addressFromBytes:data fromOffset:0];
	//STAssertEquals(address1.time, time, @"Address time does not match");
	STAssertEquals(address1.services, services, @"Address services does not match");
	STAssertEqualObjects(address1.address, address, @"Address address does not match");
	STAssertEquals(address1.port, port, @"Address port does not match");
	
	NSData *dataFromAddress1 = [address1 getData];
	STAssertEqualObjects(dataFromAddress1, data, @"Address data does not match");
	STAssertEquals([dataFromAddress1 length], length, @"Address length does not match");
	
	BitcoinAddress *address2 = [BitcoinAddress addressFromAddress:address withPort:port];
	NSData *dataFromAddress2 = [address2 getData];
	STAssertEquals([dataFromAddress2 length], length, @"Address length does not match");
	
	BitcoinAddress *address3 = [BitcoinAddress addressFromBytes:dataFromAddress2 fromOffset:0];
	//STAssertEquals(address2.time, address3.time, @"Address time does not match");
	STAssertEquals(address2.services, address3.services, @"Address services does not match");
	STAssertEqualObjects(address2.address, address3.address, @"Address address does not match");
	STAssertEquals(address2.port, address3.port, @"Address port does not match");
}

- (void)testBitcoinVersionMessage
{
	// Actual message captured over the wire.
	// Something seems fucked with the address blocks, though. Happily, we decode everything else just dandy
	char bytes[] = {
		// Header
		0x0b, 0x11, 0x09, 0x07, // magic (0x0709110B -- testnet)
		0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x00, 0x00, 0x00, 0x00, 0x00, // packet content ("version")
		0x67, 0x00, 0x00, 0x00, // 103 bytes
		0x64, 0x50, 0x59, 0x11, // checksum
		
		// Message
		0x71, 0x11, 0x01, 0x00, // version (70001)
		0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services (NODE_NETWORK)
		0xd7, 0xf3, 0x65, 0x51, 0x00, 0x00, 0x00, 0x00, // unix timestamp (1365636055)
		
		0x01, 0x00, 0x00, 0x00, // time
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00,
		
		0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		
		0x74, 0x17, 0xba, 0xcd, 0x5c, 0xbb, 0xbc, 0x15, // node id
		0x12, // 18 bytes (length of version)
		0x2f, 0x53, 0x61, 0x74, 0x6f, 0x73, 0x68, 0x69, 0x3a, 0x30, 0x2e, 0x38, 0x2e, 0x31, 0x2e, 0x39, 0x39, 0x2f, // User agent ("/Satoshi:0.8.1.99/")
		0x61, 0x00, 0x01, 0x00 // last block (65633)
	};
	
	NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinMessageHeader *messageHeader1 = [BitcoinMessageHeader headerFromBytes:data fromOffset:0];
	BitcoinVersionMessage *versionMessage1 = [BitcoinVersionMessage messageFromBytes:data fromOffset:BITCOIN_HEADER_LENGTH];
	
	// Test header
	uint32_t magic = 0x0709110B;
	uint32_t length = 103;
	uint32_t checksum = 291065956;
	STAssertEquals(messageHeader1.magic, magic, @"Version header magic does not match");
	STAssertEquals(messageHeader1.messageType, 1, @"Version header messageType does not match");
	STAssertEquals(messageHeader1.length, length, @"Version header length does not match");
	STAssertEquals(messageHeader1.checksum, checksum, @"Version checksum magic does not match");
	
	// Test payload
	int32_t version = 70001;
	uint64_t services = 1;
	int64_t timestamp = 1365636055;
	uint64_t nonce = 1566332777681000308;
	NSString *user_agent = @"/Satoshi:0.8.1.99/";
	int32_t start_height = 65633;
	bool relay = false;
	
	STAssertEquals(versionMessage1.version, version, @"Version message version does not match");
	STAssertEquals(versionMessage1.services, services, @"Version message services does not match");
	STAssertEquals(versionMessage1.timestamp, timestamp, @"Version message timestamp does not match");
	STAssertEquals(versionMessage1.nonce, nonce, @"Version message nonce does not match");
	STAssertEqualObjects(versionMessage1.user_agent, user_agent, @"Version message user_agent does not match");
	STAssertEquals(versionMessage1.start_height, start_height, @"Version message start_height does not match");
	STAssertEquals(versionMessage1.relay, relay, @"Version message relay does not match");
	
	NSData *versionData = [versionMessage1 getData];
	STAssertEquals(messageHeader1.length, (uint32_t)[versionData length], @"Version header length does not match version data length");
}

-(void)testMessageHeader
{
	char bytes[] = {
		// Header:
		0x0b, 0x11, 0x09, 0x07, // magic
		0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x00, 0x00, 0x00, 0x00, 0x00, // "version" command
		0x67, 0x00, 0x00, 0x00, // 103 bytes -- OK?
		0x67, 0xb2, 0xb2, 0x6f, // Checksum -- OK?
		
		// Message:
		0x71, 0x11, 0x01, 0x00, // version (70001)
		0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services
		0xf4, 0x2b, 0x6e, 0x51, 0x00, 0x00, 0x00, 0x00, // unix timestamp (2013-04-16 21:58:28)
		
		// addr_recv
		0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, // address
		0x00, 0x00, // port
		
		// addr_from
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, // address
		0x00, 0x00, // port
		
		0xd3, 0xa4, 0x1e, 0x39, 0xff, 0x59, 0x0d, 0xae, // Nonce
		0x12, // User agent length (18 bytes)
		0x2f, 0x53, 0x61, 0x74, 0x6f, 0x73, 0x68, 0x69, 0x3a, 0x30, 0x2e, 0x38, 0x2e, 0x31, 0x2e, 0x39, 0x39, 0x2f, // User agent (/Satoshi:0.8.1.99/)
		0xf5, 0x06, 0x01, 0x00 // Block height
		// Relay not present
	};
	
	NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinMessageHeader *messageHeader1 = [BitcoinMessageHeader headerFromBytes:data fromOffset:0];
	BitcoinVersionMessage *versionMessage1 = [BitcoinVersionMessage messageFromBytes:data fromOffset:BITCOIN_HEADER_LENGTH];
	
	NSData *versionData = [versionMessage1 getData];
	NSLog(@"%@", versionData);
	BitcoinMessageHeader *messageHeader2 = [BitcoinMessageHeader headerFromPayload:versionData withMessageType:BITCOIN_MESSAGE_TYPE_VERSION];
	
	STAssertEquals(messageHeader1.magic, messageHeader2.magic, @"Header magic does not match");
	STAssertEquals(messageHeader1.messageType, messageHeader2.messageType, @"Header messageType does not match");
	STAssertEquals(messageHeader1.length, messageHeader2.length, @"Header length does not match");
	STAssertEquals(messageHeader1.checksum, messageHeader2.checksum, @"Header checksum does not match");
}

@end
