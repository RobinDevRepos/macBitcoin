//
//  BitcoinAddrMessage.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/18/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinAddrMessage.h"
#import "BitcoinVarInt.h"
#import "BitcoinAddress.h"

@implementation BitcoinAddrMessage

// Default constructors for when you want to make a message by hand
+(id)message{
	return [[BitcoinAddrMessage alloc] init];
}

-(id)init{
	if (self = [super init]){
		_count = [BitcoinVarInt varintFromValue:0];
		_addresses = [NSMutableArray arrayWithCapacity:0];
	}
	
	return self;
}

// Init a version message with payload bytes
+(id) messageFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinAddrMessage alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		
		_count = [BitcoinVarInt varintFromBytes:data fromOffset:offset];
		
		offset += [_count size];
		_addresses = [NSMutableArray arrayWithCapacity:[_count value]];
		for (int i=0; i<[_count value]; i++){
			BitcoinAddress *address = [BitcoinAddress addressFromBytes:data fromOffset:offset];
			[_addresses addObject:address];
			offset += 30;
		}
	}
	
	return self;
}

-(void)pushAddress:(BitcoinAddress*)address{
	[self.addresses addObject:address];
	self.count = [BitcoinVarInt varintFromValue:[self.addresses count]];
}

// Encode our payload
-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[_count getData]];
	for (BitcoinAddress *address in [self addresses]){
		[data appendData:[address getData]];
	}
	
	return data;
}

@end
