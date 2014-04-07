//
//  LHSClip.h
//  LHSKippt
//
//  Created by Christian De Martino on 4/6/14.
//  Copyright (c) 2014 Lionheart Software LLC. All rights reserved.
//
// Clip objects as described in https://github.com/kippt/api-documentation/blob/master/objects/clip.md
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LHSClipType) {
    LHS_Link,
    LHS_Note,
    LHS_Image,
    LHS_File
};

@interface LHSClip : NSObject

@property (nonatomic,unsafe_unretained,readonly) NSInteger clipId;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,strong,readonly) NSString *user;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong,readonly) NSArray *comments;
@property (nonatomic,strong,readonly) NSArray *likes;
@property (nonatomic,strong,readonly) NSArray *saves;
@property (nonatomic,unsafe_unretained,readonly) BOOL isFavorite;
@property (nonatomic,unsafe_unretained,readonly) LHSClipType type;
@property (nonatomic,strong) NSDate *created;
@property (nonatomic,strong) NSDate *updated;
@property (nonatomic,strong) NSURL *resource_uri;

+(instancetype) clipWithId:(NSInteger) clipId;

@end
