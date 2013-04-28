//
//  BitcoinTransaction.m
//  MacBitCoin
//
//  Created by Myles Grant on 4/24/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import "BitcoinTransaction.h"

#import "NSData+Integer.h"
#import "NSData+CryptoHashing.h"

@implementation BitcoinTransaction

+(id)transaction{
	return [[BitcoinTransaction alloc] init];
}

-(id)init{
	if ((self = [super init])){
		_version = 1;
		
		_tx_in_count = [BitcoinVarInt varintFromValue:0];
		_tx_in = [NSMutableArray arrayWithCapacity:1];
		
		_tx_out_count = [BitcoinVarInt varintFromValue:0];
		_tx_out = [NSMutableArray arrayWithCapacity:1];
		
		_lock_time = 0;
		
		_length = 8;
	}
	
	return self;
}

+(id)transactionFromBytes:(NSData*)data fromOffset:(int)offset{
	return [[BitcoinTransaction alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData*)data fromOffset:(int)offset{
	if ((self = [super init])){
		
		_version = [data offsetToInt32:offset];
		
		offset += 4;
		_tx_in_count = [BitcoinVarInt varintFromBytes:data fromOffset:offset];
		
		offset += [_tx_in_count size];
		_tx_in = [NSMutableArray arrayWithCapacity:[_tx_in_count value]];
		for (int i=0; i<[_tx_in_count value]; i++){
			[_tx_in addObject:[BitcoinTxIn txInFromBytes:data fromOffset:offset]];
			offset += 41;
		}
		
		_tx_out_count = [BitcoinVarInt varintFromBytes:data fromOffset:offset];
		
		offset += [_tx_out_count size];
		_tx_out = [NSMutableArray arrayWithCapacity:[_tx_out_count value]];
		for (int i=0; i<[_tx_out_count value]; i++){
			[_tx_out addObject:[BitcoinTxOut txOutFromBytes:data fromOffset:offset]];
			offset += 8;
		}
		
		_lock_time = [data offsetToInt32:offset];
	}
	
	return self;
}

-(void)addTxIn:(BitcoinTxIn*)txIn{
	[self.tx_in addObject:txIn];
	self.tx_in_count = [BitcoinVarInt varintFromValue:[self.tx_in count]];
	
	self.length = 0;
}

-(void)addTxOut:(BitcoinTxOut*)txOut{
	[self.tx_out addObject:txOut];
	self.tx_out_count = [BitcoinVarInt varintFromValue:[self.tx_out count]];
	
	self.length = 0;
}

-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[NSData dataWithInt32:self.version]];
	
	[data appendData:[self.tx_in_count getData]];
	for (BitcoinTxIn *txIn in [self tx_in]){
		[data appendData:[txIn getData]];
	}
	
	[data appendData:[self.tx_out_count getData]];
	for (BitcoinTxOut *txOut in [self tx_out]){
		[data appendData:[txOut getData]];
	}

	[data appendData:[NSData dataWithInt32:self.lock_time]];
	
	return data;
}

// Build a hash, unless we've built one already. Return it
-(NSData*) getHash{
	if (!self.hash){
		NSData *data = [self getData];
		self.hash = [[data sha256Hash] sha256Hash];
	}
	
	return self.hash;
}

-(NSUInteger) getLength{
	if (!self.length){
		self.length += 4; // version
		
		self.length += [self.tx_in_count size];
		for (BitcoinTxIn *txIn in [self tx_in]){
			self.length += 36; // OutPoint
			
			// signature script
			self.length += [[txIn script_length] size];
			self.length += [[txIn script_length] value];
			
			self.length += 4; // sequence
		}
		
		self.length += [self.tx_out_count size];
		for (BitcoinTxOut *txOut in [self tx_out]){
			self.length += 8; // value
			
			// pk script
			self.length += [[txOut pk_script_length] size];
			self.length += [[txOut pk_script_length] value];
		}
		
		self.length += 4; // lock_time
	}
	
	return self.length;
}

@end

@implementation BitcoinOutPoint

+(id)outPoint{
	return [[BitcoinOutPoint alloc] init];
}

-(id)init{
	if ((self = [super init])){
		_hash = [NSMutableData dataWithLength:32];
		_index = UINT32_MAX;
	}
	
	return self;
}

+(id)outPointFromBytes:(NSData*)data fromOffset:(int)offset{
	return [[BitcoinOutPoint alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData*)data fromOffset:(int)offset{
	if ((self = [super init])){
		
		_hash = [data subdataWithRange:NSMakeRange(offset, 32)];
		
		offset += 32;
		_index = [data offsetToInt32:offset];
	}
	
	return self;
}

-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:self.hash];
	[data appendData:[NSData dataWithInt32:self.index]];
	
	return data;
}

@end

@implementation BitcoinTxIn

+(id)txIn{
	return [[BitcoinTxIn alloc] init];
}

-(id)init{
	if ((self = [super init])){
		_previous_output = [BitcoinOutPoint outPoint];
		_script_length = [BitcoinVarInt varintFromValue:0];
		_sequence = UINT32_MAX;
	}
	
	return self;
}

+(id)txInFromBytes:(NSData*)data fromOffset:(int)offset{
	return [[BitcoinTxIn alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData*)data fromOffset:(int)offset{
	if ((self = [super init])){
		
		_previous_output = [BitcoinOutPoint outPointFromBytes:data fromOffset:offset];
		
		offset += 36;
		_script_length = [BitcoinVarInt varintFromBytes:data fromOffset:offset];
		
		offset += [_script_length size];
		_sequence = [data offsetToInt32:offset];
	}
	
	return self;
}

-(void)scriptFromBytes:(NSData *)data{
	self.computational_script = data;
	self.script_length = [BitcoinVarInt varintFromValue:[data length]];
}

-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[self.previous_output getData]];
	[data appendData:[self.script_length getData]];
	[data appendData:[NSData dataWithInt32:self.sequence]];
	
	return data;
}

@end

@implementation BitcoinTxOut

+(id)txOut{
	return [[BitcoinTxOut alloc] init];
}

-(id)init{
	if ((self = [super init])){
		_pk_script_length = [BitcoinVarInt varintFromValue:0];
	}
	
	return self;
}

+(id)txOutFromBytes:(NSData*)data fromOffset:(int)offset{
	return [[BitcoinTxOut alloc] initFromBytes:data fromOffset:offset];
}

-(id)initFromBytes:(NSData*)data fromOffset:(int)offset{
	if ((self = [super init])){
		
		_value = [data offsetToInt64:offset];
		
		offset += 8;
		_pk_script_length = [BitcoinVarInt varintFromBytes:data fromOffset:offset];
		
		offset += [_pk_script_length size];
		_pk_script = [data subdataWithRange:NSMakeRange(offset, _pk_script_length.value)];
	}
	
	return self;
}

-(NSData*) getData{
	NSMutableData *data = [NSMutableData data];
	
	[data appendData:[NSData dataWithInt64:self.value]];
	[data appendData:[self.pk_script_length getData]];
	[data appendData:self.pk_script];
	
	return data;
}

@end
