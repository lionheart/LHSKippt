//
//  LHSKippt_Tests.m
//  LHSKippt Tests
//
//  Created by Dan Loewenherz on 3/22/14.
//  Copyright (c) 2014 Lionheart Software LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LHSKipptClient.h"

@interface LHSKippt_Tests : XCTestCase

@end

@implementation LHSKippt_Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    LHSKipptClient *kippt = [LHSKipptClient sharedClient];
    [kippt setUsername:@"AAAA" password:@"BBBB"];
    [kippt accountWithSuccess:^{
        
    }
                      failure:^(NSError *error) {
                          
                      }];
}

@end
