//
//  BitcoinAddress.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/14/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinAddress.h"
#import "NSData+Integer.h"
#import "GCDAsyncSocket.h"

@implementation BitcoinAddress


-(id) initFromAddress:(NSData*)address{
	if ((self = [super init])){
		_address = [NSData dataWithData:address];
	}
	
	return self;
}

-(id) initFromBytes:(NSData*)data fromOffset:(int)offset{
	if ((self = [super init])){
	}
	
	return self;
}

-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	[data appendData:[NSData dataWithInt32:self.time]];
	[data appendData:[NSData dataWithInt64:self.services]];
	
	NSString *address;
	uint16_t port;
	[GCDAsyncSocket getHost:&address port:&port fromAddress:self.address];
	[data appendData:[address dataUsingEncoding:NSASCIIStringEncoding]];
	[data appendData:[NSData dataWithInt16:ntohs(port)]];
	
	return data;
}

@end
