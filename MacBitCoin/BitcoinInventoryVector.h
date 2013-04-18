//
//  BitcoinInventoryVector.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/18/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
	BITCOIN_INV_OBJ_TYPE_ERROR = 0,
	BITCOIN_INV_OBJ_TYPE_MSG_TX = 1,
	BITCOIN_INV_OBJ_TYPE_MSG_BLOCK = 2,
}BitcoinInvObjectType;

@interface BitcoinInventoryVector : NSObject

@property (nonatomic ) BitcoinInvObjectType type;
@property NSData *hash;

+(id) inventoryVectorFromBytes:(NSData*)data fromOffset:(int)offset;
-(id) initFromBytes:(NSData*)data fromOffset:(int)offset;

-(NSData*) getData;

@end
