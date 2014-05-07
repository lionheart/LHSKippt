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
#import "LHSClip.h"

static NSString* const username = @"chrisddm@gmail.com";
static NSString* const password =  @"qwe123";
static NSInteger const testClipId = 20274442;

@interface LHSKippt_Tests : XCTestCase

@property (nonatomic,strong) LHSKipptClient *kippt;

@end

@implementation LHSKippt_Tests

- (void)setUp {
    [super setUp];
    _kippt = [LHSKipptClient sharedClient];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testUserLogin {
    
    NSLog(@"Running \"%s\"", __PRETTY_FUNCTION__);
    [_kippt loginWithUsername:username password:password success:^(id response) {
        
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

-(void) testClipFeeds {
    
    NSLog(@"Running \"%s\"", __PRETTY_FUNCTION__);
    [_kippt loginWithUsername:username password:password success:^(id response) {
        
        [_kippt clipsFeedWithFilters:LHSKipptMediaFilter success:^(NSArray *clips) {
            
            [self notify:XCTAsyncTestCaseStatusSucceeded];
            
        } failure:^(NSError *error) {
            [self notify:XCTAsyncTestCaseStatusFailed];
        }];
        
    } failure:^(NSError *error) {
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForStatus: XCTAsyncTestCaseStatusSucceeded timeout:60];
}

-(void) testClips {
    
    NSLog(@"Running \"%s\"", __PRETTY_FUNCTION__);
    [_kippt loginWithUsername:username password:password success:^(id response) {
        
        [_kippt clipsWithFilters:LHSKipptListFilter since:[NSDate date] url:nil success:^(NSArray *clips) {
            [self notify:XCTAsyncTestCaseStatusSucceeded];
        } failure:^(NSError *error) {
            [self notify:XCTAsyncTestCaseStatusFailed];
        }];
        
    } failure:^(NSError *error) {
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForStatus: XCTAsyncTestCaseStatusSucceeded timeout:60];
}

-(void) testFavoriteClips {
    
    NSLog(@"Running \"%s\"", __PRETTY_FUNCTION__);
    [_kippt loginWithUsername:username password:password success:^(id response) {
        
        [_kippt favoriteClipsWithFilters:LHSKipptListFilter since:nil url:nil success:^(NSArray *clips) {
             [self notify:XCTAsyncTestCaseStatusSucceeded];
        } failure:^(NSError *error) {
             [self notify:XCTAsyncTestCaseStatusFailed];
        }];
        
    } failure:^(NSError *error) {
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForStatus: XCTAsyncTestCaseStatusSucceeded timeout:60];
}

-(void) testClipById {
    
    NSLog(@"Running \"%s\"", __PRETTY_FUNCTION__);
    [_kippt loginWithUsername:username password:password success:^(id response) {
        
        [_kippt clipById:testClipId withFilters:LHSKipptMediaFilter|LHSKipptMediaFilter
            success:^(NSDictionary *clip) {
                
                if ([[clip objectForKey:@"id"] integerValue] == testClipId) {
                     [self notify:XCTAsyncTestCaseStatusSucceeded];
                }
                else {
                     [self notify:XCTAsyncTestCaseStatusFailed];
                }
               
            } failure:^(NSError *error) {
                [self notify:XCTAsyncTestCaseStatusFailed];
            }];
        
    } failure:^(NSError *error) {
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForStatus: XCTAsyncTestCaseStatusSucceeded timeout:60];
}

-(void) testSearchClips {
    
    NSLog(@"Running \"%s\"", __PRETTY_FUNCTION__);
    [_kippt loginWithUsername:username password:password success:^(id response) {
        
        [_kippt searchByKeyword:@"Kippt" withFilters:LHSKipptListFilter success:^(NSDictionary *clips) {
            [self notify:XCTAsyncTestCaseStatusSucceeded];
        } failure:^(NSError *error) {
            [self notify:XCTAsyncTestCaseStatusFailed];
        }];
         
        
    } failure:^(NSError *error) {
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForStatus: XCTAsyncTestCaseStatusSucceeded timeout:60];
}

-(void) testClipModification {
    
    NSLog(@"Running \"%s\"", __PRETTY_FUNCTION__);
    [_kippt loginWithUsername:username password:password success:^(id response) {
        
        
        LHSClip *clip = [LHSClip clipWithId:testClipId];
        clip.title = @"Working Title!";
        clip.notes = @"My notes are stored here!";
        clip.url = [NSURL URLWithString:@"www.yahoo.com"];
        
        [_kippt modifyClip:clip success:^(NSDictionary *clip) {
            
                if ([clip[@"notes"] isEqualToString:@"My notes are stored here!"]) {
                    
                     [self notify:XCTAsyncTestCaseStatusSucceeded];
                }
                else
                {
                    [self notify:XCTAsyncTestCaseStatusFailed];
                }
            }
             failure:^(NSError *error) {
                 [self notify:XCTAsyncTestCaseStatusFailed];
            }];
    
    } failure:^(NSError *error) {
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForStatus: XCTAsyncTestCaseStatusSucceeded timeout:60];
}

-(void) testCreateNewClip {
    
    NSLog(@"Running \"%s\"", __PRETTY_FUNCTION__);
    [_kippt loginWithUsername:username password:password success:^(id response) {
        
        
        LHSClip *clip = [LHSClip clipWithTitle:@"Working Title!" andNotes:@"My notes are stored here!"];
        clip.url = [NSURL URLWithString:@"www.google.com"];
        
            [_kippt createNewClip:clip success:^(id response) {
                [self notify:XCTAsyncTestCaseStatusSucceeded];
            }
           failure:^(NSError *error) {
               [self notify:XCTAsyncTestCaseStatusFailed];
           }];
        
    } failure:^(NSError *error) {
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForStatus: XCTAsyncTestCaseStatusSucceeded timeout:60];
}

-(void) testFavoriteAClip {
    
    NSLog(@"Running \"%s\"", __PRETTY_FUNCTION__);
    [_kippt loginWithUsername:username password:password success:^(id response) {
        
       [_kippt favoriteAClip:testClipId success:^(id response) {
           
           if ([[response objectForKey:@"is_favorite"] boolValue]) {
              [self notify:XCTAsyncTestCaseStatusSucceeded];
           }
           else {
               [self notify:XCTAsyncTestCaseStatusFailed];
           }
           
       } failure:^(NSError *error) {
           [self notify:XCTAsyncTestCaseStatusFailed];
       }];
        
    } failure:^(NSError *error) {
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForStatus: XCTAsyncTestCaseStatusSucceeded timeout:60];
}

-(void) testDeleteClip {
    
    NSLog(@"Running \"%s\"", __PRETTY_FUNCTION__);
    [_kippt loginWithUsername:username password:password success:^(id response) {
        
        __block NSInteger clipId;
        
        //Ok, let's create a new clip, get its clipid, and then delete it.
        LHSClip *clip = [LHSClip clipWithTitle:@"Working Title!" andNotes:@"My notes are stored here!"];
        clip.url = [NSURL URLWithString:@"www.google.com"];
        
        [_kippt createNewClip:clip success:^(id response) {
            
            clipId = [response[@"id"] integerValue];
            
            [_kippt deleteClip:clipId success:^{
                [self notify:XCTAsyncTestCaseStatusSucceeded];
                
            } failure:^(NSError *error) {
                [self notify:XCTAsyncTestCaseStatusFailed];
            }];
        }
          failure:^(NSError *error) {
              [self notify:XCTAsyncTestCaseStatusFailed];
          }];
        
        
    } failure:^(NSError *error) {
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForStatus: XCTAsyncTestCaseStatusSucceeded timeout:90];
    
}

@end
