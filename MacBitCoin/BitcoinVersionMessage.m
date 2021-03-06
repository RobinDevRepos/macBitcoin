//
//  BitcoinVersionMessage.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/13/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinVersionMessage.h"
#import "BitcoinAddress.h"
#import "BitcoinVarInt.h"
#import "NSData+Integer.h"

#import <Security/SecRandom.h>

@implementation BitcoinVersionMessage

// Default constructors for when you want to make a message by hand
+(id)message{
	return [[BitcoinVersionMessage alloc] init];
}

-(id)init{
	if ((self = [super init])){
		_version = PROTOCOL_VERSION;
		_services = 1; // TODO: Constant!
		_timestamp = [[NSDate date] timeIntervalSince1970];
		
		int nonce_length = 8;
		NSMutableData *nonceData = [NSMutableData dataWithLength:nonce_length];
		SecRandomCopyBytes(kSecRandomDefault, nonce_length, [nonceData mutableBytes]);
		_nonce = [nonceData offsetToInt64:0];
		
		_user_agent = @"/MacBitCoin:1.0/"; // TODO: Constants!
		
		_start_height = 0; // TODO: This is variable, so might be best to leave it to be initialized by the caller
		_relay = true; // https://en.bitcoin.it/wiki/BIP_0037
	}
	
	return self;
}

// Init a version message with payload bytes
+(id) messageFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinVersionMessage alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		if ([data length] < MIN_VERSION_SIZE) return nil;
		
		_version = [data offsetToInt32:offset];
		_services = [data offsetToInt64:offset+4];
		_timestamp = [data offsetToInt64:offset+12];
		
		// Network addresses are not prefixed with a timestamp in the version message.
		_addr_recv = [BitcoinAddress addressFromBytes:data fromOffset:offset+20 withTimestamp:FALSE];
		_addr_from = [BitcoinAddress addressFromBytes:data fromOffset:offset+46 withTimestamp:FALSE];
		
		_nonce = [data offsetToInt64:offset+72];
		
		BitcoinVarInt *userAgentLength = [BitcoinVarInt varintFromBytes:data fromOffset:offset+80];
		_user_agent = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(offset+80+userAgentLength.size, userAgentLength.value)] encoding:NSASCIIStringEncoding];
		
		_start_height = [data offsetToInt32:offset+80+userAgentLength.size+userAgentLength.value];
		//_relay = [data offsetToInt8:offset+80+userAgentLength.size+userAgentLength.value+4];
	}
	
	return self;
}

// Encode our payload
-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[NSData dataWithInt32:self.version]];
	[data appendData:[NSData dataWithInt64:self.services]];
	[data appendData:[NSData dataWithInt64:self.timestamp]];
	
	// Network addresses are not prefixed with a timestamp in the version message.
	[data appendData:[self.addr_recv getData:FALSE]];
	[data appendData:[self.addr_from getData:FALSE]];
	
	[data appendData:[NSData dataWithInt64:self.nonce]];
	
	BitcoinVarInt *userAgentLength = [BitcoinVarInt varintFromValue:self.user_agent.length];
	[data appendData:[userAgentLength getData]];
	[data appendData:[self.user_agent dataUsingEncoding:NSASCIIStringEncoding]];
	
	[data appendData:[NSData dataWithInt32:self.start_height]];
	//[data appendData:[NSData dataWithInt8:self.relay]];
	
	return data;
}

@end
