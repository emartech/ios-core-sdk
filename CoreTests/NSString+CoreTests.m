//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "NSString+EMSCore.h"

SPEC_BEGIN(NSStringCoreTests)

    describe(@"NSString+CoreTests createBasicAuthWith:(NSString *)username password:(NSString *)password", ^{

        it(@"should throw exception when username is nil", ^{
            @try {
                [NSString createBasicAuthWith:nil
                                     password:@"pass"];
                fail(@"Expected exception when username is nil");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw exception when password is nil", ^{
            @try {
                [NSString createBasicAuthWith:@"valami"
                                     password:nil];
                fail(@"Expected exception when password is nil");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should create the correct basicAuth when username and password set", ^{
            NSString *basicAuth1 = [NSString createBasicAuthWith:@"user"
                                                        password:@"pass"];
            [[basicAuth1 should] equal:@"Basic dXNlcjpwYXNz"];

            NSString *basicAuth2 = [NSString createBasicAuthWith:@"user2"
                                                        password:@"pass2"];
            [[basicAuth2 should] equal:@"Basic dXNlcjI6cGFzczI="];
        });

    });

SPEC_END
