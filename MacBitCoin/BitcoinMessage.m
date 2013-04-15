//
//  BitcoinMessage.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/13/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinMessage.h"
#import "NSData+Integer.h"
#import "NSData+CryptoHashing.h"

@implementation BitcoinMessage

// Creates a message from its byte representation of header + payload
+(id) messageFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinMessage alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		// Read and decode header
		NSData *header = [data subdataWithRange:NSMakeRange(offset, BITCOIN_HEADER_LENGTH)];
		
		_magic = [header offsetToInt32:offset];
		
		NSString *command = [[NSString alloc] initWithData:[header subdataWithRange:NSMakeRange(offset+4, BITCOIN_COMMAND_LENGTH)] encoding:NSASCIIStringEncoding];
		
		_length = [header offsetToInt32:offset+16];
		_checksum = [header offsetToInt32:offset+20];
		
		// Rest of message is payload
		_payload = [data subdataWithRange:NSMakeRange(offset+BITCOIN_HEADER_LENGTH, _length)];
	}
	
	return self;
}

// Creates a message from its byte representation of just payload
// Calculates the rest of the header vars from it
+(id) messageFromPayload:(NSData *)data fromOffset:(int)offset withType:(BitcoinMessageType)messageType{
	return [[BitcoinMessage alloc] initFromPayload:data fromOffset:offset withType:messageType];
}

-(id)initFromPayload:(NSData *)data fromOffset:(int)offset withType:(BitcoinMessageType)messageType{
	if ((self = [super init])){
		_magic = 0x0709110B; // TODO: This is testnet magic
		_messageType = messageType;
		_length = (uint32_t)data.length - offset;
		_payload = [data subdataWithRange:NSMakeRange(offset, _length)];
		_checksum = [[[_payload sha256Hash] sha256Hash] offsetToInt32:0];
	}
	
	return self;
}

-(NSData*) getData {
	return self.payload;
}

@end
