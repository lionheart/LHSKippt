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
        
        _sharedClient.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                               delegate:_sharedClient
                                                          delegateQueue:nil];
    });
    return _sharedClient;
}

#pragma Delegate methods

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSURLCredential *cred = [NSURLCredential credentialWithUser:@"chrisddm@gmail.com" password:@"12#Qwaszx" persistence:NSURLCredentialPersistenceNone];
    completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
    NSLog(@"didReceiveChallenge");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,    NSURLCredential *credential))completionHandler
{
    NSURLCredential *cred = [NSURLCredential credentialWithUser:@"chrisddm@gmail.com" password:@"12#Qwaszx" persistence:NSURLCredentialPersistenceNone];
        completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
     NSLog(@"didReceiveChallenge");
}

- (void)requestPath:(NSString *)path
             method:(NSString *)method
         parameters:(NSDictionary *)parameters
            success:(LHSKipptGenericBlock)success
            failure:(LHSKipptErrorBlock)failure {

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
                                                     if (!error) {
                                                         NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                         if (httpResp.statusCode == 200) {
                                                             // 3
                                                             NSError *jsonError;
                                                             
                                                             // 2
                                                             NSDictionary *response =
                                                             [NSJSONSerialization JSONObjectWithData:data
                                                                                             options:NSJSONReadingAllowFragments                                                                             
                                                                                               error:&jsonError];
                                                             if (!jsonError) {
                                                                 success(response);
                                                             }
                                                             else {
                                                                 failure (jsonError);
                                                             }
                                                             
                                                         } else {
                                                             // HANDLE BAD RESPONSE //
                                                             failure(error);
                                                         }
                                                     } else {
                                                         // ALWAYS HANDLE ERRORS :-] //
                                                         failure(error);
                                                     }

                                                 }];
    [task resume];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
}

#pragma mark - Authentication

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(LHSKipptGenericBlock)success
                  failure:(LHSKipptErrorBlock)failure {
    NSURLCredential *credential = [NSURLCredential credentialWithUser:username
                                                             password:password
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"kippt.com"
                                                                                  port:0
                                                                              protocol:@"https"
                                                                                 realm:@"kippt.com"
                                                                  authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
    NSURLCredentialStorage *credentials = [NSURLCredentialStorage sharedCredentialStorage];
    [credentials setDefaultCredential:credential forProtectionSpace:protectionSpace];
    
    [self.session.configuration.URLCredentialStorage setDefaultCredential:credential
                                                       forProtectionSpace:protectionSpace];
    [ _session.configuration setURLCredentialStorage:credentials];
    [self accountWithSuccess:success failure:failure];
}

- (void)accountWithSuccess:(LHSKipptGenericBlock)success
                   failure:(LHSKipptErrorBlock)failure {
    [self requestPath:@"account/"
               method:@"GET"
           parameters:nil
              success:^(id JSON) {
                  success(JSON);
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

-(void)retreiveNoteText
{
    // 1
//    NSString *fileApi =
//    @"https://api-content.dropbox.com/1/files/dropbox";
//    NSString *escapedPath = [_note.path
//                             stringByAddingPercentEscapesUsingEncoding:
//                             NSUTF8StringEncoding];
    
//    NSString *urlStr = [NSString stringWithFormat: @"%@/%@",
//                        fileApi,escapedPath];
    
    NSURL *url = [NSURL URLWithString: @""];
    
    // 2
    [[_session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            if (httpResp.statusCode == 200) {
                // 3
            
                dispatch_async(dispatch_get_main_queue(), ^{

                });
                
            } else {
                // HANDLE BAD RESPONSE //
            }
        } else {
            // ALWAYS HANDLE ERRORS :-] //
        }
        // 4
    }] resume];
}

@end
