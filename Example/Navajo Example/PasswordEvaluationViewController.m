// PasswordEvaluationViewController.m
//
// Copyright (c) 2014 – 2019 Mattt (https://mat.tt)
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

#import "PasswordEvaluationViewController.h"

#import "NJOPasswordStrengthEvaluator.h"

typedef NS_ENUM(NSUInteger, PasswordValidatorSegmentIndexes) {
    LenientValidatorSegmentIndex,
    StrictValidatorSegmentIndex,
};

@interface PasswordEvaluationViewController () 
@property (readwrite, nonatomic, strong) NJOPasswordValidator *lenientValidator;
@property (readwrite, nonatomic, strong) NJOPasswordValidator *strictValidator;
@property (readonly, nonatomic) NJOPasswordValidator *validator;
@end

@implementation PasswordEvaluationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }

    self.lenientValidator = [NJOPasswordValidator standardValidator];
    self.strictValidator = [NJOPasswordValidator validatorWithRules:@[[NJOLengthRule ruleWithRange:NSMakeRange(8, 64)], [NJORequiredCharacterRule lowercaseCharacterRequiredRule], [NJORequiredCharacterRule uppercaseCharacterRequiredRule], [NJORequiredCharacterRule symbolCharacterRequiredRule]]];

    return self;
}

- (NJOPasswordValidator *)validator {
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case LenientValidatorSegmentIndex:
            return self.lenientValidator;
        case StrictValidatorSegmentIndex:
            return self.strictValidator;
        default:
            return nil;
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Navajo", nil);

    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:self.passwordTextField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self updatePasswordStrength:note.object];
    }];

    [self updatePasswordStrength:self];
}

#pragma mark - IBAction

- (IBAction)segmentedControlDidChangeValue:(id)sender {
    [self updatePasswordStrength:sender];
}

#pragma mark -

- (void)updatePasswordStrength:(id)sender {
    NSString *password = self.passwordTextField.text;

    if ([password length] == 0) {
        self.validationErrorsTextView.text = nil;
        self.passwordStrengthMeterView.progress = 0.0f;
        self.passwordStrengthLabel.text = nil;
    } else {
        NJOPasswordStrength strength = [NJOPasswordStrengthEvaluator strengthOfPassword:password];

        NSArray *failingRules = nil;
        if ([self.validator validatePassword:password failingRules:&failingRules]) {
            self.passwordStrengthLabel.text = [NJOPasswordStrengthEvaluator localizedStringForPasswordStrength:strength];
            switch (strength) {
                case NJOVeryWeakPasswordStrength:
                    self.passwordStrengthMeterView.progress = 0.05f;
                    self.passwordStrengthMeterView.progressTintColor = [UIColor redColor];
                    break;
                case NJOWeakPasswordStrength:
                    self.passwordStrengthMeterView.progress = 0.25f;
                    self.passwordStrengthMeterView.progressTintColor = [UIColor orangeColor];
                    break;
                case NJOReasonablePasswordStrength:
                    self.passwordStrengthMeterView.progress = 0.5f;
                    self.passwordStrengthMeterView.progressTintColor = [UIColor yellowColor];
                    break;
                case NJOStrongPasswordStrength:
                    self.passwordStrengthMeterView.progress = 0.75f;
                    self.passwordStrengthMeterView.progressTintColor = [UIColor greenColor];
                    break;
                case NJOVeryStrongPasswordStrength:
                    self.passwordStrengthMeterView.progress = 1.0f;
                    self.passwordStrengthMeterView.progressTintColor = [UIColor cyanColor];
                    break;
            }
            
            self.validationErrorsTextView.text = nil;
        } else {
            self.passwordStrengthLabel.text = NSLocalizedString(@"Invalid Password", nil);
            self.passwordStrengthMeterView.progress = 0.0f;
            self.passwordStrengthMeterView.progressTintColor = [UIColor redColor];

            NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
            for (id <NJOPasswordRule> rule in failingRules) {
                [mutableAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"• %@\n", [rule localizedErrorDescription]] attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}]];
            }

            self.validationErrorsTextView.attributedText = mutableAttributedString;
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
