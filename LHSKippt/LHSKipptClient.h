//
//  LHSKippt.h
//  LHSKippt
//
//  Created by Dan Loewenherz on 3/21/14.
//  Copyright (c) 2014 Lionheart Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LHSClip;

static NSString * const LHSKipptBaseURL = @"https://kippt.com/api/";

typedef void (^LHSKipptEmptyBlock)();
typedef void (^LHSKipptGenericBlock)(id);
typedef void (^LHSKipptArrayBlock)(NSArray *response);
typedef void (^LHSKipptErrorBlock)(NSError *error);
typedef void (^LHSKipptClipsBlock)(NSArray *clips);
typedef void (^LHSKipptClipBlock)(NSDictionary *clip);

typedef NS_OPTIONS(NSUInteger, LHSKipptDataFilters) {
    LHSKippNoFilter = 0,
    LHSKipptListFilter = (1 << 0),
    LHSKipptViaFilter = (1 << 1),
    LHSKipptMediaFilter = (1 << 2)
};

@interface LHSKipptClient : NSObject <NSURLConnectionDelegate, NSURLSessionDelegate,NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLSession *session;

+ (instancetype)sharedClient;

- (void)requestPath:(NSString *)path
             method:(NSString *)method
         parameters:(NSDictionary *)parameters
            success:(LHSKipptGenericBlock)success
            failure:(LHSKipptErrorBlock)failure;

#pragma mark - User log in
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(LHSKipptGenericBlock)success
                  failure:(LHSKipptErrorBlock)failure;

#pragma mark - User clips, both public and private

- (void)clipsFeedWithFilters:(LHSKipptDataFilters)filters
                     success:(LHSKipptClipsBlock)success
                     failure:(LHSKipptErrorBlock)failure;

- (void)clipsWithFilters:(LHSKipptDataFilters)filters
                   since:(NSDate *)since
                     url:(NSURL *)url
                 success:(LHSKipptClipsBlock)success
                 failure:(LHSKipptErrorBlock)failure;

#pragma mark - Favorite clips
- (void)favoriteClipsWithFilters:(LHSKipptDataFilters)filters
                           since:(NSDate *)since
                             url:(NSURL *)url
                         success:(LHSKipptClipsBlock)success
                         failure:(LHSKipptErrorBlock)failure;

#pragma mark - fetch clip by its id
-(void) clipById:(NSInteger) clipId  withFilters:(LHSKipptDataFilters)filters
         success:(LHSKipptClipBlock)success failure:(LHSKipptErrorBlock)failure;

#pragma mark - Search a clip by keyword
-(void) searchByKeyword:(NSString*) keyword withFilters:(LHSKipptDataFilters)filters
                success:(LHSKipptGenericBlock)success failure:(LHSKipptErrorBlock)failure;

#pragma mark - Modify a clip
-(void) modifyClip:(LHSClip*) clip success:(LHSKipptGenericBlock)success failure:(LHSKipptErrorBlock)failure;

#pragma mark - Create new clip
-(void) createNewClip:(LHSClip*) clip success:(LHSKipptGenericBlock)success failure:(LHSKipptErrorBlock)failure;

#pragma mark - Favorite a Clip
-(void) favoriteAClip: (NSInteger) clipId success:(LHSKipptGenericBlock)success failure:(LHSKipptErrorBlock)failure;

#pragma mark - Delete a Clip
-(void) deleteClip: (NSInteger) clipId success:(LHSKipptEmptyBlock)success failure:(LHSKipptErrorBlock)failure;

@end
