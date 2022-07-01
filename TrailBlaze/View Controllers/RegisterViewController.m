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
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property UIAlertController *alert;


@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
