//
//  BitcoinAddress.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/14/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitcoinAddress : NSObject

@property (nonatomic) uint32_t time;
@property (nonatomic) uint64_t services;
@property NSString *address;
@property (nonatomic) uint16_t port;

+(id) addressFromAddress:(NSString*)address withPort:(uint16_t)port;
-(id) initFromAddress:(NSString*)address withPort:(uint16_t)port;

+(id) addressFromBytes:(NSData*)data fromOffset:(int)offset;

+(id) addressFromBytes:(NSData*)data fromOffset:(int)offset withTimestamp:(bool)useTimestamp;
-(id) initFromBytes:(NSData*)data fromOffset:(int)offset withTimestamp:(bool)useTimestamp;

-(NSData*) getData;
-(NSData*) getData:(bool)useTimestamp;

@end
