//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSDictionaryValidator.h"


@interface EMSDictionaryValidator ()
@property(nonatomic, strong) NSDictionary *dictionary;
@property(nonatomic, assign) BOOL passedValidation;
@end

@implementation EMSDictionaryValidator

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _dictionary = dictionary;
        _passedValidation = YES;
    }
    return self;
}

- (void)keyExist:(NSString *)string {
    if (string) {
        self.passedValidation = self.dictionary[string] != nil;
    }
}

@end


@implementation NSDictionary (Validator)

- (BOOL)validate:(ValidatorBlock)validator {
    EMSDictionaryValidator *dictionaryValidator = [[EMSDictionaryValidator alloc] initWithDictionary:self];
    validator(dictionaryValidator);
    return [dictionaryValidator passedValidation];
}


@end