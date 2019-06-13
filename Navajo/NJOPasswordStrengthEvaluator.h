// NJOPasswordStrengthEvaluator.h
// 
// Copyright (c) 2014 Mattt Thompson
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

@import Foundation;
@import CoreGraphics;
@import Darwin.Availability;

/**
 
 */
typedef NS_ENUM(NSUInteger, NJOPasswordStrength) {
    NJOVeryWeakPasswordStrength,
    NJOWeakPasswordStrength,
    NJOReasonablePasswordStrength,
    NJOStrongPasswordStrength,
    NJOVeryStrongPasswordStrength,
};

/**
 
 */
@interface NJOPasswordStrengthEvaluator : NSObject

/**
 
 */
+ (NJOPasswordStrength)strengthOfPassword:(NSString *)password;

/**
 
 */
+ (NSString *)localizedStringForPasswordStrength:(NJOPasswordStrength)strength;

@end

#pragma mark -

/**
 
 */
@interface NJOPasswordValidator : NSObject

/**
 
 */
+ (instancetype)standardValidator;

/**
 
 */
+ (instancetype)validatorWithRules:(NSArray *)rules;

/**
 
 */
- (BOOL)validatePassword:(NSString *)password
            failingRules:(out NSArray * __autoreleasing *)rules;
@end

#pragma mark -

/**
 
 */
@protocol NJOPasswordRule <NSObject>

/**
 
 */
- (BOOL)evaluateWithString:(NSString *)string;

/**
 
 */
- (NSString *)localizedErrorDescription;

@end

#pragma mark -

/**
 
 */
@interface NJOAllowedCharacterRule : NSObject <NJOPasswordRule>

/**
 
 */
+ (instancetype)ruleWithAllowedCharacters:(NSCharacterSet *)characterSet;

@end

/**
 
 */
@interface NJORequiredCharacterRule : NSObject <NJOPasswordRule>

/**
 
 */
+ (instancetype)ruleWithRequiredCharacters:(NSCharacterSet *)characterSet;

///

/**
 
 */
+ (instancetype)lowercaseCharacterRequiredRule;

/**
 
 */
+ (instancetype)uppercaseCharacterRequiredRule;

/**
 
 */
+ (instancetype)decimalDigitCharacterRequiredRule;

/**
 
 */
+ (instancetype)symbolCharacterRequiredRule;

@end

#pragma mark -

/**
 
 */
@interface NJODictionaryWordRule : NSObject <NJOPasswordRule>

/**
 
 */
+ (instancetype)rule;

@end

#pragma mark -

/**
 
 */
@interface NJOLengthRule : NSObject <NJOPasswordRule>

/**
 
 */
+ (instancetype)ruleWithRange:(NSRange)range;

@end

#pragma mark -

/**
 
 */
@interface NJOPredicateRule : NSObject <NJOPasswordRule>

+ (instancetype)ruleWithPredicate:(NSPredicate *)predicate;

@end

#pragma mark -

/**
 
 */
@interface NJORegularExpressionRule : NSObject <NJOPasswordRule>

+ (instancetype)ruleWithRegularExpression:(NSRegularExpression *)regularExpression;

@end

#pragma mark -

/**

 */
@interface NJOBlockRule : NSObject <NJOPasswordRule>

+ (instancetype)ruleWithBlock:(BOOL (^)(NSString *password))block;

@end

///

/**
 
 */
extern CGFloat NJOEntropyForString(NSString *string);
