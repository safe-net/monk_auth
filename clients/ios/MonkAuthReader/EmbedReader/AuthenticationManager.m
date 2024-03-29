//
//  AuthenticationManager.m
//  EmbedReader
//
//  Created by James FitzGerald on 6/23/14.
//
//

#import "AuthenticationManager.h"
#import "RACSignal.h"
#import "RACSubscriber.h"
#import "AFNetworking.h"
#import "RACDisposable.h"
#import "SNLUserDeviceKeys.h"
#import "DeviceId.h"

@interface AuthenticationManager ()
@property SNLUserDeviceKeys *userKeyPair;
@end

@implementation AuthenticationManager

-(id)init {
    [super init];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    _userKeyPair = [[SNLUserDeviceKeys alloc] init];
    return self;
}

-(RACSignal *)processUrl:(NSString *)url {
    NSString *signedMessage = [_userKeyPair sign:url];
    NSString *publicKey = [_userKeyPair exportPublicKey];
    DeviceId *dev = [[DeviceId alloc] init];
    return [self enqueueRequestWithMethod: @"PUT" path:url
                               parameters:@{@"signature":signedMessage, @"public_key":publicKey,
                                       @"device_name":[dev getDeviceName]}];
}

- (RACSignal *)enqueueRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {

        return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
            NSDictionary *local_parameters = parameters;
        NSError *serializationError = nil;
        NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method
                                                                       URLString:path
                                                                      parameters:local_parameters
                                                                           error:&serializationError];
        if(serializationError) {
            [subscriber sendError:serializationError];
            return nil;
        } else {
            AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                              success:^(AFHTTPRequestOperation *op,
                                                                                      id responseObject) {
                                                                                  [subscriber sendNext:responseObject];
                                                                                  [subscriber sendCompleted];
                                                                              }
                                                                              failure:^(AFHTTPRequestOperation *operation,
                                                                                      NSError *error) {
                                                                                  [subscriber sendError:error];
                                                                              }];
            [self.operationQueue addOperation:operation];

            return [RACDisposable disposableWithBlock:^{
                if ([operation isExecuting])
                    [operation cancel];
            }];
        }

    }];
}

@end
