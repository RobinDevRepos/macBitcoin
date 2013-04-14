//
//  BitcoinMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/13/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitcoinMessage : NSObject

@property int messageType;
@property NSData *bytes;
@property NSData *checksum;

-(id)initFromBytes:(NSData*)data;

@end
