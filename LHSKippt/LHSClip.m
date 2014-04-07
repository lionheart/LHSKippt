//
//  LHSClip.m
//  LHSKippt
//
//  Created by Christian De Martino on 4/6/14.
//  Copyright (c) 2014 Lionheart Software LLC. All rights reserved.
//


#import "LHSClip.h"

@interface LHSClip ()

@property (nonatomic,unsafe_unretained,readwrite) NSInteger clipId;

@end

@implementation LHSClip

+(instancetype) clipWithId:(NSInteger) clipId {
    return [[LHSClip alloc] initWithId:clipId];
}

-(instancetype) initWithId:(NSInteger) clipId {
    self = [super init];
    if (self) {
        _clipId = clipId;
    }
    return self;
}

@end
