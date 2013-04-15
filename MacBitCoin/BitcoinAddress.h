//
//  BitcoinAddress.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/14/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitcoinAddress : NSObject

@property (nonatomic) uint32 time;
@property (nonatomic) uint64_t services;
@property NSData *address; // From CocoaAsyncSocket, is a 'struct sockaddr', so contains address and port information

-(id) initFromAddress:(NSData*)address;
-(id) initFromBytes:(NSData*)data fromOffset:(int)offset;

-(NSData*) getData;

@end
