//
//  LHSKippt.h
//  LHSKippt
//
//  Created by Dan Loewenherz on 3/21/14.
//  Copyright (c) 2014 Lionheart Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const LHSKipptBaseURL = @"https://kippt.com/api/";

typedef void (^LHSKipptEmptyBlock)();
typedef void (^LHSKipptGenericBlock)(id);
typedef void (^LHSKipptArrayBlock)(NSArray *);
typedef void (^LHSKipptErrorBlock)(NSError *);

typedef NS_OPTIONS(NSUInteger, LHSKipptDataFilters) {
    LHSKipptListFilter,
    LHSKipptViaFilter,
    LHSKipptMediaFilter,
};

@interface LHSKipptClient : NSObject <NSURLConnectionDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

+ (instancetype)sharedClient;

- (void)requestPath:(NSString *)path
             method:(NSString *)method
         parameters:(NSDictionary *)parameters
            success:(LHSKipptGenericBlock)success
            failure:(LHSKipptErrorBlock)failure;

- (void)setUsername:(NSString *)username
           password:(NSString *)password;

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(LHSKipptEmptyBlock)success
                  failure:(LHSKipptErrorBlock)failure;

- (void)accountWithSuccess:(LHSKipptEmptyBlock)success
                   failure:(LHSKipptErrorBlock)failure;

typedef void (^LHSKipptClipsBlock)(NSArray *clips, NSUInteger total);
- (void)clipsWithFilters:(LHSKipptDataFilters)filters
                   since:(NSDate *)since
                     url:(NSURL *)url
                 success:(LHSKipptClipsBlock)success
                 failure:(LHSKipptErrorBlock)failure;

@end
