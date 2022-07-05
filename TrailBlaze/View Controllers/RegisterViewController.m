//
//  RegisterViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 6/30/22.
//

#import "RegisterViewController.h"
#import "Parse/Parse.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property UIAlertController *alert;


@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _usernameField.delegate = self;
    _emailField.delegate = self;
    _passwordField.delegate = self;
    
    self.alert = [UIAlertController alertControllerWithTitle:@"Empty Fields" message:@"Please fill all fields" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [self.alert addAction:okAction];
}
- (IBAction)didTapSignup:(id)sender {
    if ([_usernameField.text isEqual:@""] || [_passwordField.text isEqual:@""] || [_emailField.text isEqual:@""]) {
        [self presentViewController:self.alert animated:YES completion:^{}];
    } else {
        [self registerUser];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self didTapSignup:_signupButton];
    return YES;
}

- (void)registerUser {
    PFUser *newUser = [PFUser user];
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser.email = self.emailField.text;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
        }
    }];
}

@end
