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

#ifdef NS_CLOSED_ENUM
#define NJO_CLOSED_ENUM NS_CLOSED_ENUM
#else
#define NJO_CLOSED_ENUM NS_ENUM
#endif

#if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
# define NJO_FINAL __attribute__((objc_subclassing_restricted))
#else
# define NJO_FINAL
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Calculates the approximate information entropy for a string
 using Shannon's entropy equation.

 - Parameter string: The string.
 - Returns: The average minimum number of bits
            needed to encode a string of symbols,
            based on the frequency of those symbols.
 */
extern CGFloat NJOEntropyForString(NSString *string) NS_SWIFT_NAME(entropy(for:));

/**
 Password strength levels.
 */
typedef NJO_CLOSED_ENUM(NSUInteger, NJOPasswordStrength) {
    /// A very weak password (H < 28 bits)
    NJOVeryWeakPasswordStrength NS_SWIFT_NAME(veryWeak),

    /// A weak password (H = 28 – 35 bits)
    NJOWeakPasswordStrength NS_SWIFT_NAME(weak),

    /// A reasonably strong password (H = 36 – 59 bits)
    NJOReasonablePasswordStrength NS_SWIFT_NAME(reasonable),

    /// A strong password (H = 60 – 127 bits)
    NJOStrongPasswordStrength NS_SWIFT_NAME(strong),

    /// A very strong password (H ≥ 128 bits)
    NJOVeryStrongPasswordStrength NS_SWIFT_NAME(veryStrong),
} NS_SWIFT_NAME(PasswordStrength);

/**
 An evaluator of password strength.
 */
NJO_FINAL
NS_SWIFT_NAME(PasswordStrengthEvaluator)
@interface NJOPasswordStrengthEvaluator : NSObject

/**
 Returns the strength of a password.

 - Parameter password: The password to evaluate.
 */
+ (NJOPasswordStrength)strengthOfPassword:(NSString *)password NS_SWIFT_NAME(strength(ofPassword:));

/**
 Returns a localized string describing a password strength level.

 - Parameter level: The strength level.
 */
+ (NSString *)localizedStringForPasswordStrength:(NJOPasswordStrength)level;

@end

#pragma mark -

/**
 A password rule.
 */
NS_SWIFT_NAME(PasswordRule)
@protocol NJOPasswordRule <NSObject>

/**
 Evaluates the rule against a string.

 - Parameter string: The string to evaluate.
 */
- (BOOL)evaluateWithString:(NSString *)string;

/**
 A localized string describing why a string failed evaluation.
 */
@property (readonly, nonatomic) NSString *localizedErrorDescription;

@end

#pragma mark -

/**
 A password rule that allows certain characters.
 */
NJO_FINAL
NS_SWIFT_NAME(AllowedCharacterRule)
@interface NJOAllowedCharacterRule : NSObject <NJOPasswordRule>

/**
 Creates a rule allowing the specified characters.

 - Parameter characterSet: The allowed characters.
 */
+ (instancetype)ruleWithAllowedCharacters:(NSCharacterSet *)characterSet;

@end

/**
 A password rule that requires certain characters.
 */
NJO_FINAL
NS_SWIFT_NAME(RequiredCharacterRule)
@interface NJORequiredCharacterRule : NSObject <NJOPasswordRule>

/**
 Creates a password rule requiring the specified characters.

 - Parameter characterSet: The required characters.
 */
+ (instancetype)ruleWithRequiredCharacters:(NSCharacterSet *)characterSet;

///

/**
 A password rule requiring at least one lowercase character.
 */
@property (class, readonly, nonatomic) NJORequiredCharacterRule* lowercaseCharacterRequiredRule;

/**
 A password rule requiring at least one uppercase character.
 */
@property (class, readonly, nonatomic) NJORequiredCharacterRule* uppercaseCharacterRequiredRule;

/**
 A password rule requiring at least one decimal digit character.
 */
@property (class, readonly, nonatomic) NJORequiredCharacterRule* decimalDigitCharacterRequiredRule;

/**
 A password rule requiring at least one symbol character.
 */
@property (class, readonly, nonatomic) NJORequiredCharacterRule* symbolCharacterRequiredRule;

@end

#pragma mark -

/**
 A password rule that disallows certain words.
 */
NJO_FINAL
NS_SWIFT_NAME(DictionaryWordRule)
@interface NJODictionaryWordRule : NSObject <NJOPasswordRule>

/**
 Creates a password rule that disallows words found in a standard English dictionary.
 */
+ (instancetype)rule;

@end

#pragma mark -

/**
 A password rule that requires a certain number of characters.
 */
NJO_FINAL
NS_SWIFT_NAME(LengthRule)
@interface NJOLengthRule : NSObject <NJOPasswordRule>

/**
 Creates a password rule that requires the number of characters
 contained within the specified range.

 - Parameter range: The range of acceptable password lengths.
 */
+ (instancetype)ruleWithRange:(NSRange)range;

@end

#pragma mark -

/**
 A password rule that evaluates a predicate.
 */
NJO_FINAL
NS_SWIFT_NAME(PredicateRule)
@interface NJOPredicateRule : NSObject <NJOPasswordRule>

/**
 Creates a password rule that evaluates the specified predicate.

 - Parameter predicate: The predicate to evaluate.
*/
+ (instancetype)ruleWithPredicate:(NSPredicate *)predicate;

@end

#pragma mark -

/**
 A password rule that evaluates a regular expression.
 */
NJO_FINAL
NS_SWIFT_NAME(RegularExpressionRule)
@interface NJORegularExpressionRule : NSObject <NJOPasswordRule>

/**
 Creates a password rule that evaluates the specified regular expression.

 - Parameter regularExpression: The regular expression to evaluate.
 */
+ (instancetype)ruleWithRegularExpression:(NSRegularExpression *)regularExpression;

@end

#pragma mark -

/**
 A password rule that evaluates a block.
 */
NJO_FINAL
NS_SWIFT_NAME(BlockRule)
@interface NJOBlockRule : NSObject <NJOPasswordRule>

/**
 Creates a password rule that evaluates the specified block.

 - Parameter block: The block used for evaluation.
 */
+ (instancetype)ruleWithBlock:(BOOL (^)(NSString *password))block;

@end


#pragma mark -

/**
 A validator for password rules.
 */
NJO_FINAL
NS_SWIFT_NAME(PasswordValidator)
@interface NJOPasswordValidator : NSObject

/**
 The standard password validator.

 This validator comprises a single rule
 for passwords to have a length between 6 and 64 characters.
 */
@property (class, readonly, nonatomic) NJOPasswordValidator *standardValidator NS_SWIFT_NAME(standard);

/**
 Creates a validator with the specified rules.

 - Parameter rules: The password rules to validate.
 */
+ (instancetype)validatorWithRules:(NSArray<id<NJOPasswordRule>> *)rules;

/**
 Validates a password against the current rules.

 - Parameters:
    - password: The password to validate.
    - failingRules: A pointer for failing rules
                    returned by reference if the password doesn't validate.
 - Returns: Whether the password is valid.
 */
- (BOOL)validatePassword:(NSString *)password
            failingRules:(out NSArray<id<NJOPasswordRule>> * _Nonnull __autoreleasing *_Nullable)rules;
@end

NS_ASSUME_NONNULL_END

