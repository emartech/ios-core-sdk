//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMSDictionaryValidator : NSObject

@property(nonatomic, readonly) NSDictionary *dictionary;
@property(nonatomic, readonly) BOOL passedValidation;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)keyExist:(NSString *)string;

@end


typedef void (^ValidatorBlock)(EMSDictionaryValidator *validate);

@interface NSDictionary (Validator)

- (BOOL)validate:(ValidatorBlock)validator;

@end
