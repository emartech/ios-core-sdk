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

- (void)keyExists:(id)key withType:(Class)type {
    if (key) {
        id value = self.dictionary[key];
        BOOL containsKey = value != nil;
        BOOL typeMatches = YES;
        if(type) {
            typeMatches = [value isKindOfClass:type];
        }
        self.passedValidation = containsKey && typeMatches;
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