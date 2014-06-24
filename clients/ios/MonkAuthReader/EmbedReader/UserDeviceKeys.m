//
// Created by James FitzGerald on 6/24/14.
//

#import "UserDeviceKeys.h"


@implementation UserDeviceKeys {

}

-(id)init {
    [super init];
    _publicKey = nil;
    _privateKey = nil;
    return self;
}

-(void)dealloc {
    CFRelease(_publicKey);
    CFRelease(_privateKey);
}

-(void)generateKeyPair {

    NSString *pubKeyIdentifier = @"com.safemonk.monkauth.publickey";
    NSString *priKeyIdentifier = @"com.safemonk.monkauth.privatekey";
    NSNumber *keySize = @2048;

    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];

    NSData * publicTag = [NSData dataWithBytes:pubKeyIdentifier length:pubKeyIdentifier.length];
    NSData * privateTag = [NSData dataWithBytes:priKeyIdentifier length:priKeyIdentifier.length];
    [keyPairAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [keyPairAttr setObject:keySize forKey:(id)kSecAttrKeySizeInBits];
    [privateKeyAttr setObject:@YES forKey:(id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(id)kSecAttrApplicationTag];
    [publicKeyAttr setObject:@YES forKey:(id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(id)kSecAttrApplicationTag];
    [keyPairAttr setObject:privateKeyAttr forKey:(id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(id)kSecPublicKeyAttrs];
    OSStatus status = SecKeyGeneratePair((CFDictionaryRef)keyPairAttr, &_publicKey, &_privateKey);
}

-(void)loadKeyPair {
    // TODO...
}

-(void)saveKeyPair {
    // TODO...
}

@end