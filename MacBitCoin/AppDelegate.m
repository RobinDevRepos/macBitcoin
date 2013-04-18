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

#import "BitcoinPeer.h"

#import <CommonCrypto/CommonDigest.h>
#import <Security/SecRandom.h>

// Log levels: off, error, warn, info, verbose
#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

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
	
	// The connection manager starts listening for incoming connections and manages our peers list
	connectionManager = [ConnectionManager connectionManager];
}

@end