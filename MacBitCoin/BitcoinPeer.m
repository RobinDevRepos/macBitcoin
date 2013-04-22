//
//  BitcoinPeer.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/17/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "Definitions.h"
#import "BitcoinPeer.h"
#import "BitcoinMessageHeader.h"
#import "BitcoinVersionMessage.h"
#import "BitcoinAddrMessage.h"
#import "BitcoinInvMessage.h"
#import "BitcoinGetdataMessage.h"
#import "BitcoinGetblocksMessage.h"
#import "BitcoinBlock.h"

#import "ConnectionManager.h"

#import "DDLog.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

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

-(void) updateAddressFromSocket:(GCDAsyncSocket*)socket{
	NSString *host = [GCDAsyncSocket hostFromAddress:[socket connectedAddress]];
	if ([socket isIPv4]){
		self.address.address = [@"::ffff:" stringByAppendingString:host];
	}
	else{
		self.address.address = host;
	}
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
		DDLogInfo(@"Error connecting: %@", error);
		return;
	}
	
	self.lastSeenTime = [[NSDate date] timeIntervalSince1970];
}

-(void) connect:(GCDAsyncSocket*)socket{
	self.socket = socket;
	[self connect];
}

-(void) disconnect{
	if (![self isConnected]) return;
	
	[[self socket] disconnect];
}

-(void) send:(NSData*)payload withMessageType:(BitcoinMessageType)type{
	[self connect];
	
	BitcoinMessageHeader *header = [BitcoinMessageHeader headerFromPayload:payload withMessageType:type];
	NSData *headerData = [header getData];
	
	DDLogInfo(@"Sending header %d: %@", header.length, headerData);
	[self.socket writeData:headerData withTimeout:-1.0 tag:0];
	
	if (payload){
		DDLogInfo(@"Sending payload %d: %@", (uint32_t)[payload length], payload);
		[self.socket writeData:payload withTimeout:-1.0 tag:0];
	}
}

-(uint32_t) receiveHeader:(NSData*)data{
	if (![self isConnected]) return 0;
	
	self.header = [BitcoinMessageHeader headerFromBytes:[NSData dataWithData:data] fromOffset:0];
	
	// Some message types do not have payloads
	if (self.header.messageType == BITCOIN_MESSAGE_TYPE_VERACK){
		DDLogInfo(@"Got verack: peer=%@:%d", self.address.address, self.address.port);
		self.versionAcked = true;
		
		// TODO: Send 'getaddr' here?
		
		// Ask for blocks. TODO: Base this on our current state
		BitcoinGetblocksMessage *getBlocksMessage = [BitcoinGetblocksMessage message];
		[getBlocksMessage pushHash:@"000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943"];
		DDLogInfo(@"Sending getblocks");
		[self send:[getBlocksMessage getData] withMessageType:BITCOIN_MESSAGE_TYPE_GETBLOCKS];
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_GETADDR){
		DDLogInfo(@"Got getaddr");
		
		BitcoinAddrMessage *addrMessage = [BitcoinAddrMessage message];
		NSArray *peers = [self.manager getActivePeers];
		for (BitcoinPeer *peer in peers){
			[addrMessage pushAddress:[peer address]];
		}
		
		DDLogInfo(@"Sending addr");
		[self send:[addrMessage getData] withMessageType:BITCOIN_MESSAGE_TYPE_ADDR];
	}
	
	return self.header.length;
}

