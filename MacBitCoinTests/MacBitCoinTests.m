//
//  MacBitCoinTests.m
//  MacBitCoinTests
//
//  Created by Myles Grant on 4/7/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "MacBitCoinTests.h"

#import "NSData+Integer.h"
#import "NSData+DataToHexString.h"
#import "NSString+StringToHexData.h"
#import "NSData+ReverseBytes.h"

#import "Definitions.h"
#import "BitcoinVarInt.h"
#import "BitcoinAddress.h"
#import "BitcoinMessageHeader.h"
#import "BitcoinVersionMessage.h"
#import "BitcoinAddrMessage.h"
#import "BitcoinInvMessage.h"
#import "BitcoinInventoryVector.h"
#import "BitcoinGetblocksMessage.h"
#import "BitcoinBlock.h"
#import "BitcoinTransaction.h"

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
	uint32_t time = 1366044839;
	uint64_t services = 1;
	NSString *address = @"::ffff:10.0.0.1";
	uint16_t port = 8333;
	NSUInteger length = 30;
	
	char bytes[] = {
		0xA7, 0x30, 0x6C, 0x51, // Time 1366044839
		0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 1 (NODE_NETWORK)
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x0A, 0x00, 0x00, 0x01, // IPv6: ::ffff:10.0.0.1 or IPv4: 10.0.0.1
		0x20, 0x8D // Port 8333
	};
	NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinAddress *address1 = [BitcoinAddress addressFromBytes:data fromOffset:0];
	STAssertEquals(address1.time, time, @"Address time does not match");
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
		
		0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, // address
		0x00, 0x00, // port
		
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, // address
		0x00, 0x00, // port
		
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
	BitcoinMessageHeader *messageHeader2 = [BitcoinMessageHeader headerFromPayload:versionData withMessageType:BITCOIN_MESSAGE_TYPE_VERSION];
	
	STAssertEquals(messageHeader1.magic, messageHeader2.magic, @"Header magic does not match");
	STAssertEquals(messageHeader1.messageType, messageHeader2.messageType, @"Header messageType does not match");
	STAssertEquals(messageHeader1.length, messageHeader2.length, @"Header length does not match");
	STAssertEquals(messageHeader1.checksum, messageHeader2.checksum, @"Header checksum does not match");
}

-(void)testAddrMessage
{
	char bytes[] = {
		0x01, // length
		0xd4, 0x53, 0x70, 0x51, // timestamp
		0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x6c, 0x3d, 0x4d, 0x4a, // address
		0x47, 0x9d // 18333
	};
	
	NSData *data1 = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinAddrMessage *message1 = [BitcoinAddrMessage messageFromBytes:data1 fromOffset:0];
	
	uint64_t length = 1;
	STAssertEquals(message1.count.value, length, @"Addr length does not match");
	STAssertEquals([message1.addresses count], length, @"Addr array length does not match");

	uint32_t time = 1366315988;
	uint64_t services = 1;
	NSString *address = @"::ffff:108.61.77.74";
	uint16_t port = 18333;
	
	BitcoinAddress *address1 = [message1.addresses objectAtIndex:0];
	
	STAssertEquals(address1.time, time, @"Address time does not match");
	STAssertEquals(address1.services, services, @"Address services does not match");
	STAssertEqualObjects(address1.address, address, @"Address address does not match");
	STAssertEquals(address1.port, port, @"Address port does not match");
	
	NSData *data2 = [message1 getData];
	STAssertEqualObjects(data1, data2, @"Encoded addr messages do not match");
}

-(void)testInvMessage
{
	char bytes[] = {
		0x01, // length
		0x01, 0x00, 0x00, 0x00, // object type
		0xdc, 0x7a, 0x03, 0xbe, 0xcb, 0x18, 0x5a, 0x02, 0x4b, 0xe7, 0x30, 0x5f, 0xfe, 0x4e, 0x31, 0x28, 0x19, 0x50, 0x4f, 0x36, 0x67, 0xff, 0x29, 0xaf, 0x48, 0xc1, 0x43, 0x97, 0x17, 0xdd, 0x44, 0x82 // hash
	};
	
	NSData *data1 = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinInvMessage *message1 = [BitcoinInvMessage messageFromBytes:data1 fromOffset:0];
	
	uint64_t length = 1;
	STAssertEquals(message1.count.value, length, @"Inventory length does not match");
	STAssertEquals([message1.inventory count], length, @"Inventory array length does not match");
	
	BitcoinInventoryVector *vector1 = [message1.inventory objectAtIndex:0];
	STAssertEquals(vector1.type, BITCOIN_INV_OBJ_TYPE_MSG_TX, @"Inventory vector object type does not match");
}

