//
//  AppDelegate.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/7/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define COMMAND_LENGTH 12
#define ADDRESS_LENGTH 16
#define PROTOCOL_VERSION 70001
#define NODE_NETWORK 1

@class GCDAsyncSocket;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private
	// Outgoing
	GCDAsyncSocket *asyncSocket;
	dispatch_queue_t socketQueueOut;
	
	// Incoming
	GCDAsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;
	dispatch_queue_t socketQueueIn;
}

@property (assign) IBOutlet NSWindow *window;

@end

typedef struct {
	uint32_t magic;
	char command[COMMAND_LENGTH];
	uint32_t length;
	uint32_t checksum;
} header;

typedef struct {
	unsigned int time;
	uint64_t services;
	char ip[ADDRESS_LENGTH];
	unsigned short port;
} address;

typedef struct {
	int32_t version;
	uint64_t services;
	int64_t timestamp;
	address addr_recv;
	address addr_from;
	uint64_t nonce;
	uint8_t user_agent_length;
	char *user_agent;
	int32_t start_height;
	bool relay;	
} version;