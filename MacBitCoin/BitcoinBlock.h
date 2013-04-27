//
//  BitcoinBlock.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/19/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BitcoinVarInt.h"
#import "BitcoinTransaction.h"

//
// A representation of a Bitcoin block. Doubles as the message serialization/deserialization handler
//

@interface BitcoinBlock : NSObject

@property uint32_t version;
@property NSData *prev_block;
@property NSData *merkle_root;
@property uint32_t timestamp;
@property uint32_t bits; // The calculated difficulty target being used for this block
@property uint32_t nonce;
@property BitcoinVarInt *txn_count;
@property NSMutableArray *transactions;

@property NSData *hash;

+(id)block;
-(id)init;

+(id)blockFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

+(id)blockFromHeaderBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromHeaderBytes:(NSData*)data fromOffset:(int)offset;

-(void)setPrevBlock:(NSString*)prev_block;
-(void)setMerkleRoot:(NSString*)merkle_root;

-(void)addTransaction:(BitcoinTransaction*)tx;

-(NSData*) getData;
-(NSData*) getHeaderData;

-(NSData*) getHash;
-(NSData*) getMerkleRoot;

@end
