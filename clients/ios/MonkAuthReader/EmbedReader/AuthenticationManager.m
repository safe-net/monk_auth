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

-(id)init {
    [super init];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return self;
}

-(RACSignal *)authenticate:(NSString *)url {
    return [self enqueueRequestWithMethod: @"PUT" path:url parameters:@{@"email":"james@safemonk.com"}];
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
