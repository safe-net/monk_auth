//
// Created by James FitzGerald on 6/24/14.
//

#import <Foundation/Foundation.h>


@interface SNLUserDeviceKeys : NSObject
@property SecKeyRef publicKey;
@property SecKeyRef privateKey;
-(NSString *)sign:(NSString *)message;
-(NSString *)exportPublicKey;
@end