//
//  BitcoinPeer.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/17/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"
#import "BitcoinAddress.h"
#import "BitcoinMessageHeader.h"
#import "BitcoinVersionMessage.h"

@interface BitcoinPeer : NSObject

@property BitcoinAddress *address;
@property GCDAsyncSocket *socket;
@property (nonatomic) int32_t version;
@property (nonatomic) uint32_t blockHeight;
@property (nonatomic) uint32_t lastSeenTime;
@property BitcoinMessageHeader *header;
@property (weak) id manager;

@property (nonatomic) BOOL versionPushed;
@property (nonatomic) BOOL versionAcked;

@property (nonatomic) BOOL isDownloadPeer;
@property (nonatomic) NSUInteger blocksToDownload;

+(id) peerFromBitcoinAddress:(BitcoinAddress*)address;
-(id) initFromBitcoinAddress:(BitcoinAddress*)address;

+(id) peerFromAddress:(NSString*)address withPort:(UInt16)port;
-(id) initFromAddress:(NSString*)address withPort:(UInt16)port;

-(void) updateAddressFromSocket:(GCDAsyncSocket*)socket;

-(void) connect;
-(void) connect:(GCDAsyncSocket*)socket;
-(void) disconnect;

-(void) send:(NSData*)payload withMessageType:(BitcoinMessageType)type;
-(uint32_t) receiveHeader:(NSData*)data;
-(void) receivePayload:(NSData*)data;
-(BOOL) isConnected;

-(void) pushVersion;

-(BitcoinVersionMessage*) getOurVersion;

-(BOOL) isActive;
-(void) sendPing;

-(void) askForBlocks;

@end
