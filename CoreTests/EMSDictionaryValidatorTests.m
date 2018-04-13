//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDictionaryValidator.h"

SPEC_BEGIN(EMSDictionaryValidatorTests)

        describe(@"initWithDictionary:", ^{

            it(@"should set the parameter", ^{
                id dictMock = [NSDictionary mock];
                EMSDictionaryValidator *validator = [[EMSDictionaryValidator alloc] initWithDictionary:dictMock];
                [[validator.dictionary should] equal:dictMock];
            });


            it(@"validate category method on NSDictionary should create a validate:: with the correct dictionary", ^{
                NSDictionary *dict = @{};

                [dict validate:^(EMSDictionaryValidator *validate) {
                    [[validate.dictionary should] equal:dict];
                }];
            });

        });

        describe(@"validate", ^{

            __block NSDictionary *emptyDictionary;
            __block NSDictionary *dictionary;

            beforeEach(^{
                emptyDictionary = @{};
                dictionary = @{@"someKey": @"someValue"};
            });

            it(@"should return true if no validation rules are set", ^{
                BOOL validationPassed = [emptyDictionary validate:^(EMSDictionaryValidator *validate) {
                }];

                [[theValue(validationPassed) should] beTrue];
            });

            context(@"keyExists:withType:", ^{
                it(@"should fail validation when there is no such key in the dictionary", ^{
                    BOOL validationPassed = [emptyDictionary validate:^(EMSDictionaryValidator *validate) {
                        [validate keyExists:@"someKey" withType:[NSString class]];
                    }];

                    [[theValue(validationPassed) should] beFalse];
                });

                it(@"should pass validation when called with nil key parameter", ^{
                    BOOL validationPassed = [emptyDictionary validate:^(EMSDictionaryValidator *validate) {
                        [validate keyExists:nil withType:[NSString class]];
                    }];

                    [[theValue(validationPassed) should] beTrue];
                });

                it(@"should pass validation when called with nil type parameter", ^{
                    BOOL validationPassed = [dictionary validate:^(EMSDictionaryValidator *validate) {
                        [validate keyExists:@"someKey" withType:nil];
                    }];

                    [[theValue(validationPassed) should] beTrue];
                });

                it(@"should pass validation when there is such key in the dictionary", ^{
                    BOOL validationPassed = [dictionary validate:^(EMSDictionaryValidator *validate) {
                        [validate keyExists:@"someKey" withType:[NSString class]];
                    }];

                    [[theValue(validationPassed) should] beTrue];
                });

                it(@"should pass validation when there is such key in the dictionary with different type", ^{
                    BOOL validationPassed = [dictionary validate:^(EMSDictionaryValidator *validate) {
                        [validate keyExists:@"someKey" withType:[NSArray class]];
                    }];

                    [[theValue(validationPassed) should] beFalse];
                });
            });

        });


SPEC_END
