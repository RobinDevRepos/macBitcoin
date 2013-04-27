//
//  BitcoinTransaction.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/24/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BitcoinVarInt.h"

@class BitcoinTxIn;
@class BitcoinTxOut;

@interface BitcoinTransaction : NSObject

@property uint32_t version;
@property BitcoinVarInt *tx_in_count;
@property NSMutableArray *tx_in;
@property BitcoinVarInt *tx_out_count;
@property NSMutableArray *tx_out;
@property uint32_t lock_time;

@property NSUInteger length;
@property NSData *hash;

+(id)transaction;
-(id)init;

+(id)transactionFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(void)addTxIn:(BitcoinTxIn*)txIn;
-(void)addTxOut:(BitcoinTxOut*)txOut;

-(NSData*) getData;

-(NSData*) getHash;
-(NSUInteger) getLength;

@end

@interface BitcoinOutPoint : NSObject

@property NSData *hash;
@property uint32_t index;

+(id)outPoint;
-(id)init;

+(id)outPointFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(NSData*) getData;

@end

@interface BitcoinTxIn : NSObject

@property BitcoinOutPoint *previous_output;
@property BitcoinVarInt *script_length;
@property NSData *computational_script;
@property uint32_t sequence; // http://bitcoin.stackexchange.com/questions/2025/what-is-txins-sequence

+(id)txIn;
-(id)init;

+(id)txInFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(NSData*) getData;

@end

@interface BitcoinTxOut : NSObject

@property uint64_t value;
@property BitcoinVarInt *pk_script_length;
@property NSData *pk_script;

+(id)txOut;
-(id)init;

+(id)txOutFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(NSData*) getData;

@end