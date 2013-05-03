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
#import "BitcoinBlock.h"
#import "BitcoinBlockChain.h"

@interface ConnectionManager : NSObject

@property uint16_t listenPort;
@property (nonatomic) BitcoinVersionMessage *ourVersion;

// Peers list
@property NSMutableArray *peers;
@property NSMutableArray *downloadPeers;

// Outgoing
@property GCDAsyncSocket *asyncSocket;
@property dispatch_queue_t socketQueueOut;

// Incoming
@property GCDAsyncSocket *listenSocket;
@property dispatch_queue_t socketQueueIn;

// Block Chain
@property BitcoinBlockChain *blockChain;

+(id) connectionManager;
-(id) init;

-(BitcoinVersionMessage*)ourVersion;

// Peer management
-(void) addPeer:(BitcoinPeer*)peer;
-(BitcoinPeer*) findPeer:(BitcoinPeer*)peer;
-(BitcoinPeer*) findPeerSocket:(GCDAsyncSocket*)sock;
-(void) removePeer:(BitcoinPeer*)peer;
-(void) removePeerSocket:(GCDAsyncSocket*)sock;

-(NSArray*) getActivePeers;
-(NSUInteger) countOfPeers;
-(void) connectToPeers;

// Download peer management
-(void) addDownloadPeer:(BitcoinPeer*)peer;
-(BitcoinPeer*) getDownloadPeer;
-(void) removeDownloadPeer:(BitcoinPeer*)peer;
-(void) startDownloadPeer;

// Block chain management
-(BOOL) hasBlockHash:(NSData*)hash;
-(void) addBlock:(BitcoinBlock*)block;
-(void) addBlockHeader:(BitcoinBlock*)block;
-(BitcoinBlock*) getBlockByHash:(NSData*)hash;
-(BitcoinBlock*) getChainHead;
-(NSUInteger) getBlockHeight;
-(void) setBlockHeight:(NSUInteger)height;
-(NSArray*) getBlockLocatorHashes;

@end
