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

@implementation BitcoinVersionMessage

+(id) messageFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinVersionMessage alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super initFromBytes:data fromOffset:offset])){
		self.messageType = 1;
		
		_version = [data offsetToInt32:offset];
		_services = [data offsetToInt64:offset+4];
		_timestamp = [data offsetToInt64:offset+12];
		_addr_recv = [BitcoinAddress addressFromBytes:data fromOffset:offset+20];
		_addr_from = [BitcoinAddress addressFromBytes:data fromOffset:offset+46];
		_nonce = [data offsetToInt64:offset+72];
		
		BitcoinVarInt *userAgentLength = [BitcoinVarInt varintFromBytes:data fromOffset:offset+80];
		_user_agent = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(offset+80+userAgentLength.size, userAgentLength.value)] encoding:NSASCIIStringEncoding];
		
		_start_height = [data offsetToInt32:offset+80+userAgentLength.size+userAgentLength.value];
		_relay = [data offsetToInt8:offset+80+userAgentLength.size+userAgentLength.value+4];
	}
	
	return self;
}
@end
