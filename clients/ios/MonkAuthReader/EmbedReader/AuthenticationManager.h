//
//  AuthenticationManager.h
//  EmbedReader
//
//  Created by James FitzGerald on 6/23/14.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>


@class RACSignal;

@interface AuthenticationManager : AFHTTPRequestOperationManager
-(RACSignal *)authenticate:(NSString *)url;

@end

