//
//  BitcoinHeadersMessage.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/21/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinHeadersMessage.h"

#import "BitcoinVarInt.h"
#import "BitcoinBlock.h"

@implementation BitcoinHeadersMessage

// Default constructors for when you want to make a message by hand
+(id)message{
	return [[BitcoinHeadersMessage alloc] init];
}

-(id)init{
	if ((self = [super init])){
		_count = [BitcoinVarInt varintFromValue:0];
		_headers = [NSMutableArray arrayWithCapacity:1];
	}
	
	return self;
}

// Init a version message with payload bytes
+(id) messageFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinHeadersMessage alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		
		_count = [BitcoinVarInt varintFromBytes:data fromOffset:offset];
		
		offset += [_count size];
		_headers = [NSMutableArray arrayWithCapacity:[_count value]];
		for (int i=0; i<[_count value]; i++){
			[_headers addObject:[BitcoinBlock blockFromBytes:data fromOffset:offset]];
			offset += 81;
		}
	}
	
	return self;
}

-(void)pushHeader:(BitcoinBlock*)block{
	[self.headers addObject:block];
	self.count = [BitcoinVarInt varintFromValue:[self.headers count]];
}

-(NSUInteger)countHeaders{
	return [self.count value];
}

-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[self.count getData]];
	for (BitcoinBlock *block in [self headers]){
		[data appendData:[block getHeaderData]];
	}
	
	return data;
}

@end
