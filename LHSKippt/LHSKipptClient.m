//
//  LHSKippt.m
//  LHSKippt
//
//  Created by Dan Loewenherz on 3/21/14.
//  Copyright (c) 2014 Lionheart Software LLC. All rights reserved.
//

#import "LHSKipptClient.h"
#import "LHSClip.h"

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

@interface LHSKipptClient ()

@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *password;

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
    NSURLCredential *newCredential = [NSURLCredential credentialWithUser:self.userName
                                                                password:self.password
                                            persistence:NSURLCredentialPersistenceNone];
    completionHandler(NSURLSessionAuthChallengeUseCredential, newCredential);
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,    NSURLCredential *credential))completionHandler
{
    NSURLCredential *newCredential = [NSURLCredential credentialWithUser:self.userName
                                                                password:self.password
                                                             persistence:NSURLCredentialPersistenceNone];
    completionHandler(NSURLSessionAuthChallengeUseCredential, newCredential);
}


- (void)requestPath:(NSString *)path
             method:(NSString *)method
         parameters:(NSDictionary *)parameters
            success:(LHSKipptGenericBlock)success
            failure:(LHSKipptErrorBlock)failure {

    NSMutableArray *urlComponents = [NSMutableArray arrayWithObject:LHSKipptBaseURL];
    [urlComponents addObject:path];

    NSString *body = [parameters _queryParametersToString];
    if ([method isEqualToString:@"GET"] && body) {
        [urlComponents addObject:@"?"];
        [urlComponents addObject:body];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[urlComponents componentsJoinedByString:@""]]];
    request.HTTPMethod = method;

    if ([method isEqualToString:@"POST"]) {
//        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
        [request setHTTPBody:postData];
    }
    if ([method isEqualToString:@"PUT"]) {
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
        [request setHTTPBody:postData];
    }

    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
         if (!error) {
             NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
             if (httpResp.statusCode == 200 || httpResp.statusCode == 201) {
                 
                 NSError *jsonError;
                 NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                 options:NSJSONReadingAllowFragments error:&jsonError];
                 if (!jsonError) {
                     success(response);
                 }
                 else {
                     failure (jsonError);
                 }
                 
             } else {
                 // HANDLE BAD RESPONSE //
                 
                 failure([NSError errorWithDomain:@"Kipp.com" code:httpResp.statusCode
                                         userInfo:@{@"status code":@(httpResp.statusCode)}]);
             }
         } else {
             // ALWAYS HANDLE ERRORS :-] //
             failure(error);
         }

     }] resume];
}

#pragma mark - Authentication

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(LHSKipptGenericBlock)success
                  failure:(LHSKipptErrorBlock)failure {
    
    self.password = password;
    self.userName = username;
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.password
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

#pragma Clips feed
- (void)clipsFeedWithFilters:(LHSKipptDataFilters)filters
                 success:(LHSKipptClipsBlock)success
                 failure:(LHSKipptErrorBlock)failure {
    
    NSMutableDictionary *parameters = [self addFilterParamsForFilter:filters];
    
    [self requestPath:@"clips/feed/?"
               method:@"GET"
           parameters:parameters
              success:^(id response) {
                  NSArray *clipsFeed = [response objectForKey:@"objects"];
                  success(clipsFeed);
              }
              failure:failure];
}

#pragma mark - Clips

- (void)clipsForCurrentUserWithSuccess:(LHSKipptClipsBlock)success
                               failure:(LHSKipptErrorBlock)failure {
    [self requestPath:@"clips/"
               method:@"GET"
           parameters:nil
              success:^(id response) {
                  
                  NSArray *clips = [response objectForKey:@"objects"];
                  success(clips);
              }
              failure:failure];
}

- (void)clipsWithFilters:(LHSKipptDataFilters)filters
                   since:(NSDate *)since
                     url:(NSURL *)url
                 success:(LHSKipptClipsBlock)success
                 failure:(LHSKipptErrorBlock)failure {

    NSMutableDictionary *parameters = [self addFilterParamsForFilter:filters];
    
    if (url) {
        parameters [@"url"] = [url absoluteString];
    }
    if (since) {
        parameters [@"since"] = @(round([since timeIntervalSince1970]));
    }

    [self requestPath:@"clips/?"
               method:@"GET"
           parameters:parameters
              success:^(NSDictionary *response) {
                  NSArray *clips = [response objectForKey:@"objects"];
                  success(clips);
              }
              failure:failure];
}

#pragma FavoriteClips

- (void)favoriteClipsWithFilters:(LHSKipptDataFilters)filters
                   since:(NSDate *)since
                     url:(NSURL *)url
                 success:(LHSKipptClipsBlock)success
                 failure:(LHSKipptErrorBlock)failure {
    
    NSMutableDictionary *parameters = [self addFilterParamsForFilter:filters];
    
    if (url) {
        parameters [@"url"] = [url absoluteString];
    }
    if (since) {
        parameters [@"since"] = @(round([since timeIntervalSince1970]));
    }
    
    [self requestPath:@"clips/favorites/"
               method:@"GET"
           parameters:parameters
              success:^(NSDictionary *response) {
                  NSArray *clips = [response objectForKey:@"objects"];
                  success(clips);
              }
              failure:failure];
}

#pragma Get Clip by id
-(void) clipById:(NSInteger) clipId  withFilters:(LHSKipptDataFilters)filters
         success:(LHSKipptClipBlock)success failure:(LHSKipptErrorBlock)failure {
    
    NSMutableDictionary *parameters = [self addFilterParamsForFilter:filters];
    
    [self requestPath:[NSString stringWithFormat:@"clips/%d",clipId]
               method:@"GET"
           parameters:parameters
              success:^(NSDictionary *response) {
                  success(response);
              }
              failure:failure];
}

#pragma Search a clip by keyword
-(void) searchByKeyword:(NSString*) keyword withFilters:(LHSKipptDataFilters)filters
                success:(LHSKipptGenericBlock)success failure:(LHSKipptErrorBlock)failure {
    
    NSMutableDictionary *parameters = [self addFilterParamsForFilter:filters];
    parameters [@"q"] = keyword;
    
    [self requestPath:@"clips/search/"
               method:@"GET"
           parameters:parameters
              success:^(NSArray *response) {
                  success(response);
              }
              failure:failure];
}

#pragma Modify a clip
-(void) modifyClip:(LHSClip*) clip success:(LHSKipptGenericBlock)success failure:(LHSKipptErrorBlock)failure {
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"title"] = clip.title,
    payload[@"notes"] = clip.notes;
    payload[@"is_favorite"] = @(clip.isFavorite);
    payload[@"url"] =  [clip.url absoluteString];
    
    [self requestPath:[NSString stringWithFormat:@"clips/%d/",clip.clipId]
               method:@"PUT"
           parameters:payload
              success:^(NSArray *response) {
                  success(response);
              }
              failure:failure];
}

-(void) createNewClip:(LHSClip*) clip success:(LHSKipptGenericBlock)success failure:(LHSKipptErrorBlock)failure {
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"title"] = clip.title,
    payload[@"notes"] = clip.notes;
    payload[@"url"] =  [clip.url absoluteString];
    
    [self requestPath:@"clips/"
               method:@"POST"
           parameters:payload
              success:^(NSDictionary *response) {
                  success(response);
              }
              failure:failure];
}

- (NSMutableDictionary *)addFilterParamsForFilter:(LHSKipptDataFilters)filters
{
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
    
    return parameters;
}

@end
