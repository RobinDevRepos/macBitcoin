//
//  NSData+CryptoHashing.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/10/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CryptoHashing)

- (NSData *)md5Hash;
- (NSString *)md5HexHash;

- (NSData *)sha1Hash;
- (NSString *)sha1HexHash;

- (NSData *)sha256Hash;
- (NSString *)sha256HexHash;

- (NSData *)sha512Hash;
- (NSString *)sha512HexHash;

@end