-(void) receivePayload:(NSData*)data{
	if (![self isConnected]) return;
	if (![self header]) return;
	if ([self.header length] != [data length]) return;
	if ([BitcoinMessageHeader buildChecksum:data] != [self.header checksum]) return;
	
	if (self.header.messageType == BITCOIN_MESSAGE_TYPE_VERSION){
		BitcoinVersionMessage *versionMessage = [BitcoinVersionMessage messageFromBytes:data fromOffset:0];
		self.version = [versionMessage version];
		//self.address = [versionMessage addr_from]; // TODO: Test if this is routable before we assign it, and then convert it
		
		// Ignore connections to ourselves
		if (versionMessage.nonce == [[self getOurVersion] nonce]){
			DDLogInfo(@"Ignoring connection to ourselves");
			return;
		}
		
		// TODO: Look for peers with this nonce in general?
		
		// TODO: Decide whether we like this version or not and respond
		DDLogInfo(@"Got version message: version %d, blocks=%d, peer=%@:%d", self.version, versionMessage.start_height, self.address.address, self.address.port);
		if (self.version == PROTOCOL_VERSION){
			// Documentation implies verack and then version, but doing it that way increments your misbehaving score in the official client.
			// Unclear if you should always send your version back, or only if you are accepting connections from it
			
			// Push version
			[self pushVersion];
						
			// Send verack
			DDLogInfo(@"Sending verack");
			[self send:nil withMessageType:BITCOIN_MESSAGE_TYPE_VERACK];

		}
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_ADDR){
		BitcoinAddrMessage *addrMessage = [BitcoinAddrMessage messageFromBytes:data fromOffset:0];
		DDLogInfo(@"Got addr message: %lld", addrMessage.count.value);

		for (BitcoinAddress *newAddress in [addrMessage addresses]){
			[[self manager] addPeer:[BitcoinPeer peerFromBitcoinAddress:newAddress]]; // Blindly add peers, and the connection manager will de-dupe them
			
			// TODO: Relay this to a subset of nodes
		}
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_INV){
		BitcoinInvMessage *invMessage = [BitcoinInvMessage messageFromBytes:data fromOffset:0];
		DDLogInfo(@"Got inv message: %lld", invMessage.count.value);
		
		// TODO: Apparently should send 'getData' for these, if we don't have them
		// Or maybe only if they're BITCOIN_INV_OBJ_TYPE_MSG_BLOCK
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_GETDATA){
		BitcoinGetdataMessage *getDataMessage = [BitcoinGetdataMessage messageFromBytes:data fromOffset:0];
		DDLogInfo(@"Got getdata message: %lld", getDataMessage.count.value);
		
		// TODO: Store these
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_GETBLOCKS){
		BitcoinGetblocksMessage *getBlocksMessage = [BitcoinGetblocksMessage messageFromBytes:data fromOffset:0];
		DDLogInfo(@"Got getblocks message: %lld", getBlocksMessage.count.value);
		
		// TODO: You know, send these back if we have them
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_GETHEADERS){
		BitcoinGetblocksMessage *getHeadersMessage = [BitcoinGetblocksMessage messageFromBytes:data fromOffset:0];
		DDLogInfo(@"Got getheaders message: %lld", getHeadersMessage.count.value);
		
		// TODO: You know, send these back if we have them
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_BLOCK){
		BitcoinBlock *blockMessage = [BitcoinBlock blockFromBytes:data fromOffset:0];
		DDLogInfo(@"Got new block: %@", [blockMessage getHash]);
		
		// TODO: OMG this is, like, the whole point. Do things!
	}
	else{
		DDLogError(@"Received payload of unknown type %d: %@", self.header.messageType, data);
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
	if ([self versionPushed]) return;
	
	BitcoinVersionMessage *versionMessage = [self getOurVersion];
	
	// Who are we talking to this time?
	versionMessage.addr_recv = self.address;
	
	// Freshen timestamp
	versionMessage.timestamp = [[NSDate date] timeIntervalSince1970];
	
	// Send message
	DDLogInfo(@"Sending version: version %d, blocks=%d, us=%@:%d, them=%@:%d, peer=%@:%d", versionMessage.version, versionMessage.start_height, versionMessage.addr_from.address, versionMessage.addr_from.port, versionMessage.addr_recv.address, versionMessage.addr_recv.port, versionMessage.addr_recv.address, versionMessage.addr_recv.port);
	
	[self send:[versionMessage getData] withMessageType:BITCOIN_MESSAGE_TYPE_VERSION];
	self.versionPushed = true;
}

-(BitcoinVersionMessage*) getOurVersion{
	ConnectionManager *manager = [self manager];
	if (manager){
		return [manager ourVersion];
	}
	
	return [BitcoinVersionMessage message];
}

-(BOOL) isActive{
	if (![self isConnected]) return false;
	
	// If ninety minutes has passed since a peer node has communicated any messages, then the client will assume that connection has closed.
	if (self.lastSeenTime >= [[NSDate date] timeIntervalSince1970] - (60 * 90)) return true;
	
	return false;
}

@end
