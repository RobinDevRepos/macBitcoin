//
//  AppDelegate.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/7/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCDAsyncSocket;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private
	dispatch_queue_t socketQueue;
	
	// Outgoing
	GCDAsyncSocket *asyncSocket;
	
	// Incoming
	GCDAsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;
}

@property (assign) IBOutlet NSWindow *window;

@end

typedef struct {
	uint32_t magic;
	const char *command;
	uint32_t length;
	uint32_t checksum;
	const char *payload;
} header;

typedef struct {
	int32_t version;
	uint64_t services;
	int64_t timestamp;
	const char *addr_recv;
	const char *addr_from;
	uint64_t nonce;
	uint8_t user_agent_length;
	const char * user_agent;
	int32_t start_height;
	bool relay;
	
} version;