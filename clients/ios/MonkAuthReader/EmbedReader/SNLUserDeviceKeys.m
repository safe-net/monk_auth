//
// Created by James FitzGerald on 6/24/14.
//

#import "SNLUserDeviceKeys.h"
#import <CommonCrypto/CommonDigest.h>
//#import <SecSignVerifyTransform.h>

@interface SNLUserDeviceKeys ()
@property NSString *pubKeyIdentifier;
@property NSString *priKeyIdentifier;
@end
@implementation SNLUserDeviceKeys {

}

-(id)init {
    [super init];
    _publicKey = nil;
    _privateKey = nil;
    _pubKeyIdentifier = @"com.safemonk.monkauth.publickey";
    _priKeyIdentifier = @"com.safemonk.monkauth.privatekey";
    if (![self loadKeyPair])
        [self generateKeyPair];
    return self;
}

-(void)dealloc {

    CFRelease(_publicKey);
    CFRelease(_privateKey);
    [super dealloc];
}

-(void)generateKeyPair {


    NSNumber *keySize = @2048;

    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];

    NSData * publicTag = [_pubKeyIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    NSData * privateTag = [_priKeyIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    [keyPairAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [keyPairAttr setObject:keySize forKey:(id)kSecAttrKeySizeInBits];
    [privateKeyAttr setObject:@YES forKey:(id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(id)kSecAttrApplicationTag];
    [publicKeyAttr setObject:@YES forKey:(id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(id)kSecAttrApplicationTag];
    [keyPairAttr setObject:privateKeyAttr forKey:(id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(id)kSecPublicKeyAttrs];
    OSStatus status = SecKeyGeneratePair((CFDictionaryRef)keyPairAttr, &_publicKey, &_privateKey);

    // Put it in the key chain while we are here
    //[self saveKeyPair];

}

-(BOOL)loadKeyPair {

    NSData * publicTag = [_pubKeyIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    NSData * privateTag = [_priKeyIdentifier dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];

    [privateKeyAttr setObject:(id)kSecClassKey forKey:(id)kSecClass];
    [privateKeyAttr setObject:privateTag forKey:(id)kSecAttrApplicationTag];
    [privateKeyAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [privateKeyAttr setObject:@YES forKey:(id)kSecReturnRef];

    OSStatus status = SecItemCopyMatching(privateKeyAttr, &_privateKey);

    if (status == errSecItemNotFound) {
        NSLog(@"Key does not yet exit we will have to generate it");
        return NO;
    } else if (status != noErr) {
        NSLog(@"Something went wrong with the keychain");
        return NO;
    }

    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    [publicKeyAttr setObject:(id)kSecClassKey forKey:(id)kSecClass];
    [publicKeyAttr setObject:publicTag forKey:(id)kSecAttrApplicationTag];
    [publicKeyAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [publicKeyAttr setObject:@YES forKey:(id)kSecReturnRef];
    status = SecItemCopyMatching(publicKeyAttr, &_publicKey);
    return status == noErr;
}

-(NSString *)sign:(NSString *)message {
    // Hash the message using SHA-256
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *hashOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(messageData.bytes, messageData.length,  hashOut.mutableBytes);
    size_t sigLen = 0;
    OSStatus status = SecKeyRawSign(_privateKey, kSecPaddingPKCS1, hashOut.mutableBytes, hashOut.length, nil, &sigLen);
    NSMutableData *sigOut = [NSMutableData dataWithLength:sigLen];
    status = SecKeyRawSign(_privateKey, kSecPaddingPKCS1, hashOut.mutableBytes, hashOut.length, sigOut.mutableBytes, &sigLen);

    // TODO: Convert to a string...

    return nil;
}


@end