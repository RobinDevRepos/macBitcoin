//
//  BitcoinMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/13/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Definitions.h"

@interface BitcoinMessageHeader : NSObject

@property (nonatomic) uint32_t magic;
@property (nonatomic) BitcoinMessageType messageType;
@property (nonatomic) uint32_t length;
@property (nonatomic) uint32_t checksum;

+(id)header;
-(id)init;

+(id)headerFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

+(id)headerFromPayload:(NSData*)payload withMessageType:(BitcoinMessageType)type;
-(id)initFromPayload:(NSData*)payload withMessageType:(BitcoinMessageType)type;

+(uint32_t) buildChecksum:(NSData*)data;

-(NSData*)getData;

-(NSString*)getCommandName;

@end
