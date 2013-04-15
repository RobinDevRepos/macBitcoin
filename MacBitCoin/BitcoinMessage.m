//
//  BitcoinMessage.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/13/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinMessage.h"

@implementation BitcoinMessage

+(id) messageFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinMessage alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if ((self = [super init])){
		_bytes = [data subdataWithRange:NSMakeRange(offset, data.length-offset)];
	}
	
	return self;
}

@end
