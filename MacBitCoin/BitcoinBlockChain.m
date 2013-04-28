//
//  BitcoinBlockChain.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/27/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinBlockChain.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation BitcoinBlockChain

+(id) blockChain{
	return [[self alloc] init];
}

-(id) init{
	if (self = [super init]){
		_orphanBlocks = [NSMutableDictionary dictionaryWithCapacity:1];
		_blocks = [NSMutableDictionary dictionaryWithCapacity:1];
		
		// Add the genesis block
		BitcoinBlock *genesisBlock = [BitcoinBlock genesisBlock];
		NSData *hash = [genesisBlock getHash];
		
		[self.blocks setObject:genesisBlock forKey:hash];
		self.chainHead = genesisBlock;
	}
	
	return self;
}

-(void)addBlock:(BitcoinBlock*)block{
	NSData *hash = [block getHash];
	
	// Check if we already have it
	if (hash == [self.chainHead getHash]) return;
	if ([self.orphanBlocks objectForKey:hash]) return;
	if ([self.blocks objectForKey:hash]) return;
	
	// Do we have the previous?
	BitcoinBlock *prevBlock = [self.blocks objectForKey:[block prev_block]];
	if (prevBlock == nil){
		// We don't know the previous block, so it's probably a block we received while downloading the chain
		// Store it for later processing once we have more blocks
		[self.orphanBlocks setObject:block forKey:hash];
		DDLogWarn(@"Added orphan block: %@", hash);
	}
	else{
		if ([self.chainHead getHash] == [prevBlock getHash]){
			// The previous block was the head, so this is just the chain continuing on like normal
			[self.blocks setObject:block forKey:hash];
			self.chainHead = block;
			DDLogInfo(@"Added new block to the end of the chain: %@", hash);
			
			// Now try and connect orphans
			int orphansConnected;
			do {
				orphansConnected = 0;
				for (NSData *orphanHash in self.orphanBlocks){
					BitcoinBlock *orphan = [self.orphanBlocks objectForKey:orphanHash];
					if ([self.chainHead getHash] == [orphan prev_block]){
						[self.blocks setObject:block forKey:hash];
						self.chainHead = block;
						[self.orphanBlocks removeObjectForKey:orphanHash];
						DDLogInfo(@"Moved orphan to the end of the chain: %@", orphanHash);
						
						orphansConnected++;
					}
				}
			} while (orphansConnected > 0);
		}
		else{
			// This connects somewhere else in the chain, so we need to figure out where the split happened
			// and potentially re-organize
			DDLogError(@"Received out-of-order block: %@", hash);
		}
	}
}

@end
