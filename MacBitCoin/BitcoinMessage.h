//
//  BitcoinMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/13/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitcoinMessage : NSObject

@property (readonly) int messageType;
@property (readonly) NSData *bytes;
@property (readonly) NSData *checksum;

-(id)initFromBytes:(NSData*)data;

@end
