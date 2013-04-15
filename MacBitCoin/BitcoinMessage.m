//
//  BitcoinMessage.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/13/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinMessage.h"

@implementation BitcoinMessage

-(id)initFromBytes:(NSData *)data{
	if ((self = [super init])){
		_bytes = [NSData dataWithData:data];
	}
	
	return self;
}

@end
