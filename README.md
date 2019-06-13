# Navajo

**Password Validator & Strength Evaluator**

> This library is no longer maintained.
> Use [Password Autofill Rules](https://developer.apple.com/documentation/security/password_autofill/customizing_password_autofill_rules)
> in iOS 12, macOS Mojave, and Safari
> to generate strong random passwords
> according to your own validation criteria.

![Navajo](https://raw.github.com/mattt/Navajo/screenshots/example.gif)

> Navajo is named in honor of the famed [code talkers of the Second World War](http://en.wikipedia.org/wiki/Code_talker#Navajo_code_talkers).

## Usage

### Validating Password

```objective-c
NSString *password = @"abc123"
NJOPasswordValidator *validator = [NJOPasswordValidator standardValidator];

NSArray *failingRules = nil;
BOOL isValid = [validator validatePassword:password
                              failingRules:&failingRules];

if (!isValid) {
    for (id <NJOPasswordRule> rule in failingRules) {
        NSLog(@"- %@", [rule localizedErrorDescription]);
    }
}
```

#### Available Validation Rules

- Allowed Characters
- Required Characters (e.g. lowercase, uppercase, decimal, symbol)
- Non-Dictionary Word
- Minimum / Maximum Length
- Predicate Match
- Regular Expression Match
- Block Evaluation

### Evaluating Password Strength

> Password strength is evaluated in terms of [information entropy](http://en.wikipedia.org/wiki/Entropy_%28information_theory%29).

```objective-c
NJOPasswordStrength strength = [NJOPasswordStrengthEvaluator strengthOfPassword:password];
NSLog(@"%@", [NJOPasswordStrengthEvaluator localizedStringForPasswordStrength:strength]);
```

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))
