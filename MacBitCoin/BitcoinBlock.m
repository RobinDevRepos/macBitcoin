//
//  BitcoinBlock.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/19/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinBlock.h"

#import "NSData+Integer.h"
#import "BitcoinVarInt.h"

@implementation BitcoinBlock

// Default constructors for when you want to make a block by hand
+(id)block{
	return [[BitcoinBlock alloc] init];
}

// Init a version message with payload bytes
+(id) blockFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinBlock alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		
		_version = [data offsetToInt32:offset];
		
		offset += 4;
		_prev_block = [data subdataWithRange:NSMakeRange(offset, 32)];
		
		offset += 32;
		_merkle_root = [data subdataWithRange:NSMakeRange(offset, 32)];
		
		offset += 32;
		_timestamp = [data offsetToInt32:offset];
		
		offset += 4;
		_bits = [data offsetToInt32:offset];
		
		offset += 4;
		_nonce = [data offsetToInt32:offset];
		
		offset += 4;
		_txn_count = [BitcoinVarInt varintFromBytes:data fromOffset:offset];
		
		offset += [_txn_count size];
		_transactions = [NSMutableArray arrayWithCapacity:[_txn_count value]];
		for (int i=0; i<[_txn_count value]; i++){
			// TODO: These are "tx" commands, not just bytes
			[_transactions addObject:[data subdataWithRange:NSMakeRange(offset, 32)]];
			offset += 32;
		}
	}
	
	return self;
}

// Encode our payload
-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[NSData dataWithInt32:self.version]];
	
	[data appendData:self.prev_block];
	[data appendData:self.merkle_root];
	
	[data appendData:[NSData dataWithInt32:self.timestamp]];
	[data appendData:[NSData dataWithInt32:self.bits]];
	[data appendData:[NSData dataWithInt32:self.nonce]];
	
	[data appendData:[self.txn_count getData]];
	for (NSData	*tx in [self transactions]){
		[data appendData:tx]; // TODO: These are "tx" commands, not just bytes
	}
	
	return data;
}

@end
