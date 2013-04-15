//
//  NSData+Integer.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/14/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Integer)

-(uint8_t)offsetToInt8:(NSUInteger)offset;
-(uint16_t)offsetToInt16:(NSUInteger)offset;
-(uint32_t)offsetToInt32:(NSUInteger)offset;
-(uint64_t)offsetToInt48:(NSUInteger)offset;
-(uint64_t)offsetToInt64:(NSUInteger)offset;

+(id)dataWithInt8:(uint8_t)value;
+(id)dataWithInt16:(uint16_t)value;
+(id)dataWithInt32:(uint32_t)value;
+(id)dataWithInt64:(uint64_t)value;

@end
