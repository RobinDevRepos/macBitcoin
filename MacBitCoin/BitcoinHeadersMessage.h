//
//  BitcoinHeadersMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/21/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BitcoinVarInt.h"
#import "BitcoinBlock.h"

@interface BitcoinHeadersMessage : NSObject

@property BitcoinVarInt *count;
@property NSMutableArray *headers;

+(id)message;
-(id)init;

+(id)messageFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(void)pushHeader:(BitcoinBlock*)block;
-(NSUInteger)countHeaders;

-(NSData*) getData;

@end
