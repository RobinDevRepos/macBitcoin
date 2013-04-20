//
//  BitcoinInvMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/18/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Definitions.h"
#import "BitcoinVarInt.h"

@interface BitcoinInvMessage : NSObject

@property BitcoinVarInt *count;
@property NSMutableArray *inventory;

+(id)message;

+(id)messageFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(NSData*) getData;

@end
