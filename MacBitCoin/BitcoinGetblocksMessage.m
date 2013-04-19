//
//  BitcoinGetblocksMessage.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/19/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinGetblocksMessage.h"

#import "NSData+Integer.h"
#import "BitcoinVarInt.h"

@implementation BitcoinGetblocksMessage

// Default constructors for when you want to make a message by hand
+(id)message{
	return [[BitcoinGetblocksMessage alloc] init];
}

// Init a version message with payload bytes
+(id) messageFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinGetblocksMessage alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		
		_version = [data offsetToInt32:offset];
		
		offset += 4;
		_count = [BitcoinVarInt varintFromBytes:data fromOffset:offset];
		
		offset += [_count size];
		_hashes = [NSMutableArray arrayWithCapacity:[_count value]];
		for (int i=0; i<[_count value]; i++){
			[_hashes addObject:[data subdataWithRange:NSMakeRange(offset, 32)]];
			offset += 32;
		}
		
		_hash_stop = [data subdataWithRange:NSMakeRange(offset, 32)];
	}
	
	return self;
}

// Encode our payload
-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[NSData dataWithInt32:self.version]];
	
	[data appendData:[_count getData]];
	for (NSData	*hash in [self hashes]){
		[data appendData:hash];
	}
	
	[data appendData:self.hash_stop];
	
	return data;
}

@end
