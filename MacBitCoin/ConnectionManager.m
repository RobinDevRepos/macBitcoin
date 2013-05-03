//
//  ConnectionManager.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/17/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "ConnectionManager.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_INFO;

#import "Definitions.h"

@implementation ConnectionManager

+(id) connectionManager{
	return [[self alloc] init];
}

-(id) init{
	if (self = [super init]){
		_peers = [NSMutableArray arrayWithCapacity:10];
		_downloadPeers = [NSMutableArray arrayWithCapacity:1];
		
		_blockChain = [BitcoinBlockChain blockChain];
		[_blockChain setManager:self];
		
		_ourVersion = [BitcoinVersionMessage message];
		_ourVersion.addr_from = [BitcoinAddress addressFromAddress:@"::ffff:0.0.0.0" withPort:0];		
		// TODO: Once we get an external ip, update this and push to our peers (http://whatismyip.akamai.com/)
		// TODO: Store ourselves as peer, so we can track peer-related data on ourselves?
		_ourVersion.start_height = [_blockChain getBlockHeight];
		
		// Setup our sockets (GCDAsyncSocket).
		// The socket will invoke our delegate methods using the usual delegate paradigm.
		// However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
		//
		// Now we can configure the delegate dispatch queue however we want.
		// We could use a dedicated dispatch queue for easy parallelization.
		// Or we could simply use the dispatch queue for the main thread.
		//
		// The best approach for your application will depend upon convenience, requirements and performance.
		
		_socketQueueIn = dispatch_queue_create("socketQueueIn", NULL);
		
		// Start listening for incoming requests
		_listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueueIn];
		
		_listenPort = LISTEN_PORT;
		DDLogInfo(@"Starting to listen on port %hu...", _listenPort);
		
		NSError *error = nil;
		if(![_listenSocket acceptOnPort:_listenPort error:&error])
		{
			DDLogError(@"Error listening: %@", error);
		}
		
		
		// Outgoing socket queue
		_socketQueueOut = dispatch_queue_create("socketQueueOut", NULL);
		
		[self connectToPeers];
	}
	
	return self;
}

-(BitcoinVersionMessage*)ourVersion{
	_ourVersion.start_height = [self.blockChain getBlockHeight];
	return _ourVersion;
}

-(void) addPeer:(BitcoinPeer *)peer {
	if ([self findPeer:peer]){
		DDLogInfo(@"Ignoring existing peer: %@ port:%hu", peer.address.address, peer.address.port);
		return;
	}
	
	if (![peer isConnected]){
		if (!peer.socket){
			GCDAsyncSocket *sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueueOut];
			[peer connect:sock];
		}
		else{
			[peer connect];
		}
	}
	
	[peer setManager:self];
	
	DDLogInfo(@"Adding peer: %@ port:%hu", peer.address.address, peer.address.port);
	@synchronized([self peers]){
		[[self peers] addObject:peer];
	}
}

-(BitcoinPeer*) findPeer:(BitcoinPeer*)peer{
	@synchronized([self peers]){
		for (BitcoinPeer *existingPeer in [self peers]){
			if ([existingPeer isEqualTo:peer]) return existingPeer;
		}
	}
	
	return nil;
}

-(BitcoinPeer*) findPeerSocket:(GCDAsyncSocket*)sock{
	@synchronized([self peers]){
		for (BitcoinPeer *peer in [self peers]){
			if (peer.socket == sock) return peer;
		}
	}
	
	return nil;
}

-(void) removePeer:(BitcoinPeer*)peer{
	
	DDLogInfo(@"Removing peer: %@ port:%hu", peer.address.address, peer.address.port);
	@synchronized([self peers]){
		[[self peers] removeObject:peer];
	}
	
	DDLogInfo(@"New peer count: %lld", (uint64_t)[self countOfPeers]);
	
	if ([self countOfPeers] < MIN_ACTIVE_PEERS){
		[self connectToPeers];
		
		// TODO: We'll need to check again after some reasonably short timeout, in case all of these fail, like if we're offline
		// Or is there some signal we can catch for network up/down to be even smarter still?
	}
}

-(void) removePeerSocket:(GCDAsyncSocket*)sock{
	BitcoinPeer *peer = [self findPeerSocket:sock];
	if (peer){
		[self removePeer:peer];
	}
	else{
		DDLogWarn(@"Attempt to remove unknown");
	}
}

