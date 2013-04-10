//
//  AppDelegate.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/7/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define COMMAND_LENGTH 12

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
	int32_t version;
	uint64_t services;
	int64_t timestamp;
	const char* addr_recv;
	const char* addr_from;
	uint64_t nonce;
	uint8_t user_agent_length;
	char user_agent[15];
	int32_t start_height;
	bool relay;	
} version;