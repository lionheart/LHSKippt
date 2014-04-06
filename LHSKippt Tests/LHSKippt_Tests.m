//
//  LHSKippt_Tests.m
//  LHSKippt Tests
//
//  Created by Dan Loewenherz on 3/22/14.
//  Copyright (c) 2014 Lionheart Software LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LHSKipptClient.h"
#import "XCTestCase+AsyncTesting.h"

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
    [kippt loginWithUsername:@"chrisddm@gmail.com" password:@"12#Qwaszx" success:^(id response) {
        
        NSString *username = [response objectForKey:@"username"];
        if ([username isEqualToString:@"chrisddm"]) {
              [self notify:XCTAsyncTestCaseStatusSucceeded];
        }
        else {
              [self notify:XCTAsyncTestCaseStatusFailed];
        }
       
    } failure:^(NSError *error) {
         [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForStatus: XCTAsyncTestCaseStatusSucceeded timeout:20];
}

@end
