//
//  BitcoinBlockChain.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/27/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BitcoinBlock.h"

@interface BitcoinBlockChain : NSObject

@property BitcoinBlock *chainHead;
@property NSMutableDictionary *orphanBlocks;
@property NSMutableDictionary *blocks;
@property (weak) id manager;
@property NSUInteger targetHeight;

+(id)blockChain;
-(id)init;

-(BOOL)hasBlockHash:(NSData*)hash;
-(void)addBlock:(BitcoinBlock*)block;
-(void)addBlockHeader:(BitcoinBlock*)block;
-(BitcoinBlock*) getBlockByHash:(NSData*)hash;

-(NSUInteger) getBlockHeight;

-(BOOL) isBootstrapping;

@end