-(void)testGetblocksMessage
{
	char bytes[] = {
		0x71, 0x11, 0x01, 0x00, // version
		0x02, // count
		0x43, 0x49, 0x7f, 0xd7, 0xf8, 0x26, 0x95, 0x71, 0x08, 0xf4, 0xa3, 0x0f, 0xd9, 0xce, 0xc3, 0xae, 0xba, 0x79, 0x97, 0x20, 0x84, 0xe9, 0x0e, 0xad, 0x01, 0xea, 0x33, 0x09, 0x00, 0x00, 0x00, 0x00,
		0x43, 0x49, 0x7f, 0xd7, 0xf8, 0x26, 0x95, 0x71, 0x08, 0xf4, 0xa3, 0x0f, 0xd9, 0xce, 0xc3, 0xae, 0xba, 0x79, 0x97, 0x20, 0x84, 0xe9, 0x0e, 0xad, 0x01, 0xea, 0x33, 0x09, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 // hash_stop
	};
	
	NSData *data1 = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinGetblocksMessage *message1 = [BitcoinGetblocksMessage messageFromBytes:data1 fromOffset:0];
	
	uint32_t version = 70001;
	uint64_t count = 2;
	STAssertEquals(message1.version, version, @"Getblocks version does not match");
	STAssertEquals(message1.count.value, count, @"Getblocks hash length does not match");
	STAssertEquals([message1.hashes count], count, @"Getblocks hash array length does not match");
}

