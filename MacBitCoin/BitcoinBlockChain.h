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

+(id)blockChain;
-(id)init;

-(void)addBlock:(BitcoinBlock*)block;

@end
