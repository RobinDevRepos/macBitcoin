//
//  ConnectionManager.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/17/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "ConnectionManager.h"
#import "DDLog.h"

#define READ_TIMEOUT 5.0

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation ConnectionManager

+(id) connectionManager{
	return [[self alloc] init];
}

-(id) init{
	if (self = [super init]){
		_peers = [NSMutableArray arrayWithCapacity:10];
		
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
		
		_listenPort = 18333; // Real port is 8333
		DDLogInfo(@"Starting to listen on port %hu...", _listenPort);
		
		NSError *error = nil;
		if(![_listenSocket acceptOnPort:_listenPort error:&error])
		{
			DDLogError(@"Error listening: %@", error);
		}
		
		
		// Outgoing socket queue
		_socketQueueOut = dispatch_queue_create("socketQueueOut", NULL);
		
		// Seed our peers list
		NSArray *seedHosts;
		if (TRUE){
			// TODO: Do this with a DNS lookup
			seedHosts = [NSArray arrayWithObjects:
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
		}
		else{
			seedHosts = [NSArray arrayWithObject:@"localhost"];
		}
		
		for (NSString *host in seedHosts){
			BitcoinPeer *seedPeer = [BitcoinPeer peerFromAddress:host withPort:18333]; // Real port is 8333
			[self addPeer:seedPeer];
		}
	}
	
	return self;
}

-(void) addPeer:(BitcoinPeer *)peer {
	if (![peer isConnected]){
		GCDAsyncSocket *sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueueOut];
		[peer connect:sock];
	}
	// TODO: Make sure we don't already exist
	
	@synchronized([self peers]){
		[[self peers] addObject:peer];
	}
}

-(BitcoinPeer*) findPeer:(GCDAsyncSocket*)sock{
	for (BitcoinPeer *peer in [self peers]){
		if (peer.socket == sock) return peer;
	}
	
	return nil;
}

-(void) removePeer:(BitcoinPeer*)peer{
	
	@synchronized([self peers]){
		[[self peers] removeObject:peer];
	}
}

-(void) removePeerSocket:(GCDAsyncSocket*)sock{
	BitcoinPeer *peer = [self findPeer:sock];
	if (peer) [self removePeer:peer];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Socket Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	DDLogInfo(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
	
	//	DDLogInfo(@"localHost :%@ port:%hu", [sock localHost], [sock localPort]);
	
	// Start reading
	[sock readDataToLength:24 withTimeout:READ_TIMEOUT tag:TAG_FIXED_LENGTH_HEADER];
	
	BitcoinPeer *peer = [self findPeer:sock];
	[peer pushVersion];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
	DDLogInfo(@"socketDidSecure:%p", sock);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	DDLogInfo(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	DDLogInfo(@"socket:%p didReadData:withTag:%ld", sock, tag);
	DDLogInfo(@"Full response: %@", data);
	
	BitcoinPeer *peer = [self findPeer:sock];
	if (tag == TAG_FIXED_LENGTH_HEADER){
		uint32_t length = [peer receiveHeader:data];
		
		DDLogInfo(@"Header read. Waiting for body: %d", length);
		[sock readDataToLength:length withTimeout:-1 tag:TAG_RESPONSE_BODY]; // TODO
	}
	else if (tag == TAG_RESPONSE_BODY){
		[peer receivePayload:data];
		[sock readDataToLength:24 withTimeout:-1 tag:TAG_FIXED_LENGTH_HEADER];
	}
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength withTag:(long)tag
{
	DDLogInfo(@"socket:%p didReadPartialDataOfLength:%ld:%ld", sock, (long)partialLength, tag);
}

/*- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
 elapsed:(NSTimeInterval)elapsed
 bytesDone:(NSUInteger)length
 {
 
 DDLogInfo(@"socket:%p shouldTimeoutReadWithTag:%ld:%f:%ld", sock, tag, elapsed, length);
 
 return 0.0;
 }*/

- (void)socket:(GCDAsyncSocket *)sock didWriteWithTag:(long)tag
{
	DDLogInfo(@"socket:%p didWriteWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength withTag:(long)tag
{
	DDLogInfo(@"socket:%p didWritePartialDataOfLength:%ld:%ld", sock, (long)partialLength, tag);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	DDLogInfo(@"socketDidDisconnect:%p withError: %@", sock, err);
	
	BitcoinPeer *peer = [self findPeer:sock];
	if (peer) [self removePeer:peer];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	DDLogInfo(@"didAcceptNewSocket:%p", sock);
	
	NSString *host = [newSocket connectedHost];
	UInt16 port = [newSocket connectedPort];
	
	DDLogInfo(@"Accepted client %@:%hu", host, port);
	
	BitcoinPeer *seedPeer = [BitcoinPeer peerFromAddress:host withPort:port];
	seedPeer.socket = newSocket;
	[self addPeer:seedPeer];
	
	[newSocket readDataToLength:24 withTimeout:READ_TIMEOUT tag:TAG_FIXED_LENGTH_HEADER];
}

@end
