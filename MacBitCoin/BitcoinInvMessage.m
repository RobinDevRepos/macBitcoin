//
//  BitcoinInvMessage.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/18/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinInvMessage.h"
#import "BitcoinVarInt.h"
#import "BitcoinInventoryVector.h"

@implementation BitcoinInvMessage

// Default constructors for when you want to make a message by hand
+(id)message{
	return [[BitcoinInvMessage alloc] init];
}

// Init a version message with payload bytes
+(id) messageFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinInvMessage alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		
		_count = [BitcoinVarInt varintFromBytes:data fromOffset:offset];
		
		offset += [_count size];
		_inventory = [NSMutableArray arrayWithCapacity:[_count value]];
		for (int i=0; i<[_count value]; i++){
			BitcoinInventoryVector *vector = [BitcoinInventoryVector inventoryVectorFromBytes:data fromOffset:offset];
			[_inventory addObject:vector];
			offset += 36;
		}
	}
	
	return self;
}

// Encode our payload
-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[_count getData]];
	for (BitcoinInventoryVector	*vector	in [self inventory]){
		[data appendData:[vector getData]];
	}
	
	return data;
}

@end
