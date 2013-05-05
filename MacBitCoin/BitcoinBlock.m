//
//  BitcoinBlock.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/19/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinBlock.h"

#import "Definitions.h"
#import "NSData+Integer.h"
#import "NSData+CryptoHashing.h"
#import "BitcoinVarInt.h"
#import "NSString+StringToHexData.h"
#import "NSData+ReverseBytes.h"

@implementation BitcoinBlock

// Default constructors for when you want to make a block by hand
+(id)block{
	return [[BitcoinBlock alloc] init];
}

-(id)init{
	if (self = [super init]){
		_version = 1;
		_bits = 0x1d07fff8;
		_timestamp = [[NSDate date] timeIntervalSince1970];
		_prev_block = [NSMutableData dataWithLength:32];
		_txn_count = [BitcoinVarInt varintFromValue:0];
		_transactions = [NSMutableArray arrayWithCapacity:0];
		
		_blockHeight = 0;
	}
	
	return self;
}

+(id)genesisBlock{
	return [[BitcoinBlock alloc] initGenesisBlock];
}

-(id)initGenesisBlock{
	// TODO: Switch to normal network block
	if (self = [self init]){
		
		// https://en.bitcoin.it/wiki/Genesis_block
		_timestamp = 1296688602;
		_bits = 0x1D00FFFF;
		_nonce = 414098458;
		
		BitcoinTransaction *tx = [BitcoinTransaction transaction];
		
		BitcoinTxIn *txIn = [BitcoinTxIn txIn];
		NSData *script = [@"04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73" stringToHexData];
		[txIn scriptFromBytes:script];
		[tx addTxIn:txIn];
		
		BitcoinTxOut *txOut = [BitcoinTxOut txOut];
		txOut.value = 5000000000;
		
		// TODO: This should be a script object
		NSMutableData *pkScript = [NSMutableData dataWithCapacity:32];
		[pkScript appendData:[@"41" stringToHexData]]; // Length of script
		[pkScript appendData:[@"04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f" stringToHexData]];
		char op_checksig[] = { 0xac };
		[pkScript appendBytes:op_checksig length:1];
		[txOut scriptFromBytes:pkScript];
		[tx addTxOut:txOut];
		
		[self addTransaction:tx];
	}
	
	return self;
}

// Init a block with payload bytes
+(id) blockFromBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinBlock alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData *)data fromOffset:(int)offset{
	if (self = [super init]){
		
		_version = [data offsetToInt32:offset];
		
		offset += 4;
		_prev_block = [data subdataWithRange:NSMakeRange(offset, 32)];
		
		offset += 32;
		_merkle_root = [data subdataWithRange:NSMakeRange(offset, 32)];
		
		offset += 32;
		_timestamp = [data offsetToInt32:offset];
		
		offset += 4;
		_bits = [data offsetToInt32:offset];
		
		offset += 4;
		_nonce = [data offsetToInt32:offset];
		
		offset += 4;
		_txn_count = [BitcoinVarInt varintFromBytes:data fromOffset:offset];
		
		offset += [_txn_count size];
		_transactions = [NSMutableArray arrayWithCapacity:[_txn_count value]];
		for (int i=0; i<[_txn_count value]; i++){
			BitcoinTransaction *tx = [BitcoinTransaction transactionFromBytes:data fromOffset:offset];
			[_transactions addObject:tx];
			offset += [tx getLength];
		}
	}
	
	return self;
}

// Init a block *HEADER* with payload bytes
+(id) blockFromHeaderBytes:(NSData *)data fromOffset:(int)offset{
	return [[BitcoinBlock alloc] initFromHeaderBytes:data fromOffset:offset];
}

-(id)initFromHeaderBytes:(NSData *)data fromOffset:(int)offset{
	if (self = [super init]){
		
		_version = [data offsetToInt32:offset];
		
		offset += 4;
		_prev_block = [data subdataWithRange:NSMakeRange(offset, 32)];
		
		offset += 32;
		_merkle_root = [data subdataWithRange:NSMakeRange(offset, 32)];
		
		offset += 32;
		_timestamp = [data offsetToInt32:offset];
		
		offset += 4;
		_bits = [data offsetToInt32:offset];
		
		offset += 4;
		_nonce = [data offsetToInt32:offset];
		
		_txn_count = [BitcoinVarInt varintFromValue:0];
	}
	
	return self;
}