-(NSArray*) getActivePeers{
	NSMutableArray *activePeers = [NSMutableArray arrayWithCapacity:[self.peers count]];
	@synchronized([self peers]){
		for (BitcoinPeer *peer in [self peers]){
			if ([peer isActive]) [activePeers addObject:peer];
		}
	}
	return activePeers;
}

-(NSUInteger) countOfPeers{
	return [[self getActivePeers] count];
}

-(void) connectToPeers{
	// Seed our peers list
	// TODO: This should come from a DNS lookup
	NSArray *seedHosts = [NSArray arrayWithObjects:
		@"127.0.0.1",
		@"213.5.71.38",
		@"173.236.193.117",
		@"131.188.138.23",
		@"192.81.222.207",
		@"54.243.45.209",
		@"78.46.18.137",
		@"23.21.243.183",
		@"178.63.48.141",
		@"24.12.138.16",
		@"62.213.207.209",
		@"173.230.150.38",
		@"164.177.157.148",
		@"94.23.47.168",
		@"46.4.24.198",
		@"5.9.2.145",
		@"94.23.1.23",
		@"91.121.137.219",
		@"199.26.85.40",
		@"108.61.77.74",
		@"152.2.31.233",
		nil];
	
	for (NSString *host in seedHosts){
		BitcoinPeer *seedPeer = [BitcoinPeer peerFromAddress:host withPort:CONNECT_PORT];
		//[seedPeer setIsDownloadPeer:TRUE];
		[self addPeer:seedPeer];
		
		if ([self countOfPeers] >= MAX_ACTIVE_PEERS) break;
	}
	
	// TODO: Schedule task to prune our list when we haven't heard from them in 90 minutes
	// TODO: Schedule task to send pings in 30 minutes, if we haven't sent anything else
	// TODO: Serialize peer list to disk and load it on startup, using the seed list if we don't have any or all our saved peers are unreachable
}

// Download peer management
-(void) addDownloadPeer:(BitcoinPeer*)peer{
	BitcoinPeer *downloadPeer = [self getDownloadPeer];
	
	DDLogInfo(@"Adding download peer: %@", peer.address.address);
	@synchronized([self downloadPeers]){
		[[self downloadPeers] addObject:peer];
	}
	
	// Start downloading, but only if there's no existing peer. When this peer finishes, we'll pick a (potentially) better peer
	if (!downloadPeer){
		peer.isDownloadPeer = TRUE;
		[peer askForBlocks];
	}
}

-(BitcoinPeer*) getDownloadPeer{
	@synchronized([self downloadPeers]){
		for (BitcoinPeer *peer in [self downloadPeers]){
			if (peer.isDownloadPeer) return peer;
		}
	}
	
	return nil;
}

-(void) removeDownloadPeer:(BitcoinPeer*)peer{
	DDLogInfo(@"Removing download peer: %@ ", peer.address.address);
	peer.isDownloadPeer = false;
	
	@synchronized([self downloadPeers]){
		[[self downloadPeers] removeObject:peer];
	}
}

-(void) startDownloadPeer{
	BitcoinPeer *bestDownloadPeer = nil;
	@synchronized([self downloadPeers]){
		for (BitcoinPeer *peer in [self downloadPeers]){
			// TODO: Other factors like ping time?
			if ([peer blockHeight] == 0) continue;
			
			if (bestDownloadPeer == nil || ([bestDownloadPeer blockHeight] < [peer blockHeight])){
				bestDownloadPeer = peer;
			}
		}
	}
	
	if (bestDownloadPeer){
		if ([bestDownloadPeer blockHeight] > [self getBlockHeight]){
			DDLogInfo(@"Setting new download peer: %@", bestDownloadPeer.address.address);
			bestDownloadPeer.isDownloadPeer = TRUE;
			[bestDownloadPeer askForBlocks];
		}
		else{
			DDLogInfo(@"Do not need to download more blocks. Skipping download peer");
		}
	}
	else{
		DDLogWarn(@"Could not find new download peer");
	}
}

// Block chain methods just pass responsibility onto the chain
-(BOOL) hasBlockHash:(NSData*)hash{
	return [self.blockChain hasBlockHash:hash];
}

-(void) addBlock:(BitcoinBlock*)block{
	[self.blockChain addBlock:block];
}

-(void) addBlockHeader:(BitcoinBlock*)block{
	[self.blockChain addBlockHeader:block];
}

-(BitcoinBlock*) getBlockByHash:(NSData*)hash{
	return [self.blockChain getBlockByHash:hash];
}

