//
//  BitcoinMessage.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/13/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinMessageHeader.h"

#import "NSData+Integer.h"
#import "NSData+CryptoHashing.h"

@implementation BitcoinMessageHeader

// Creates a header with some defaults
+(id)header{
	return [[BitcoinMessageHeader alloc] init];
}

-(id)init{
	if ((self = [super init])){
		self.magic = BITCOIN_HEADER_MAGIC;
	}
	
	return self;
}

// Creates a header from its byte representation
+(id) headerFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinMessageHeader alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		// Read and decode header
		NSData *header = [data subdataWithRange:NSMakeRange(offset, BITCOIN_HEADER_LENGTH)];
		
		_magic = [header offsetToInt32:offset]; // TODO: Validate this
		
		// Extract command
		char commandBytes[BITCOIN_COMMAND_LENGTH];
		[header getBytes:commandBytes range:NSMakeRange(offset+4, BITCOIN_COMMAND_LENGTH)];
		NSString *command = [NSString stringWithCString:commandBytes encoding:NSASCIIStringEncoding];
		
		// Convert this into message type
		if ([command isEqualToString:@"version"]){
			_messageType = BITCOIN_MESSAGE_TYPE_VERSION;
		}
		else if ([command isEqualToString:@"verack"]){
			_messageType = BITCOIN_MESSAGE_TYPE_VERACK;
		}
		else if ([command isEqualToString:@"addr"]){
			_messageType = BITCOIN_MESSAGE_TYPE_ADDR;
		}
		else if ([command isEqualToString:@"inv"]){
			_messageType = BITCOIN_MESSAGE_TYPE_INV;
		}
		else if ([command isEqualToString:@"getdata"]){
			_messageType = BITCOIN_MESSAGE_TYPE_GETDATA;
		}
		else if ([command isEqualToString:@"getblocks"]){
			_messageType = BITCOIN_MESSAGE_TYPE_GETBLOCKS;
		}
		else if ([command isEqualToString:@"getheaders"]){
			_messageType = BITCOIN_MESSAGE_TYPE_GETHEADERS;
		}
		else if ([command isEqualToString:@"tx"]){
			_messageType = BITCOIN_MESSAGE_TYPE_TX;
		}
		else if ([command isEqualToString:@"block"]){
			_messageType = BITCOIN_MESSAGE_TYPE_BLOCK;
		}
		else if ([command isEqualToString:@"headers"]){
			_messageType = BITCOIN_MESSAGE_TYPE_HEADERS;
		}
		else if ([command isEqualToString:@"getaddr"]){
			_messageType = BITCOIN_MESSAGE_TYPE_GETADDR;
		}
		else if ([command isEqualToString:@"alert"]){
			_messageType = BITCOIN_MESSAGE_TYPE_ALERT;
		}
		else if ([command isEqualToString:@"ping"]){
			_messageType = BITCOIN_MESSAGE_TYPE_PING;
		}
		else{
			// TODO: Throw exception?
		}
		
		_length = [header offsetToInt32:offset+16];
		_checksum = [header offsetToInt32:offset+20];
	}
	
	return self;
}

+(id)headerFromPayload:(NSData*)payload withMessageType:(BitcoinMessageType)type{
	return [[BitcoinMessageHeader alloc] initFromPayload:payload withMessageType:type];
}

-(id)initFromPayload:(NSData*)payload withMessageType:(BitcoinMessageType)type{
	if ((self = [self init])){
		_length = (uint32_t)[payload length];
		_messageType = type;
		_checksum = [BitcoinMessageHeader buildChecksum:payload];
	}
	
	return self;
}

+(uint32_t) buildChecksum:(NSData*)data{
	if (!data) return 0xe2e0f65d;
	
	return [[[data sha256Hash] sha256Hash] offsetToInt32:0];
}

// Returns header data
-(NSData*) getData {
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[NSData dataWithInt32:self.magic]];
	
	uint8_t command[BITCOIN_COMMAND_LENGTH];
	NSString *name = [self getCommandName];
	// TODO: Throw exception if name is null
	for (int i=0; i<BITCOIN_COMMAND_LENGTH; i++){
		if (i < name.length){
			command[i] = [name characterAtIndex:i];
		}
		else{
			command[i] = 0x00;
		}
	}
	[data appendData:[NSData dataWithBytes:command length:BITCOIN_COMMAND_LENGTH]];
	
	[data appendData:[NSData dataWithInt32:self.length]];
	[data appendData:[NSData dataWithInt32:self.checksum]];
	
	return data;
}

// Returns the command name from our message type
-(NSString*)getCommandName{
	NSString *name;
	switch (self.messageType) {
		case BITCOIN_MESSAGE_TYPE_VERSION:
			name = @"version";
			break;
			
		case BITCOIN_MESSAGE_TYPE_VERACK:
			name = @"verack";
			break;
		
		case BITCOIN_MESSAGE_TYPE_ADDR:
			name = @"addr";
			break;
			
		case BITCOIN_MESSAGE_TYPE_INV:
			name = @"inv";
			break;
			
		case BITCOIN_MESSAGE_TYPE_GETDATA:
			name = @"getdata";
			break;
			
		case BITCOIN_MESSAGE_TYPE_GETBLOCKS:
			name = @"getblocks";
			break;
			
		case BITCOIN_MESSAGE_TYPE_GETHEADERS:
			name = @"getheaders";
			break;
			
		case BITCOIN_MESSAGE_TYPE_TX:
			name = @"tx";
			break;

		case BITCOIN_MESSAGE_TYPE_BLOCK:
			name = @"block";
			break;
			
		case BITCOIN_MESSAGE_TYPE_HEADERS:
			name = @"headers";
			break;
			
		case BITCOIN_MESSAGE_TYPE_GETADDR:
			name = @"getaddr";
			break;
			
		case BITCOIN_MESSAGE_TYPE_PING:
			name = @"ping";
			break;
			
		case BITCOIN_MESSAGE_TYPE_ALERT:
			name = @"alert";
			break;
			
		default:
			break;
	}
	
	return name;
}

@end