// Used for testing, mostly
-(void)setPrevBlock:(NSString*)prev_block{
	self.prev_block = [prev_block stringToHexData];
	self.hash = nil;
}

// Used for testing, mostly
-(void)setMerkleRoot:(NSString*)merkle_root{
	self.merkle_root = [merkle_root stringToHexData];
	self.hash = nil;
}

-(void)addTransaction:(BitcoinTransaction*)tx{
	[self.transactions addObject:tx];
	self.txn_count = [BitcoinVarInt varintFromValue:[self.transactions count]];
	self.hash = nil;
	self.merkle_root = nil;
}

// Encode our payload
-(NSData*) getData{
	NSMutableData *data = [NSMutableData dataWithCapacity:80];
	
	[data appendData:[NSData dataWithInt32:self.version]];
	
	[data appendData:self.prev_block];
	[data appendData:[self getMerkleRoot]];
	
	[data appendData:[NSData dataWithInt32:self.timestamp]];
	[data appendData:[NSData dataWithInt32:self.bits]];
	[data appendData:[NSData dataWithInt32:self.nonce]];
	
	[data appendData:[self.txn_count getData]];
	for (BitcoinTransaction	*tx in [self transactions]){
		[data appendData:[tx getData]];
	}
	
	return [NSData dataWithData:data];
}

// Encode our payload as a block *HEADER*
-(NSData*) getHeaderData{
	NSMutableData *data = [NSMutableData dataWithCapacity:80];
	
	[data appendData:[NSData dataWithInt32:self.version]];
	
	[data appendData:self.prev_block];
	[data appendData:[self getMerkleRoot]];
	
	[data appendData:[NSData dataWithInt32:self.timestamp]];
	[data appendData:[NSData dataWithInt32:self.bits]];
	[data appendData:[NSData dataWithInt32:self.nonce]];
	
	return [NSData dataWithData:data];
}

// Build a hash, unless we've built one already. Return it
-(NSData*) getHash{
	if (!self.hash){
		NSData *data = [self getHeaderData];
		self.hash = [[data sha256Hash] sha256Hash];
	}
	
	return self.hash;
}


// Get the merkle root -- building it if we don't have one
-(NSData*) getMerkleRoot{
	if (!self.merkle_root){
		// Build the merkle tree
		// Much of this ported from bitcoinj
		NSMutableArray *tree = [NSMutableArray arrayWithCapacity:self.txn_count.value];
		
        // Start by adding all the hashes of the transactions as leaves of the tree.
        for (BitcoinTransaction	*tx in [self transactions]){
			// Add their hashes to the tree
			[tree addObject:[tx getHash]];
        }
		
        uint64_t levelOffset = 0; // Offset in the list where the currently processed level starts.
        // Step through each level, stopping when we reach the root (levelSize == 1).
        for (uint64_t levelSize = [tree count]; levelSize > 1; levelSize = (levelSize + 1) / 2){
            // For each pair of nodes on that level:
            for (int left = 0; left < levelSize; left += 2) {
                // The right hand node can be the same as the left hand, in the case where we don't have enough
                // transactions.
                uint64_t right = MIN(left + 1, levelSize - 1);
                NSData *leftBytes = [tree objectAtIndex:levelOffset + left];
                NSData *rightBytes = [tree objectAtIndex:levelOffset + right];
				
				NSMutableData *digest = [NSMutableData dataWithCapacity:64];
				[digest appendData:[[leftBytes sha256Hash] sha256Hash]];
				[digest appendData:[[rightBytes sha256Hash] sha256Hash]];
				[tree addObject:digest];
            }
			
            // Move to the next level.
            levelOffset += levelSize;
        }
		
		// And now the last hash is the merkle root
		self.merkle_root = [tree lastObject];
	}
	
	return self.merkle_root;
}

@end
