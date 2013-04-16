//
//  BitcoinMessage.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/13/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
	BITCOIN_MESSAGE_TYPE_VERSION = 1,
	BITCOIN_MESSAGE_TYPE_VERACK = 2,
	BITCOIN_MESSAGE_TYPE_ADDR = 4,
	BITCOIN_MESSAGE_TYPE_INV = 8,
	BITCOIN_MESSAGE_TYPE_GETDATA = 16,
	BITCOIN_MESSAGE_TYPE_GETBLOCKS = 32,
	BITCOIN_MESSAGE_TYPE_GETHEADERS = 64,
	BITCOIN_MESSAGE_TYPE_TX = 128,
	BITCOIN_MESSAGE_TYPE_BLOCK = 256,
	BITCOIN_MESSAGE_TYPE_HEADERS = 512,
	BITCOIN_MESSAGE_TYPE_GETADDR = 1024,
	BITCOIN_MESSAGE_TYPE_PING = 2048,
	BITCOIN_MESSAGE_TYPE_PONG = 4096,
	BITCOIN_MESSAGE_TYPE_ALERT = 8192,
	BITCOIN_MESSAGE_TYPE_ALT = 16384,
	BITCOIN_MESSAGE_TYPE_ADDRMAN = 32768,
	BITCOIN_MESSAGE_TYPE_CHAINDESC = 65536,
}BitcoinMessageType;

#define BITCOIN_HEADER_LENGTH 24
#define BITCOIN_COMMAND_LENGTH 12

@interface BitcoinMessage : NSObject

@property (nonatomic) uint32_t magic;
@property (nonatomic) BitcoinMessageType messageType;
@property (nonatomic) uint32_t length;
@property (nonatomic) uint32_t checksum;
@property NSData *payload;

+(id)messageFromBytes:(NSData*)data fromOffset:(int)offset;
-(id)initFromBytes:(NSData*)data fromOffset:(int)offset;

+(id)messageFromPayload:(NSData*)data fromOffset:(int)offset withType:(BitcoinMessageType)messageType;
-(id)initFromPayload:(NSData*)data fromOffset:(int)offset withType:(BitcoinMessageType)messageType;

-(void)generateHeader;

-(NSData*)getHeader;
-(NSData*)getPayload;
-(NSData*)getData;

-(NSString*)getCommandName;

@end
