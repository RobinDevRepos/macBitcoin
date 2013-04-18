//
//  BitcoinPeer.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/17/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinPeer.h"
#import "BitcoinMessageHeader.h"

#import "BitcoinVersionMessage.h"

#define CONNECT_TIMEOUT 1.0

@implementation BitcoinPeer

+(id) peerFromAddress:(NSString*)address withPort:(UInt16)port{
	return [[BitcoinPeer alloc] initFromAddress:address withPort:port];
}

-(id) initFromAddress:(NSString*)address withPort:(UInt16)port{
	BitcoinAddress *bitcoinAddress = [BitcoinAddress addressFromAddress:address withPort:port];
	return [self initFromBitcoinAddress:bitcoinAddress];
}

+(id) peerFromBitcoinAddress:(BitcoinAddress*)address{
	return [[BitcoinPeer alloc] initFromBitcoinAddress:address];
}

-(id) initFromBitcoinAddress:(BitcoinAddress*)address{
	if ((self = [super init])){
		_address = address;
	}
	
	return self;
}

-(void) connect{
	if (!self.socket) return;
	
	// Are we already connected?
	if ([self isConnected]){
		return;
	}
	
	
	// Connect
	NSError *error = nil;
	if (![self.socket connectToHost:self.address.address onPort:self.address.port withTimeout:CONNECT_TIMEOUT error:&error])
	{
		NSLog(@"Error connecting: %@", error);
		return;
	}
	
	self.lastSeenTime = [[NSDate date] timeIntervalSince1970];
}

-(void) connect:(GCDAsyncSocket*)socket{
	self.socket = socket;
	[self connect];
}

-(void) send:(NSData*)payload withMessageType:(BitcoinMessageType)type{
	[self connect];
	
	BitcoinMessageHeader *header = [BitcoinMessageHeader headerFromPayload:payload withMessageType:type];
	NSData *headerData = [header getData];
	
	NSLog(@"%@", headerData);
	[self.socket writeData:headerData withTimeout:-1.0 tag:0];
	
	NSLog(@"%@", payload);
	[self.socket writeData:payload withTimeout:-1.0 tag:0];
}

-(uint32_t) receiveHeader:(NSData*)data{
	if (![self isConnected]) return 0;
	
	self.header = [BitcoinMessageHeader headerFromBytes:[NSData dataWithData:data] fromOffset:0];
	return self.header.length;
}

-(void) receivePayload:(NSData*)data{
	if (![self isConnected]) return;
	if (![self header]) return;
	if ([self.header length] != [data length]) return;
	if ([BitcoinMessageHeader buildChecksum:data] != [self.header checksum]) return;
	
	if (self.header.messageType == BITCOIN_MESSAGE_TYPE_VERSION){
		BitcoinVersionMessage *versionMessage1 = [BitcoinVersionMessage messageFromBytes:data fromOffset:0];
		self.version = [versionMessage1 version];
		self.address = versionMessage1.addr_from;
		
		// TODO: Decide whether we like this version or not and respond
	}
	else{
		return;
	}
	
	self.header = nil;
	self.lastSeenTime = [[NSDate date] timeIntervalSince1970];
}

-(BOOL) isConnected{
	return (self.socket && !self.socket.isDisconnected);
}

-(void) pushVersion{
	if (![self isConnected]) return;
	// TODO: Check if we've already done this?
	
	// TODO: A lot of the data that pertains to our local state needs to come from somewhere centralized
	
	BitcoinVersionMessage *versionMessage = [BitcoinVersionMessage message];
	
	BitcoinAddress *addr_recv = [BitcoinAddress addressFromAddress:self.address.address withPort:self.address.port];
	versionMessage.addr_recv = addr_recv;
	
	BitcoinAddress *addr_from = [BitcoinAddress addressFromAddress:self.socket.localHost withPort:self.socket.localPort];
	versionMessage.addr_from = addr_from;
	
	// Send message
	NSLog(@"sending version: version %d, blocks=%d, us=%@:%d, them=%@:%d, peer=%@:%d", versionMessage.version, versionMessage.start_height, versionMessage.addr_from.address, versionMessage.addr_from.port, versionMessage.addr_recv.address, versionMessage.addr_recv.port, versionMessage.addr_recv.address, versionMessage.addr_recv.port);
	
	[self send:[versionMessage getData] withMessageType:BITCOIN_MESSAGE_TYPE_VERSION];
}

@end
