//
//  BitcoinGetblocksMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/19/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BitcoinVarInt.h"

@interface BitcoinGetblocksMessage : NSObject

@property uint32_t version;
@property BitcoinVarInt *count;
@property NSMutableArray *hashes;
@property NSData *hash_stop;

+(id)message;

+(id)messageFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(NSData*) getData;

@end
