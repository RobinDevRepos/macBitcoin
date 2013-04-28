//
//  BitcoinGetblocksMessage.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/19/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinGetblocksMessage.h"

#import "Definitions.h"
#import "NSData+Integer.h"
#import "BitcoinVarInt.h"

@implementation BitcoinGetblocksMessage

// Default constructors for when you want to make a message by hand
+(id)message{
	return [[BitcoinGetblocksMessage alloc] init];
}

-(id)init{
	if ((self = [super init])){
		_version = PROTOCOL_VERSION;
		_count = [BitcoinVarInt varintFromValue:0];
		_hashes = [NSMutableArray arrayWithCapacity:1];
		_hash_stop = [NSMutableData dataWithCapacity:32];
	}
	
	return self;
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

-(void)pushStringHash:(NSString*)hash{
	[self.hashes addObject:[hash dataUsingEncoding:NSASCIIStringEncoding]];
	self.count = [BitcoinVarInt varintFromValue:[self.hashes count]];
}

-(void)pushDataHash:(NSData*)hash{
	[self.hashes addObject:hash];
	self.count = [BitcoinVarInt varintFromValue:[self.hashes count]];
}

// Encode our payload
-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[NSData dataWithInt32:self.version]];
	
	[data appendData:[self.count getData]];
	for (NSData	*hash in [self hashes]){
		[data appendData:hash];
	}
	
	[data appendData:self.hash_stop];
	
	return data;
}

@end