-(void)testTransaction
{
	char bytes[] = {
		// Transaction:
		0x01, 0x00, 0x00, 0x00, // - version
		
		// Inputs:
		0x01, // - number of transaction inputs
		
		// Input 1:
		0x6D, 0xBD, 0xDB, 0x08, 0x5B, 0x1D, 0x8A, 0xF7,  0x51, 0x84, 0xF0, 0xBC, 0x01, 0xFA, 0xD5, 0x8D, // - previous output (outpoint)
		0x12, 0x66, 0xE9, 0xB6, 0x3B, 0x50, 0x88, 0x19,  0x90, 0xE4, 0xB4, 0x0D, 0x6A, 0xEE, 0x36, 0x29,
		0x00, 0x00, 0x00, 0x00,
		
		0x8B, // - script is 10x39, bytes long
		
		0x48, 0x30, 0x45, 0x02, 0x21, 0x00, 0xF3, 0x58,  0x1E, 0x19, 0x72, 0xAE, 0x8A, 0xC7, 0xC7, 0x36, // - signature script (scriptSig)
		0x7A, 0x7A, 0x25, 0x3B, 0xC1, 0x13, 0x52, 0x23,  0xAD, 0xB9, 0xA4, 0x68, 0xBB, 0x3A, 0x59, 0x23,
		0x3F, 0x45, 0xBC, 0x57, 0x83, 0x80, 0x02, 0x20,  0x59, 0xAF, 0x01, 0xCA, 0x17, 0xD0, 0x0E, 0x41,
		0x83, 0x7A, 0x1D, 0x58, 0xE9, 0x7A, 0xA3, 0x1B,  0xAE, 0x58, 0x4E, 0xDE, 0xC2, 0x8D, 0x35, 0xBD,
		0x96, 0x92, 0x36, 0x90, 0x91, 0x3B, 0xAE, 0x9A,  0x01, 0x41, 0x04, 0x9C, 0x02, 0xBF, 0xC9, 0x7E,
		0xF2, 0x36, 0xCE, 0x6D, 0x8F, 0xE5, 0xD9, 0x40,  0x13, 0xC7, 0x21, 0xE9, 0x15, 0x98, 0x2A, 0xCD,
		0x2B, 0x12, 0xB6, 0x5D, 0x9B, 0x7D, 0x59, 0xE2,  0x0A, 0x84, 0x20, 0x05, 0xF8, 0xFC, 0x4E, 0x02,
		0x53, 0x2E, 0x87, 0x3D, 0x37, 0xB9, 0x6F, 0x09,  0xD6, 0xD4, 0x51, 0x1A, 0xDA, 0x8F, 0x14, 0x04,
		0x2F, 0x46, 0x61, 0x4A, 0x4C, 0x70, 0xC0, 0xF1,  0x4B, 0xEF, 0xF5,
		
		0xFF, 0xFF, 0xFF, 0xFF, // - sequence
		
		// Outputs:
		0x02, // - 2 Output Transactions
		
		// Output 1:
		0x40, 0x4B, 0x4C, 0x00, 0x00, 0x00, 0x00, 0x00, //  - 0.05, BTC (5000000)
		0x19, // - pk_script is 0x25, bytes long
		
		0x76, 0xA9, 0x14, 0x1A, 0xA0, 0xCD, 0x1C, 0xBE,  0xA6, 0xE7, 0x45, 0x8A, 0x7A, 0xBA, 0xD5, 0x12, // - pk_script
		0xA9, 0xD9, 0xEA, 0x1A, 0xFB, 0x22, 0x5E, 0x88,  0xAC,
		
		// Output 2:
		0x80, 0xFA, 0xE9, 0xC7, 0x00, 0x00, 0x00, 0x00, // - 33.54, BTC (3354000000)
		0x19, // - pk_script is 0x25, bytes long
		
		0x76, 0xA9, 0x14, 0x0E, 0xAB, 0x5B, 0xEA, 0x43,  0x6A, 0x04, 0x84, 0xCF, 0xAB, 0x12, 0x48, 0x5E, // - pk_script
		0xFD, 0xA0, 0xB7, 0x8B, 0x4E, 0xCC, 0x52, 0x88,  0xAC,
		
		// Locktime:
		0x00, 0x00, 0x00, 0x00 // - lock time
	};
	
	NSData *data1 = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	BitcoinTransaction *transaction = [BitcoinTransaction transactionFromBytes:data1 fromOffset:0];
	
	uint32_t version = 1;
	STAssertEquals(transaction.version, version, @"Transaction version does not match");
	
	uint64_t txInCount = 1;
	STAssertEquals(transaction.tx_in_count.value, txInCount, @"Transaction tx in length does not match");
	STAssertEquals([transaction.tx_in count], txInCount, @"Transaction tx in array length does not match");
	
	BitcoinTxIn *txIn = [transaction.tx_in objectAtIndex:0];
	
	uint64_t scriptLength = 139;
	STAssertEquals(txIn.script_length.value, scriptLength, @"Transaction tx in 1 script length does not match");
	STAssertEquals([txIn.computational_script length], scriptLength, @"Transaction tx in 1 script length does not match");
	
	uint32_t sequence = UINT32_MAX;
	STAssertEquals(txIn.sequence, sequence, @"Transaction tx in 1 sequence does not match");
	
	uint64_t txOutCount = 2;
	STAssertEquals(transaction.tx_out_count.value, txOutCount, @"Transaction tx out length does not match");
	STAssertEquals([transaction.tx_out count], txOutCount, @"Transaction tx out array length does not match");
	
	BitcoinTxOut *txOut = [transaction.tx_out objectAtIndex:0];
	
	scriptLength = 25;
	STAssertEquals(txOut.pk_script_length.value, scriptLength, @"Transaction tx out 1 script length does not match");
	STAssertEquals([txOut.pk_script length], scriptLength, @"Transaction tx out 1 script length does not match");
	
	uint64_t value = 0.05 * COIN;
	STAssertEquals(txOut.value, value, @"Transaction tx out 1 value does not match");
	
	txOut = [transaction.tx_out objectAtIndex:1];
	
	scriptLength = 25;
	STAssertEquals(txOut.pk_script_length.value, scriptLength, @"Transaction tx out 2 script length does not match");
	STAssertEquals([txOut.pk_script length], scriptLength, @"Transaction tx out 2 script length does not match");
	
	value = 33.54 * COIN;
	STAssertEquals(txOut.value, value, @"Transaction tx out 2 value does not match");

	uint32_t lock_time = 0;
	STAssertEquals(transaction.lock_time, lock_time, @"Transaction lock_time does not match");
	
	NSData *data2 = [transaction getData];
	STAssertEqualObjects(data1, data2, @"Encoded transactions do not match");
}

