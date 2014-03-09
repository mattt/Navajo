// NJOPasswordStrengthEvaluator.m
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

#import "NJOPasswordStrengthEvaluator.h"

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
@import UIKit;
#else
@import CoreServices;
#endif

CGFloat NJOEntropyForString(NSString *string) {
    if (!string || [string length] == 0) {
        return 0.0f;
    }

    __block BOOL includesLowercaseCharacter = NO, includesUppercaseCharacter = NO, includesDecimalDigitCharacter = NO, includesPunctuationCharacter = NO, includesSymbolCharacter = NO, includesWhitespaceCharacter = NO, includesNonBaseCharacter = NO;
    __block NSUInteger sizeOfCharacterSet = 0;

    NSCountedSet *characterFrequency = [[NSCountedSet alloc] initWithCapacity:[string length]];
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {

        {
            if (!includesLowercaseCharacter && [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[substring characterAtIndex:0]]) {
                includesLowercaseCharacter = YES;
                sizeOfCharacterSet += 26;
                goto next;
            }

            if (!includesUppercaseCharacter && [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[substring characterAtIndex:0]]) {
                includesLowercaseCharacter = YES;
                sizeOfCharacterSet += 26;
                goto next;
            }

            if (!includesDecimalDigitCharacter && [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[substring characterAtIndex:0]]) {
                includesDecimalDigitCharacter = YES;
                sizeOfCharacterSet += 10;
                goto next;
            }

            if (!includesSymbolCharacter && [[NSCharacterSet symbolCharacterSet] characterIsMember:[substring characterAtIndex:0]]) {
                includesSymbolCharacter = YES;
                sizeOfCharacterSet += 10;
                goto next;
            }

            if (!includesPunctuationCharacter && [[NSCharacterSet punctuationCharacterSet] characterIsMember:[substring characterAtIndex:0]]) {
                includesPunctuationCharacter = YES;
                sizeOfCharacterSet += 20;
                goto next;
            }

            if (!includesWhitespaceCharacter && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[substring characterAtIndex:0]]) {
                includesWhitespaceCharacter = YES;
                sizeOfCharacterSet += 1;
                goto next;
            }

            if (!includesNonBaseCharacter && [[NSCharacterSet nonBaseCharacterSet] characterIsMember:[substring characterAtIndex:0]]) {
                includesNonBaseCharacter = YES;
                sizeOfCharacterSet += 32 + 128;
                goto next;
            }
        }
        next: {
            [characterFrequency addObject:substring];
        }
    }];

    CGFloat entropyPerCharacter = log2f(sizeOfCharacterSet);
    
    return entropyPerCharacter * [string length];
}

static inline __attribute__((const)) NJOPasswordStrength NJOPasswordStrengthForEntropy(CGFloat entropy) {
    if (entropy < 28) {
        return NJOVeryWeakPasswordStrength;
    } else if (entropy < 36) {
        return NJOWeakPasswordStrength;
    } else if (entropy < 60) {
        return NJOReasonablePasswordStrength;
    } else if (entropy < 128) {
        return NJOStrongPasswordStrength;
    } else {
        return NJOVeryStrongPasswordStrength;
    }
}

#pragma mark -

@implementation NJOPasswordStrengthEvaluator

+ (NJOPasswordStrength)strengthOfPassword:(NSString *)password {
    return NJOPasswordStrengthForEntropy(NJOEntropyForString(password));
}

+ (NSString *)localizedStringForPasswordStrength:(NJOPasswordStrength)strength {
    switch (strength) {
        case NJOVeryWeakPasswordStrength:
            return NSLocalizedStringFromTable(@"Very Weak Password", @"Navajo", nil);
        case NJOWeakPasswordStrength:
            return NSLocalizedStringFromTable(@"Weak Password", @"Navajo", nil);
        case NJOReasonablePasswordStrength:
            return NSLocalizedStringFromTable(@"Reasonable Password", @"Navajo", nil);
        case NJOStrongPasswordStrength:
            return NSLocalizedStringFromTable(@"Strong Password", @"Navajo", nil);
        case NJOVeryStrongPasswordStrength:
            return NSLocalizedStringFromTable(@"Very Strong Password", @"Navajo", nil);
    }

    return nil;
}

