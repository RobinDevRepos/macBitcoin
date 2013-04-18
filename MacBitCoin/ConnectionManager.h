//
//  ConnectionManager.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/17/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"
#import "BitcoinPeer.h"

#define TAG_FIXED_LENGTH_HEADER 0
#define TAG_RESPONSE_BODY 1

@interface ConnectionManager : NSObject

@property uint16_t listenPort;

// Peers list
@property NSMutableArray *peers;

// Outgoing
@property GCDAsyncSocket *asyncSocket;
@property dispatch_queue_t socketQueueOut;

// Incoming
@property GCDAsyncSocket *listenSocket;
@property dispatch_queue_t socketQueueIn;

+(id) connectionManager;
-(id) init;

-(void) addPeer:(BitcoinPeer*)peer;
-(BitcoinPeer*) findPeer:(GCDAsyncSocket*)sock;
-(void) removePeer:(BitcoinPeer*)peer;
-(void) removePeerSocket:(GCDAsyncSocket*)sock;

@end
