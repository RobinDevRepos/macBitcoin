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
#import "BitcoinInventoryVector.h"
#import "BitcoinGetdataMessage.h"
#import "BitcoinGetblocksMessage.h"
#import "BitcoinBlock.h"
#import "BitcoinHeadersMessage.h"

#import "ConnectionManager.h"

#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_INFO;

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
		_isDownloadPeer = FALSE;
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
	
	DDLogVerbose(@"Sending header %d bytes:\n%@", header.length, headerData);
	[self.socket writeData:headerData withTimeout:-1.0 tag:0];
	
	if (payload){
		DDLogVerbose(@"Sending payload %d bytes:\n%@", (uint32_t)[payload length], payload);
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
		
		// Ask for blocks. Will only work if we are a download peer
		[self askForBlocks];
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
	else{
		DDLogInfo(@"Header read of type: %@", [self.header getCommandName]);
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
		self.blockHeight = [versionMessage start_height];
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

			// If they have blocks, add them as a download peer
			if (self.blockHeight > 0){
				[self.manager addDownloadPeer:self];
			}
		}
		else{
			DDLogInfo(@"Version %d is too low. Ignoring peer.", self.version);
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
		
		// Send 'getData' for these, if we don't have them
		// But, only if they're BITCOIN_INV_OBJ_TYPE_MSG_BLOCK
		// TODO: Handle other types
		NSMutableArray *toFetch = [NSMutableArray arrayWithCapacity:invMessage.count.value];
		for (BitcoinInventoryVector *invVector in [invMessage inventory]){
			if (invVector.type != BITCOIN_INV_OBJ_TYPE_MSG_BLOCK) continue;
			
			if (![self.manager hasBlockHash:[invVector hash]]){
				[toFetch addObject:invVector];
			}
		}
		
		NSUInteger blocksToFetch = [toFetch count];
		if ([toFetch count] > 0){
			self.blocksToDownload += blocksToFetch;
			
			BitcoinGetdataMessage *getDataMessage = [BitcoinGetdataMessage message];
			getDataMessage.inventory = toFetch; // TODO: There should be one method on BitcoinGetdataMessage that takes an array and sets count
			getDataMessage.count = [BitcoinVarInt varintFromValue:blocksToFetch];
			DDLogInfo(@"Sending getdata in response to inv for %ld blocks", blocksToFetch);
			[self send:[getDataMessage getData] withMessageType:BITCOIN_MESSAGE_TYPE_GETDATA];
		}
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_GETDATA){
		BitcoinGetdataMessage *getDataMessage = [BitcoinGetdataMessage messageFromBytes:data fromOffset:0];
		DDLogInfo(@"Got getdata message: %lld", getDataMessage.count.value);
		
		// TODO: Send these blocks back if we have them and 'notfound' for the ones we don't
		// Do we send tx or block or both depending on the type?
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_GETBLOCKS){
		BitcoinGetblocksMessage *getBlocksMessage = [BitcoinGetblocksMessage messageFromBytes:data fromOffset:0];
		DDLogInfo(@"Got getblocks message: %lld", getBlocksMessage.count.value);
		
		// TODO: Return an inv containing the list of blocks starting right after the last known hash in the block locator object, up to hash_stop or 500 blocks, whichever comes first
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_GETHEADERS){
		BitcoinGetblocksMessage *getHeadersMessage = [BitcoinGetblocksMessage messageFromBytes:data fromOffset:0];
		DDLogInfo(@"Got getheaders message: %lld", getHeadersMessage.count.value);
		
		// TODO: Send BitcoinHeadersMessage back for the ones we have
		BitcoinHeadersMessage *headersMessage = [BitcoinHeadersMessage message];
		DDLogInfo(@"Sending headers");
		[self send:[headersMessage getData] withMessageType:BITCOIN_MESSAGE_TYPE_HEADERS];
		
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_BLOCK){
		BitcoinBlock *block = [BitcoinBlock blockFromBytes:data fromOffset:0];
		DDLogInfo(@"Got block: %@", [block getHash]);
		
		// TODO: Always decrement this? Is it possible to receive this unasked from a peer? Does that really matter?
		self.blocksToDownload--;
		
		// If we have it, ignore it. If we don't, add it and relay it if found valid
		if ([self.manager hasBlockHash:[block getHash]]) return;
		
		// TODO: Validate this: https://en.bitcoin.it/wiki/Protocol_specification#block
		[self.manager addBlock:block];
		
		// Ask for more, maybe from another, better, more handsome peer
		if (self.blocksToDownload == 0){
			self.isDownloadPeer = false;
			[self.manager startDownloadPeer];
		}
		else{
			DDLogInfo(@"Still waiting for %ld blocks", (unsigned long)self.blocksToDownload);
		}
	}
	else if (self.header.messageType == BITCOIN_MESSAGE_TYPE_HEADERS){
		BitcoinHeadersMessage *headersMessage = [BitcoinHeadersMessage messageFromBytes:data fromOffset:0];
		DDLogInfo(@"Got block headers: %ld", [headersMessage countHeaders]);
		
		// Add the ones we don't have
		for (BitcoinBlock *header in [headersMessage headers]){
			[self.manager addBlockHeader:header];
		}
		
		// Ask for more, maybe from another, better, more handsome peer
		if (self.blocksToDownload == 0){
			self.isDownloadPeer = false;
			[self.manager startDownloadPeer];
		}
		else{
			DDLogInfo(@"Still waiting for %ld headers", (unsigned long)self.blocksToDownload);
		}
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

-(void) askForBlocks{
	if (![self isDownloadPeer]) return;
	
	if (self.blockHeight > [self.manager getBlockHeight]){
		DDLogInfo(@"Asking for headers: our blocks=%ld, peer blocks=%d", (unsigned long)[self.manager getBlockHeight], self.blockHeight);
		// Ask for headers.
		BitcoinGetblocksMessage *getBlocksMessage = [BitcoinGetblocksMessage message];
		NSArray *hashes = [self.manager getBlockLocatorHashes];
		for (NSData *hash in hashes){
			[getBlocksMessage pushDataHash:hash];
		}
		
		DDLogInfo(@"Sending getheaders: %ld", (unsigned long)[hashes count]);
		[self send:[getBlocksMessage getData] withMessageType:BITCOIN_MESSAGE_TYPE_GETHEADERS];
		
		//DDLogInfo(@"Sending getblocks");
		//[self send:[getBlocksMessage getData] withMessageType:BITCOIN_MESSAGE_TYPE_GETBLOCKS];
	}
	else{
		// TODO: We are a/the download peer, but there was nothing to request. We should tell the manager.
	}
}

@end
