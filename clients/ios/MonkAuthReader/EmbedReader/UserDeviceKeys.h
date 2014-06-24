//
// Created by James FitzGerald on 6/24/14.
//

#import <Foundation/Foundation.h>


@interface UserDeviceKeys : NSObject
@property SecKeyRef publicKey;
@property SecKeyRef privateKey;

-(void)generateKeyPair;
-(void)loadKeyPair;
-(void)saveKeyPair;


@end