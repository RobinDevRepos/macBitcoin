//
//  MessageHeader.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/10/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageHeader : NSObject <NSCoding> {
	uint32_t magic;
	NSString *command;
	uint32_t length;
	uint32_t checksum;
}

@property (nonatomic) uint32_t magic;
@property (nonatomic, copy) NSString *command;
@property (nonatomic) uint32_t length;
@property (nonatomic) uint32_t checksum;

@end
