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
@property NSString *deviceId;
@property NSString *deviceName;
@end

@implementation AuthenticationManager

-(id)init {
    [super init];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    _userKeyPair = [[SNLUserDeviceKeys alloc] init];
    DeviceId *dev = [[DeviceId alloc] init];
    _deviceId = [dev getUniqueDeviceIdentifierAsString];
    _deviceName = [dev getDeviceName];
    return self;
}

-(RACSignal *)processUrl:(NSString *)url {
    // TODO: Extract the otc and sign it
    // Push up the signed otc + pub key etc...

    NSString *signedMessage = [_userKeyPair sign:url];


    return [self enqueueRequestWithMethod: @"PUT" path:url parameters:@{@"email":@"james@safemonk.com"}];
}

- (RACSignal *)enqueueRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {

        return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
            NSDictionary *local_parameters = parameters; // == nil; //? self.defaultParams : [self.defaultParams sdn_merge:parameters];
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
