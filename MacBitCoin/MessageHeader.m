//
//  MessageHeader.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/10/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "MessageHeader.h"

@implementation MessageHeader

@synthesize magic;
@synthesize command;
@synthesize length;
@synthesize checksum;

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.magic = [decoder decodeInt32ForKey:@"magic"];
		self.command = [decoder decodeObjectForKey:@"command"];
		self.length = [decoder decodeInt32ForKey:@"length"];
		self.checksum = [decoder decodeInt32ForKey:@"checksum"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeInt32:magic forKey:@"magic"];
	[encoder encodeObject:command forKey:@"command"];
	[encoder encodeInt32:length forKey:@"length"];
	[encoder encodeInt32:checksum forKey:@"checksum"];
}

@end
