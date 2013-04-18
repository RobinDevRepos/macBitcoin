//
//  BitcoinAddrMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/18/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BitcoinVarInt.h"

@interface BitcoinAddrMessage : NSObject

@property BitcoinVarInt *count;
@property NSMutableArray *addresses;

+(id)message;

+(id)messageFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(NSData*) getData;

@end
