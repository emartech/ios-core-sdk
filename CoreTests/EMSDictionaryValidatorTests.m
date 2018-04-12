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

            beforeEach(^{
                emptyDictionary = @{};
            });

            it(@"should return true if no validation rules are set", ^{
                BOOL validationPassed = [emptyDictionary validate:^(EMSDictionaryValidator *validate) {
                }];

                [[theValue(validationPassed) should] beTrue];
            });

            context(@"keyExist", ^{
                it(@"should fail validation when there is no such key in the dictionary", ^{
                    BOOL validationPassed = [emptyDictionary validate:^(EMSDictionaryValidator *validate) {
                        [validate keyExist:@"someKey"];
                    }];

                    [[theValue(validationPassed) should] beFalse];
                });

                it(@"should pass validation when called with nil parameter", ^{
                    BOOL validationPassed = [emptyDictionary validate:^(EMSDictionaryValidator *validate) {
                        [validate keyExist:nil];
                    }];

                    [[theValue(validationPassed) should] beTrue];
                });

                it(@"should pass validation when there is such key in the dictionary", ^{
                    NSDictionary *dictionary = @{@"someKey": @"someValue"};
                    BOOL validationPassed = [dictionary validate:^(EMSDictionaryValidator *validate) {
                        [validate keyExist:@"someKey"];
                    }];

                    [[theValue(validationPassed) should] beTrue];
                });
            });

        });


SPEC_END
