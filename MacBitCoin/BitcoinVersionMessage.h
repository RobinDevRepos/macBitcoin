//
//  BitcoinVersionMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/13/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BitcoinMessage.h"
#import "BitcoinAddress.h"

@interface BitcoinVersionMessage : BitcoinMessage

@property (nonatomic) int32_t version;
@property (nonatomic) uint64_t services;
@property (nonatomic) int64_t timestamp;

@property BitcoinAddress *addr_recv;
@property BitcoinAddress *addr_from;

@property (nonatomic) uint64_t nonce;

@property NSString *user_agent;

@property (nonatomic) int32_t start_height;
@property (nonatomic) bool relay;

+(id)messageFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(NSData*) getData;

@end
