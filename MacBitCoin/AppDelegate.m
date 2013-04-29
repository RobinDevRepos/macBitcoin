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
	
	// And we also enable colors
	// Requires that you install: https://github.com/robbiehanson/XcodeColors
	[[DDTTYLogger sharedInstance] setColorsEnabled:YES];
	
	[[DDTTYLogger sharedInstance] setLogFormatter:formatter];
	
	DDLogInfo(@"%@", THIS_METHOD);
	
	// The connection manager starts listening for incoming connections and manages our peers list
	// Basically, it does everything. Once I start on the UI, I assume the UI will add listeners to
	// the connection manager in order to receive updates about peers and block chain and the like
	connectionManager = [ConnectionManager connectionManager];
}

@end