//
//  BitcoinGetdataMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/19/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Definitions.h"
#import "BitcoinVarInt.h"
#import "BitcoinInventoryVector.h"

@interface BitcoinGetdataMessage : NSObject

@property BitcoinVarInt *count;
@property NSMutableArray *inventory;

+(id)message;
-(id)init;

+(id)messageFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(void)pushVector:(BitcoinInventoryVector*)inv_vector;

-(NSData*) getData;

@end
