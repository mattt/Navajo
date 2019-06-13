# Navajo

**Password Validator & Strength Evaluator**

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
