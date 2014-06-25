//
// Created by James FitzGerald on 6/24/14.
//

#import "SNLUserDeviceKeys.h"


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

//    [queryPublicKey setObject:(__bridge_transfer id)kSecClassKey forKey:(__bridge_transfer id)kSecClass];
//
//    [queryPublicKey setObject:publicTag forKey:(__bridge_transfer id)kSecAttrApplicationTag];
//    [queryPublicKey setObject:(__bridge_transfer id)kSecAttrKeyTypeRSA forKey:(__bridge_transfer id)kSecAttrKeyType];
//    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge_transfer id)kSecReturnData];


}

-(void)saveKeyPair {
    // TODO...  I believe SegGenKeyPair puts it in the key chain
    // Put it in the key chain
    //NSMutableDictionary *
}

@end