//
//  LHSKippt.m
//  LHSKippt
//
//  Created by Dan Loewenherz on 3/21/14.
//  Copyright (c) 2014 Lionheart Software LLC. All rights reserved.
//

#import "LHSKipptClient.h"

@interface NSDictionary (LHSKipptAdditions)

- (NSString *)_queryParametersToString;

@end

@implementation NSDictionary (LHSKipptAdditions)

- (NSString *)_queryParametersToString {
    NSMutableArray *items = [NSMutableArray array];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        [items addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }];
    
    if (items.count > 0) {
        return [items componentsJoinedByString:@"&"];
    }
    else {
        return nil;
    }
}

@end

@implementation LHSKipptClient

+ (instancetype)sharedClient {
    static LHSKipptClient *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[LHSKipptClient alloc] init];
        
        _sharedClient.session = [NSURLSession sessionWithConfiguration:nil
                                                               delegate:_sharedClient
                                                          delegateQueue:[NSOperationQueue currentQueue]];
    });
    return _sharedClient;
}

- (void)requestPath:(NSString *)path
             method:(NSString *)method
         parameters:(NSDictionary *)parameters
            success:(LHSKipptGenericBlock)success
            failure:(LHSKipptErrorBlock)failure {
    if (!failure) {
        failure = ^(NSError *error) {};
    }

    NSMutableArray *urlComponents = [NSMutableArray arrayWithObject:LHSKipptBaseURL];
    [urlComponents addObject:path];

    NSString *body = [parameters _queryParametersToString];
    if (![method isEqualToString:@"POST"] && body) {
        [urlComponents addObject:body];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[urlComponents componentsJoinedByString:@""]]];
    request.HTTPMethod = method;

    if ([method isEqualToString:@"POST"]) {
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    }

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                                                 }];
    [task resume];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
}

#pragma mark - Authentication

- (void)setUsername:(NSString *)username
           password:(NSString *)password {
    NSURLCredential *credential = [NSURLCredential credentialWithUser:username
                                                             password:password
                                                          persistence:NSURLCredentialPersistencePermanent];
    
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"kippt.com"
                                                                                  port:0
                                                                              protocol:@"https"
                                                                                 realm:nil
                                                                  authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
    
    [self.session.configuration.URLCredentialStorage setDefaultCredential:credential
                                                       forProtectionSpace:protectionSpace];
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(LHSKipptEmptyBlock)success
                  failure:(LHSKipptErrorBlock)failure {
    NSURLCredential *credential = [NSURLCredential credentialWithUser:username
                                                             password:password
                                                          persistence:NSURLCredentialPersistencePermanent];
    
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"kippt.com"
                                                                                  port:0
                                                                              protocol:@"https"
                                                                                 realm:nil
                                                                  authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
    
    [self.session.configuration.URLCredentialStorage setDefaultCredential:credential
                                                       forProtectionSpace:protectionSpace];
}

- (void)accountWithSuccess:(LHSKipptEmptyBlock)success
                   failure:(LHSKipptErrorBlock)failure {
    [self requestPath:@"account/"
               method:@"GET"
           parameters:nil
              success:^(id JSON) {
                  
              }
              failure:failure];
}

#pragma mark - Clips

- (void)clipsWithFilters:(LHSKipptDataFilters)filters
                   since:(NSDate *)since
                     url:(NSURL *)url
                 success:(LHSKipptClipsBlock)success
                 failure:(LHSKipptErrorBlock)failure {

    NSMutableArray *filterComponents = [NSMutableArray array];
    if (filters & LHSKipptListFilter) {
        [filterComponents addObject:@"list"];
    }
    
    if (filters & LHSKipptViaFilter) {
        [filterComponents addObject:@"via"];
    }

    if (filters & LHSKipptMediaFilter) {
        [filterComponents addObject:@"media"];
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (filterComponents.count > 0) {
        parameters[@"include_data"] = [filterComponents componentsJoinedByString:@","];
    }

    [self requestPath:@"clips/"
               method:@"GET"
           parameters:parameters
              success:^(id JSON) {

              }
              failure:failure];
}

@end
