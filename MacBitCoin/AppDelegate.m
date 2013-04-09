//
//  AppDelegate.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/7/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncSocket.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DispatchQueueLogFormatter.h"

#define CONNECT_TIMEOUT 1.0
#define READ_TIMEOUT 5.0
#define PROTOCOL_VERSION 70001

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Setup logging framework
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Format our logging
	DispatchQueueLogFormatter *formatter = [[DispatchQueueLogFormatter alloc] init];
	[formatter setReplacementString:@"socket" forQueueLabel:GCDAsyncSocketQueueName];
	[formatter setReplacementString:@"socket-cf" forQueueLabel:GCDAsyncSocketThreadName];
	
	[[DDTTYLogger sharedInstance] setLogFormatter:formatter];
	
	DDLogInfo(@"%@", THIS_METHOD);
	
	// Setup our sockets (GCDAsyncSocket).
	// The socket will invoke our delegate methods using the usual delegate paradigm.
	// However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
	//
	// Now we can configure the delegate dispatch queue however we want.
	// We could use a dedicated dispatch queue for easy parallelization.
	// Or we could simply use the dispatch queue for the main thread.
	//
	// The best approach for your application will depend upon convenience, requirements and performance.
	
	socketQueue = dispatch_queue_create("socketQueue", NULL);
	

	// Start listening for incoming requests
	listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
	
	// Setup an array to store all accepted client connections
	connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
	
	uint16_t listenPort = 18333; // Real port is 8333
	
	DDLogInfo(@"Starting to listen on port %hu...", listenPort);
	
	NSError *error = nil;
	if(![listenSocket acceptOnPort:listenPort error:&error])
	{
		DDLogError(@"Error listening: %@", error);
		return;
	}

	
	// Outgoing socket
	asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
	
	
	
	// Now we tell the ASYNCHRONOUS socket to connect.
	//
	// Recall that GCDAsyncSocket is ... asynchronous.
	// This means when you tell the socket to connect, it will do so ... asynchronously.
	// After all, do you want your main thread to block on a slow network connection?
	//
	// So what's with the BOOL return value, and error pointer?
	// These are for early detection of obvious problems, such as:
	//
	// - The socket is already connected.
	// - You passed in an invalid parameter.
	// - The socket isn't configured properly.
	//
	// The error message might be something like "Attempting to connect without a delegate. Set a delegate first."
	//
	// When the asynchronous sockets connects, it will invoke the socket:didConnectToHost:port: delegate method.
	
	// http://testnet.mojocoin.com/about
	NSString *host = @"199.26.85.40";
	uint16_t port = 18333;
		
	DDLogInfo(@"Connecting to \"%@\" on port %hu...", host, port);
		
	error = nil;
	if (![asyncSocket connectToHost:host onPort:port withTimeout:CONNECT_TIMEOUT error:&error])
	{
		DDLogError(@"Error connecting: %@", error);
	}
		
	// You can also specify an optional connect timeout.
	
	//	NSError *error = nil;
	//	if (![asyncSocket connectToHost:host onPort:80 withTimeout:5.0 error:&error])
	//	{
	//		DDLogError(@"Error connecting: %@", error);
	//	}
	
	// The connect method above is asynchronous.
	// At this point, the connection has been initiated, but hasn't completed.
	// When the connection is establish, our socket:didConnectToHost:port: delegate method will be invoked.
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Socket Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	DDLogInfo(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
	
	//	DDLogInfo(@"localHost :%@ port:%hu", [sock localHost], [sock localPort]);
	
	// Start reading
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
	
	// Send version: https://en.bitcoin.it/wiki/Protocol_specification#version
	DDLogInfo(@"sending version: version %d, blocks=%d, us=%@, them=%@, peer=%@", PROTOCOL_VERSION, -1, sock.localHost, sock.connectedHost, sock.connectedHost);
	
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
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
				 elapsed:(NSTimeInterval)elapsed
			   bytesDone:(NSUInteger)length
{
	
	DDLogInfo(@"socket:%p shouldTimeoutReadWithTag:%ld:%f:%ld", sock, tag, elapsed, length);
	
	return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	DDLogInfo(@"socketDidDisconnect:%p withError: %@", sock, err);
	
	if (sock != listenSocket)
	{
		DDLogInfo(@"Client Disconnected");		
		@synchronized(connectedSockets)
		{
			[connectedSockets removeObject:sock];
		}
	}
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	DDLogInfo(@"didAcceptNewSocket:%p", sock);
	
	@synchronized(connectedSockets)
	{
		[connectedSockets addObject:newSocket];
	}
	
	NSString *host = [newSocket connectedHost];
	UInt16 port = [newSocket connectedPort];
	
	DDLogInfo(@"Accepted client %@:%hu", host, port);
	
	[newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
}

@end
