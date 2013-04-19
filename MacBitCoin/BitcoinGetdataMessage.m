//
//  BitcoinGetdataMessage.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/19/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinGetdataMessage.h"

#import "BitcoinVarInt.h"
#import "BitcoinInventoryVector.h"

@implementation BitcoinGetdataMessage

// Default constructors for when you want to make a message by hand
+(id)message{
	return [[BitcoinGetdataMessage alloc] init];
}

// Init a version message with payload bytes
+(id) messageFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinGetdataMessage alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		
		_count = [BitcoinVarInt varintFromBytes:data fromOffset:offset];
		
		if ([_count value] <= MAX_INV_COUNT){
			offset += [_count size];
			_inventory = [NSMutableArray arrayWithCapacity:[_count value]];
			for (int i=0; i<[_count value]; i++){
				BitcoinInventoryVector *vector = [BitcoinInventoryVector inventoryVectorFromBytes:data fromOffset:offset];
				[_inventory addObject:vector];
				offset += 36;
			}
		}
	}
	
	return self;
}

// Encode our payload
-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	if ([_count value] > MAX_INV_COUNT) return data;
	
	[data appendData:[_count getData]];
	for (BitcoinInventoryVector	*vector	in [self inventory]){
		[data appendData:[vector getData]];
	}
	
	return data;
}

@end
