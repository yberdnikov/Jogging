//
//  JoggingAppTests.m
//  JoggingAppTests
//
//  Created by Yuriy Berdnikov on 1/26/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "Kiwi.h"
#import <Parse/Parse.h>
#import "JSAConstants.h"

#define TEST_USERNAME @"test_user10"
#define TEST_USER_EMAIL @"test_user10@mail.com"

SPEC_BEGIN(MathSpec)

describe(@"Parse API", ^{
    
    beforeAll(^{
        
        [Parse enableLocalDatastore];
        [Parse setApplicationId:kJSAParseAppID clientKey:kJSAParseClientKey];
        
        [PFUser logOut];
    });
    
    it(@"User should not exist", ^{
        [[[PFUser currentUser] should] beNil];
    });
    
    context(@"User Signup", ^{
        
        afterAll(^{
            [PFUser logOut];
        });
        
        it(@"should singup new user within 10 seconds", ^{
            
            PFUser *user = [PFUser user];
            user[@"name"] = TEST_USERNAME;
            user.username = TEST_USERNAME;
            user.email = TEST_USER_EMAIL;
            user.password = @"123asd";
            
            __block BOOL isSignupSuccess = NO;
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                isSignupSuccess = succeeded;
                
                if (error)
                    fail(@"Unable to singup test user");
            }];
            
            [[expectFutureValue(theValue(isSignupSuccess)) shouldEventuallyBeforeTimingOutAfter(10.0)] beYes];
        });
    });
    
    context(@"User Login", ^{
        
        it(@"should login user within 5 seconds", ^{
            
            __block PFUser *userInfo = nil;
            [PFUser logInWithUsernameInBackground:TEST_USERNAME password:@"123asd" block:^(PFUser *user, NSError *error) {
                
                if (error)
                {
                    fail(@"Unable to login test user");
                    return;
                }
                
                userInfo = user;
            }];
            
            [[expectFutureValue(userInfo) shouldEventuallyBeforeTimingOutAfter(5.0)] beNonNil];
            
            [[expectFutureValue(userInfo.username) shouldEventually] equal:TEST_USERNAME];
            [[expectFutureValue(userInfo.email) shouldEventually] equal:TEST_USER_EMAIL];
        });
    });
    
    context(@"User entries", ^{
        
        __block PFObject *entryToRemove = nil;
        
        it(@"new user should not have entries", ^{
            
            PFQuery *query = [PFQuery queryWithClassName:@"JSAEntry"];
            [query orderBySortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            
            __block NSArray *userEntries = nil;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (error)
                {
                    fail(@"Unable to fetch user entries");
                    return;
                }
                
                userEntries = objects;
            }];
            
            [[expectFutureValue(userEntries) shouldEventuallyBeforeTimingOutAfter(5.0)] beNonNil];
            [[expectFutureValue(theValue(userEntries.count)) shouldEventually] equal:theValue(0)];
        });
        
        it(@"should add 2 entry", ^{
            
            PFObject *entry1 = [PFObject objectWithClassName:@"JSAEntry"];
            entry1[@"date"] = @(1420113600); // Thu, 01 Jan 2015 12:00:00 GMT
            entry1[@"distance"] = @(1); // 1 mile
            entry1[@"time"] = @(3600); // 1 hour
            entry1[@"user"] = [PFUser currentUser];
            
            PFObject *entry2 = [PFObject objectWithClassName:@"JSAEntry"];
            entry2[@"date"] = @(1422792000); // Sun, 01 Feb 2015 12:00:00 GMT
            entry2[@"distance"] = @(1); // 1 mile
            entry2[@"time"] = @(3600); // 1 hour
            entry2[@"user"] = [PFUser currentUser];
            
            __block BOOL isInsertSuccess = NO;
            [PFObject saveAllInBackground:@[entry1, entry2] block:^(BOOL succeeded, NSError *error) {
                isInsertSuccess = succeeded;
                
                if (error)
                {
                    fail(@"Unable to fetch user entries");
                    return;
                }
            }];
            
            [[expectFutureValue(theValue(isInsertSuccess)) shouldEventuallyBeforeTimingOutAfter(10.0)] beYes];
        });
        
        it(@"should receive 2 entries", ^{
            
            PFQuery *query = [PFQuery queryWithClassName:@"JSAEntry"];
            [query orderBySortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            
            __block NSArray *userEntries = nil;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (error)
                {
                    fail(@"Unable to fetch user entries");
                    return;
                }
                
                userEntries = objects;
            }];
            
            [[expectFutureValue(userEntries) shouldEventuallyBeforeTimingOutAfter(5.0)] beNonNil];
            [[expectFutureValue(theValue(userEntries.count)) shouldEventually] equal:theValue(2)];
        });
        
        it(@"should receive 1 entry for period 30.12.2014 - 3.01.2015", ^{
            
            PFQuery *query = [PFQuery queryWithClassName:@"JSAEntry"];
            [query orderBySortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            
            //from Tue, 30 Dec 2014 12:00:00 GMT
            [query whereKey:@"date" greaterThanOrEqualTo:@(1419940800)];
            
            //to Sat, 03 Jan 2015 12:00:00 GMT
            [query whereKey:@"date" lessThanOrEqualTo:@(1420286400)];
            
            __block NSArray *userEntries = nil;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (error)
                {
                    fail(@"Unable to fetch user entries");
                    return;
                }
                
                userEntries = objects;
                entryToRemove = [userEntries lastObject];
            }];
            
            [[expectFutureValue(userEntries) shouldEventuallyBeforeTimingOutAfter(5.0)] beNonNil];
            [[expectFutureValue(theValue(userEntries.count)) shouldEventually] equal:theValue(1)];
        });
        
        it(@"should remove 1 entry", ^{
            
            [[entryToRemove shouldNot] beNil];

            __block BOOL isRemoveSuccess = NO;
            [entryToRemove deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

                isRemoveSuccess = succeeded;
                
                if (error)
                {
                    fail(@"Unable to remove entry");
                    return;
                }
            }];
            
            [[expectFutureValue(theValue(isRemoveSuccess)) shouldEventuallyBeforeTimingOutAfter(10.0)] beYes];
        });
        
        it(@"should receive 1 entry after remove", ^{
            
            PFQuery *query = [PFQuery queryWithClassName:@"JSAEntry"];
            [query orderBySortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            
            __block NSArray *userEntries = nil;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (error)
                {
                    fail(@"Unable to fetch user entries");
                    return;
                }
                
                userEntries = objects;
            }];
            
            [[expectFutureValue(userEntries) shouldEventuallyBeforeTimingOutAfter(5.0)] beNonNil];
            [[expectFutureValue(theValue(userEntries.count)) shouldEventually] equal:theValue(1)];
        });
    });
});

SPEC_END
