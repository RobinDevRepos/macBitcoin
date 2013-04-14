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
#import "BitcoinVarInt.h"

@interface BitcoinVersionMessage : BitcoinMessage

@property int32_t version;
@property uint64_t services;
@property int64_t timestamp;

@property BitcoinAddress *addr_recv;
@property BitcoinAddress *addr_from;

@property uint64_t nonce;

@property NSString *user_agent;

@property int32_t start_height;
@property bool relay;

@end
