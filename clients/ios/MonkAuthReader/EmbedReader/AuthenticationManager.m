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

@implementation AuthenticationManager

-(RACSignal *)authenticate:(NSString *)url {
    return [self enqueueRequestWithMethod: @"POST" path:url parameters:@{}];
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