//
//  BitcoinVarInt.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/14/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitcoinVarInt : NSObject

@property uint64_t value;
@property (readonly) uint8_t size;

+(id) varintFromValue:(uint64_t)value;
+(id) varintFromBytes:(NSData*)data fromOffset:(int)offset;

-(id) initFromValue:(uint64_t)value;
-(id) initFromBytes:(NSData*)data fromOffset:(int)offset;

-(uint8_t) sizeOf:(uint64_t)value;

-(NSData*) getData;

@end