@end

@interface NJOPasswordValidator ()
@property (readwrite, nonatomic, strong) NSArray *rules;
@end

@implementation NJOPasswordValidator

+ (instancetype)standardValidator {
    return [self validatorWithRules:@[[NJOLengthRule ruleWithRange:NSMakeRange(6, 64)], [NJODictionaryWordRule rule]]];
}

+ (instancetype)validatorWithRules:(NSArray *)rules {
    NJOPasswordValidator *validator = [[self alloc] init];
    validator.rules = rules;

    return validator;
}

- (BOOL)validatePassword:(NSString *)password
            failingRules:(out NSArray *__autoreleasing *)rules
{
    NSArray *failingRules = [self.rules filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id <NJOPasswordRule> rule, NSDictionary *bindings) {
        return [rule evaluateWithString:password];
    }]];

    if (rules) {
        *rules = failingRules;
    }

    return [failingRules count] == 0;
}

@end

#pragma mark -

@interface NJOAllowedCharacterRule ()
@property (readwrite, nonatomic, strong) NSCharacterSet *disallowedCharacters;
@end

@implementation NJOAllowedCharacterRule

+ (instancetype)ruleWithAllowedCharacters:(NSCharacterSet *)characterSet {
    NJOAllowedCharacterRule *rule = [[self alloc] init];
    rule.disallowedCharacters = [characterSet invertedSet];

    return rule;
}

#pragma mark - NJOPasswordRule

- (BOOL)evaluateWithString:(NSString *)string {
    return [string rangeOfCharacterFromSet:self.disallowedCharacters].location == NSNotFound;
}

- (NSString *)localizedErrorDescription {
    return NSLocalizedStringFromTable(@"Must not include disallowed character", @"Navajo", nil);
}

@end

#pragma mark -

@interface NJORequiredCharacterRule ()
@property (readwrite, nonatomic, strong) NSCharacterSet *requiredCharacters;
@property (readwrite, nonatomic, copy) NSString *localizedErrorDescription;
@end

@implementation NJORequiredCharacterRule

+ (instancetype)ruleWithRequiredCharacters:(NSCharacterSet *)characterSet {
    NJORequiredCharacterRule *rule = [[self alloc] init];
    rule.requiredCharacters = characterSet;
    rule.localizedErrorDescription = NSLocalizedStringFromTable(@"Must include required characters", @"Navajo", nil);

    return rule;
}

+ (instancetype)lowercaseCharacterRequiredRule {
    NJORequiredCharacterRule *rule = [[self alloc] init];
    rule.requiredCharacters = [NSCharacterSet lowercaseLetterCharacterSet];
    rule.localizedErrorDescription = NSLocalizedStringFromTable(@"Must include lowercase character", @"Navajo", nil);

    return rule;
}

+ (instancetype)uppercaseCharacterRequiredRule {
    NJORequiredCharacterRule *rule = [[self alloc] init];
    rule.requiredCharacters = [NSCharacterSet uppercaseLetterCharacterSet];
    rule.localizedErrorDescription = NSLocalizedStringFromTable(@"Must include uppercase character", @"Navajo", nil);

    return rule;
}

+ (instancetype)decimalDigitCharacterRequiredRule {
    NJORequiredCharacterRule *rule = [[self alloc] init];
    rule.requiredCharacters = [NSCharacterSet decimalDigitCharacterSet];
    rule.localizedErrorDescription = NSLocalizedStringFromTable(@"Must include decimal digit character", @"Navajo", nil);

    return rule;
}

