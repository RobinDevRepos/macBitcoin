//
//  BitcoinAddress.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/14/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinAddress.h"
#import "NSData+Integer.h"

#import <arpa/inet.h>

@implementation BitcoinAddress

+(id) addressFromAddress:(NSString*)address withPort:(uint16_t)port{
	return [[BitcoinAddress alloc] initFromAddress:address withPort:(uint16_t)port];
}

+(id) addressFromBytes:(NSData*)data fromOffset:(int)offset{
	return [[BitcoinAddress alloc] initFromBytes:data fromOffset:offset];
}

-(id) initFromAddress:(NSString*)address withPort:(uint16_t)port{
	if ((self = [super init])){
		_time = [[NSDate date] timeIntervalSince1970];
		_services = 1; // TODO: Constant!
		_address = address;
		_port = port;
	}
	
	return self;
}

-(id) initFromBytes:(NSData*)data fromOffset:(int)offset{
	if ((self = [super init])){
		//_time = [data offsetToInt32:offset];
		//offset += 4;
		_services = [data offsetToInt64:offset];
		
		// Read 16 bytes out into an array
		uint8_t bytes[16];
		offset += 8;
		[data getBytes:bytes range:NSMakeRange(offset, 16)];
		
		// Convert the byte array from network to string format
		char ip[INET6_ADDRSTRLEN];
		const char *conversion = inet_ntop(AF_INET6, &bytes, ip, sizeof(ip));
		
		// If the conversion worked, convert the string format array into an NSString
		if (conversion != NULL){
			NSString *address = [NSString stringWithCString:ip encoding:NSASCIIStringEncoding];
			_address = [address stringByReplacingOccurrencesOfString:@"::ffff:" withString:@""];
		}
		
		// Read out port from network byte order
		offset += 16;
		_port = htons([data offsetToInt16:offset]);
	}
	
	return self;
}

-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	//[data appendData:[NSData dataWithInt32:self.time]];
	[data appendData:[NSData dataWithInt64:self.services]];
	
	// Read the NSString string format address into NSData
	NSData *addressData = [self.address dataUsingEncoding:NSASCIIStringEncoding];
	
	// Convert to byte array
	char bytes[16];
	[addressData getBytes:bytes length:sizeof(bytes)];
	if (addressData.length == 8){
		// Looks like ipv4 -- encode it into ipv6
		// Probably a better way to do this
		for (int i=0; i<8; i++){
			bytes[i+7] = bytes[i];
		}
		
		bytes[0] = ':';
		bytes[1] = ':';
		bytes[2] = 'f';
		bytes[3] = 'f';
		bytes[4] = 'f';
		bytes[5] = 'f';
		bytes[6] = ':';
	}
	
	// Convert byte array from string format to network format
	unsigned char buf[sizeof(struct in6_addr)];
	int conversion = inet_pton(AF_INET6, bytes, buf);
	
	// If the conversion worked, write to the NSData
	if (conversion > 0){
		[data appendData:[NSData dataWithBytes:buf length:sizeof(buf)]];
	}
	
	// Convert port to network byte order before writing it to the data
	[data appendData:[NSData dataWithInt16:ntohs(self.port)]];
	
	return data;
}

@end
