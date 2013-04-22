//
//  BitcoinAddrMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/18/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BitcoinVarInt.h"
#import "BitcoinAddress.h"

@interface BitcoinAddrMessage : NSObject

@property BitcoinVarInt *count;
@property NSMutableArray *addresses;

+(id)message;
-(id)init;

+(id)messageFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(void)pushAddress:(BitcoinAddress*)address;

-(NSData*) getData;

@end
