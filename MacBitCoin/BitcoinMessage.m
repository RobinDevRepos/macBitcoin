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
		NSLog(@"Header: %@", header);
		
		_magic = [header offsetToInt32:offset]; // TODO: Validate this
		
		NSString *command = [[NSString alloc] initWithData:[header subdataWithRange:NSMakeRange(offset+4, BITCOIN_COMMAND_LENGTH)] encoding:NSASCIIStringEncoding];
		// TODO: Convert this into message type AND maybe upgrade this object and parse the payload?
		
		_length = [header offsetToInt32:offset+16];
		_checksum = [header offsetToInt32:offset+20];
		
		// Rest of message is payload
		if (data.length == offset+BITCOIN_HEADER_LENGTH+_length){
			_payload = [data subdataWithRange:NSMakeRange(offset+BITCOIN_HEADER_LENGTH, _length)];
			NSLog(@"Payload: %@", _payload);
		}
		
		// TODO: Check checksum and throw exception
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
		_messageType = messageType;
		_payload = [data subdataWithRange:NSMakeRange(offset, data.length-offset)];
		
		[self generateHeader]; // TODO: Is this safe to do?
	}
	
	return self;
}

// Builds the header vars from the payload
-(void)generateHeader{
	if (!self.payload)
		self.payload = [self getPayload];
	
	// TODO: Exception if payload is empty
	self.magic = 0x0709110B; // TODO: This is testnet magic
	self.length = (uint32_t)self.payload.length;
	self.checksum = [[[self.payload sha256Hash] sha256Hash] offsetToInt32:0];
}

// Calculates a header and returns it
-(NSData*) getHeader{
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

// Just returns the payload
-(NSData*) getPayload{
	return self.payload;
}

// Returns header and then payload
-(NSData*) getData {
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[self getHeader]];
	[data appendData:[self getPayload]];
	
	return data;
}

// Returns the command name from our message type
-(NSString*)getCommandName{
	NSString *name;
	switch (self.messageType) {
		case BITCOIN_MESSAGE_TYPE_VERSION:
			name = @"version";
			break;
			
		default:
			break;
	}
	
	return name;
}

@end
