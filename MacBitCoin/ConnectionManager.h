//
//  ConnectionManager.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/17/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"

#import "Definitions.h"
#import "BitcoinPeer.h"
#import "BitcoinVersionMessage.h"

@interface ConnectionManager : NSObject

@property uint16_t listenPort;
@property BitcoinVersionMessage *ourVersion;

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
-(BitcoinPeer*) findPeer:(BitcoinPeer*)peer;
-(BitcoinPeer*) findPeerSocket:(GCDAsyncSocket*)sock;
-(void) removePeer:(BitcoinPeer*)peer;
-(void) removePeerSocket:(GCDAsyncSocket*)sock;

-(NSArray*) getActivePeers;
-(NSUInteger) countOfPeers;

@end