-(void)testGenesisBlock
{
	BitcoinBlock *genesisBlock = [BitcoinBlock genesisBlock];
	
	BitcoinTransaction *transaction = [[genesisBlock transactions] objectAtIndex:0];
	
	uint32_t version = 1;
	STAssertEquals(transaction.version, version, @"Genesis block transaction version does not match");
	
	uint64_t txInCount = 1;
	STAssertEquals(transaction.tx_in_count.value, txInCount, @"Genesis block transaction tx in length does not match");
	STAssertEquals([transaction.tx_in count], txInCount, @"Genesis block transaction tx in array length does not match");
	
	BitcoinTxIn *txIn = [transaction.tx_in objectAtIndex:0];
	
	uint64_t scriptLength = 77;
	STAssertEquals(txIn.script_length.value, scriptLength, @"Genesis block transaction tx in 1 script length does not match");
	STAssertEquals([txIn.computational_script length], scriptLength, @"Genesis block transaction tx in 1 script length does not match");
	
	uint32_t sequence = UINT32_MAX;
	STAssertEquals(txIn.sequence, sequence, @"Genesis block transaction tx in 1 sequence does not match");
	
	uint64_t txOutCount = 1;
	STAssertEquals(transaction.tx_out_count.value, txOutCount, @"Genesis block transaction tx out length does not match");
	STAssertEquals([transaction.tx_out count], txOutCount, @"Genesis block transaction tx out array length does not match");
	
	BitcoinTxOut *txOut = [transaction.tx_out objectAtIndex:0];
	
	scriptLength = 67;
	STAssertEquals(txOut.pk_script_length.value, scriptLength, @"Genesis block transaction tx out 1 script length does not match");
	STAssertEquals([txOut.pk_script length], scriptLength, @"Genesis block transaction tx out 1 script length does not match");
	
	uint64_t value = 50 * COIN;
	STAssertEquals(txOut.value, value, @"Genesis block transaction tx out 1 value does not match");
	
	uint32_t lock_time = 0;
	STAssertEquals(transaction.lock_time, lock_time, @"Genesis block transaction lock_time does not match");
	
	NSLog(@"Block data: %@", [genesisBlock getData]);
	NSLog(@"TX hash: %@", [transaction getHash]);
	
	NSData *expectedMerkleRoot = [[@"4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b" stringToHexData] reverseBytes];
	STAssertEqualObjects([genesisBlock getMerkleRoot], expectedMerkleRoot, @"Genesis block merkle root does not match");
	
	NSData *hash = [genesisBlock getHash];
	
	NSString *genesisHash = @"000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943";
	NSData *data1 = [[genesisHash stringToHexData] reverseBytes];
	STAssertEqualObjects(hash, data1, @"Genesis block hash does not match");
}

// https://en.bitcoin.it/wiki/Block_hashing_algorithm
-(void)testExampleBlock
{
	BitcoinBlock *exampleBlock = [BitcoinBlock block];
	[exampleBlock setPrevBlock:@"81cd02ab7e569e8bcd9317e2fe99f2de44d49ab2b8851ba4a308000000000000"];
	[exampleBlock setMerkleRoot:@"e320b6c2fffc8d750423db8b1eb942ae710e951ed797f7affc8892b0f1fc122b"];
	exampleBlock.timestamp = 0x4dd7f5c7;
	exampleBlock.bits = 0x1a44b9f2;
	exampleBlock.nonce = 0x9546a142;
	
	NSData *hash = [exampleBlock getHash];
	
	char bytes[] = {
		0x1d, 0xbd, 0x98, 0x1f, 0xe6, 0x98, 0x57, 0x76, 0xb6, 0x44, 0xb1, 0x73, 0xa4, 0xd0, 0x38, 0x5d,
		0xdc, 0x1a, 0xa2, 0xa8, 0x29, 0x68, 0x8d, 0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	};
	NSData *data1 = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	STAssertEqualObjects(hash, data1, @"Example block hash does not match");
}

@end