+ (instancetype)symbolCharacterRequiredRule {
    NJORequiredCharacterRule *rule = [[self alloc] init];

    NSMutableCharacterSet *mutableCharacterSet = [[NSMutableCharacterSet alloc] init];
    [mutableCharacterSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
    [mutableCharacterSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    rule.requiredCharacters = mutableCharacterSet;
    rule.localizedErrorDescription = NSLocalizedStringFromTable(@"Must include symbol character", @"Navajo", nil);

    return rule;
}

#pragma mark - NJOPasswordRule

- (BOOL)evaluateWithString:(NSString *)string {
    return [string rangeOfCharacterFromSet:self.requiredCharacters].location == NSNotFound;
}

@end

#pragma mark -

@implementation NJODictionaryWordRule

+ (instancetype)rule {
    return [[self alloc] init];
}

#pragma mark - NJOPasswordRule

- (BOOL)evaluateWithString:(NSString *)string {
    static NSCharacterSet *_nonLowercaseCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _nonLowercaseCharacterSet = [[NSCharacterSet lowercaseLetterCharacterSet] invertedSet];
    });
    
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    return [UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:[[string lowercaseString] stringByTrimmingCharactersInSet:_nonLowercaseCharacterSet]];
#else
    CFRange range = DCSGetTermRangeInString(NULL,(__bridge CFStringRef)[[string lowercaseString] stringByTrimmingCharactersInSet:_nonLowercaseCharacterSet], 0);

    return range.location != kCFNotFound;
#endif
}

- (NSString *)localizedErrorDescription {
    return NSLocalizedStringFromTable(@"Must not be dictionary word", @"Navajo", nil);
}

@end

#pragma mark -

@interface NJOLengthRule ()
@property (readwrite, nonatomic, assign) NSRange range;
@end

@implementation NJOLengthRule

+ (instancetype)ruleWithRange:(NSRange)range {
    NJOLengthRule *rule = [[self alloc] init];
    rule.range = range;

    return rule;
}

#pragma mark - NJOPasswordRule

- (BOOL)evaluateWithString:(NSString *)string {
    return !NSLocationInRange([string length], self.range);
}

- (NSString *)localizedErrorDescription {
    return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Must be within range %@", @"Navajo", nil), NSStringFromRange(self.range)];
}

@end

#pragma mark -

@interface NJOPredicateRule ()
@property (readwrite, nonatomic, strong) NSPredicate *predicate;
@end

@implementation NJOPredicateRule

+ (instancetype)ruleWithPredicate:(NSPredicate *)predicate {
    NJOPredicateRule *rule = [[self alloc] init];
    rule.predicate = predicate;

    return rule;
}

#pragma mark - NJOPasswordRule

- (BOOL)evaluateWithString:(NSString *)string {
    return [self.predicate evaluateWithObject:string];
}

- (NSString *)localizedErrorDescription {
    return NSLocalizedStringFromTable(@"Must match predicate", @"Navajo", nil);
}

@end

#pragma mark -

@interface NJORegularExpressionRule ()
@property (readwrite, nonatomic, strong) NSRegularExpression *regularExpression;
@end

@implementation NJORegularExpressionRule

+ (instancetype)ruleWithRegularExpression:(NSRegularExpression *)regularExpression {
    NJORegularExpressionRule *rule = [[self alloc] init];
    rule.regularExpression = regularExpression;

    return rule;
}

#pragma mark - NJOPasswordRule

- (BOOL)evaluateWithString:(NSString *)string {
    return [self.regularExpression numberOfMatchesInString:string options:(NSMatchingOptions)0 range:NSMakeRange(0, [string length])] > 0;
}

- (NSString *)localizedErrorDescription {
    return NSLocalizedStringFromTable(@"Must match predicate", @"Navajo", nil);
}

@end

#pragma mark -

@interface NJOBlockRule ()
@property (readwrite, nonatomic, copy) BOOL (^evaluation)(NSString *password);
@end

@implementation NJOBlockRule

+ (instancetype)ruleWithBlock:(BOOL (^)(NSString *password))block {
    NJOBlockRule *rule = [[NJOBlockRule alloc] init];
    rule.evaluation = block;

    return rule;
}

#pragma mark - NJOPasswordRule

- (BOOL)evaluateWithString:(NSString *)string {
    if (self.evaluation) {
        return self.evaluation(string);
    }

    return NO;
}

- (NSString *)localizedErrorDescription {
    return NSLocalizedStringFromTable(@"Must satisfy precondition", @"Navajo", nil);
}

@end