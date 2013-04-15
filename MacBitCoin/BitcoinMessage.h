//
//  BitcoinMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/13/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitcoinMessage : NSObject

@property (nonatomic) int messageType;
@property (readonly) NSData *bytes;
@property (readonly) NSData *checksum;

+(id)messageFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

-(NSData*) getData;

@end