-(BitcoinBlock*) getChainHead{
	return [self.blockChain chainHead];
}

-(NSUInteger) getBlockHeight{
	return [self.blockChain getBlockHeight];
}

-(void) setBlockHeight:(NSUInteger)height{
	self.ourVersion.start_height = height;
}

-(NSArray*) getBlockLocatorHashes{
	NSMutableArray *hashes = [NSMutableArray arrayWithCapacity:51];
	
	// Walk back up to 50 blocks and push hashes
	BitcoinBlock *block = [self getChainHead];
	for (int i = 50; block != nil && i > 0; i--) {
		[hashes addObject:[block getHash]];
		block = [self getBlockByHash:[block prev_block]];
	}
	
	// If we haven't added the genesis block yet, we need to add it
	if (block != nil){
		[hashes addObject:[[BitcoinBlock genesisBlock] getHash]];
	}
	
	return [NSArray arrayWithArray:hashes];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Socket Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	DDLogVerbose(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
	
	//	DDLogInfo(@"localHost :%@ port:%hu", [sock localHost], [sock localPort]);
		
	BitcoinPeer *peer = [self findPeerSocket:sock];
	if (peer){
		// Update their address now that we have a socket
		[peer updateAddressFromSocket:sock];		
		
		// Start reading
		[sock readDataToLength:24 withTimeout:READ_TIMEOUT tag:TAG_FIXED_LENGTH_HEADER];

		// Push version
		[peer pushVersion];
		
		DDLogInfo(@"New peer count: %lld", (uint64_t)[self countOfPeers]);
	}
	else{
		DDLogWarn(@"socket:%p on host:%@ port:%hu is an unknown peer", sock, host, port);
	}
}

/*- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
	DDLogVerbose(@"socketDidSecure:%p", sock);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	DDLogVerbose(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}*/

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	DDLogVerbose(@"socket:%p didReadData:withTag:%ld", sock, tag);
	DDLogVerbose(@"Full response: %@", data);
	
	BitcoinPeer *peer = [self findPeerSocket:sock];
	if (tag == TAG_FIXED_LENGTH_HEADER){
		uint32_t length = [peer receiveHeader:data];
		
		if (length){
			DDLogVerbose(@"Header read. Waiting for body: %d", length);
			[sock readDataToLength:length withTimeout:-1 tag:TAG_RESPONSE_BODY];
		}
		else{
			DDLogVerbose(@"Header read. Length is zero. Re-waiting for header.");
			[sock readDataToLength:24 withTimeout:-1 tag:TAG_FIXED_LENGTH_HEADER];
		}
	}
	else if (tag == TAG_RESPONSE_BODY){
		[peer receivePayload:data];
		[sock readDataToLength:24 withTimeout:-1 tag:TAG_FIXED_LENGTH_HEADER];
	}
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength withTag:(long)tag
{
	DDLogVerbose(@"socket:%p didReadPartialDataOfLength:%ld:%ld", sock, (long)partialLength, tag);
}

/*- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
 elapsed:(NSTimeInterval)elapsed
 bytesDone:(NSUInteger)length
 {
 
 DDLogInfo(@"socket:%p shouldTimeoutReadWithTag:%ld:%f:%ld", sock, tag, elapsed, length);
 
 return 0.0;
 }*/

/*- (void)socket:(GCDAsyncSocket *)sock didWriteWithTag:(long)tag
{
	DDLogInfo(@"socket:%p didWriteWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength withTag:(long)tag
{
	DDLogInfo(@"socket:%p didWritePartialDataOfLength:%ld:%ld", sock, (long)partialLength, tag);
}*/

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	DDLogWarn(@"socketDidDisconnect:%p withError: %@", sock, err);
	
	[self removePeerSocket:sock];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	DDLogVerbose(@"didAcceptNewSocket:%p", sock);
	
	NSString *host = [newSocket connectedHost];
	UInt16 port = [newSocket connectedPort];
	
	DDLogInfo(@"Accepted client %@:%hu", host, port);
	
	BitcoinPeer *seedPeer = [BitcoinPeer peerFromAddress:host withPort:port];
	seedPeer.socket = newSocket;
	[seedPeer updateAddressFromSocket:newSocket];
	[self addPeer:seedPeer];
	
	[newSocket readDataToLength:24 withTimeout:READ_TIMEOUT tag:TAG_FIXED_LENGTH_HEADER];
}

@end
