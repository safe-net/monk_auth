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
    size_t sigLen = SecKeyGetBlockSize(_privateKey);
    
    // Malloc a buffer to hold signature.
    NSMutableData *sigOut = [NSMutableData dataWithLength:sigLen];
    
    // Sign the SHA256 hash.
    OSStatus status = SecKeyRawSign(_privateKey, kSecPaddingPKCS1SHA256, hashOut.mutableBytes, hashOut.length, sigOut.mutableBytes, &sigLen);
    if (status != noErr) {
        NSLog(@"Failed to sign message");
        return  nil;
    }
        
    // Convert to a string...
    NSString *base64String = [self base64forData:sigOut];
    //NSLog(@"%@", base64String);

    return base64String;
}

// TODO: move this to a util class...
-(NSString*)base64forData:(NSData*)theData
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

-(NSData *)getPublicKeyBits {
    OSStatus sanityCheck = noErr;
    NSData * publicKeyBits = nil;
    NSData *publicTag = [_pubKeyIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnData];
    
    // Get the key bits.
    sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyBits);
    
    if (sanityCheck != noErr)
    {
        publicKeyBits = nil;
    }
    
    [queryPublicKey release];
    
    return publicKeyBits;
}

-(NSString *)exportPublicKey {
    NSData *publicKeyBits = [self getPublicKeyBits];
    if (!publicKeyBits) {
        NSLog(@"Failed to export public key");
        return  nil;
    }
    
    return [self base64forData:publicKeyBits];
}

@end