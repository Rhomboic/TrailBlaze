//
//  ProfileViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/1/22.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"
#import "RunCell.h"
#import "QueryManager.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ProfileViewController {
    NSArray *pastRuns;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PFUser currentUser][@"pastRuns"] fetchIfNeeded];
    pastRuns = [PFUser currentUser][@"pastRuns"];
    _profileName.text = PFUser.currentUser.username;
    PFFileObject *image = [PFUser.currentUser objectForKey:@"profileImage"];
    NSLog(@"%@",image.url);
    [_profileImage setImageWithURL:[NSURL URLWithString:[image url]]];
    
    _profileImage.layer.cornerRadius = 50;
    _profileImage.clipsToBounds = true;
    
}
- (IBAction)didTapLogout:(id)sender {
    SceneDelegate *sceneDelegate = (SceneDelegate *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {

    }];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    sceneDelegate.window.rootViewController = loginViewController;
}
- (IBAction)didTapProfileImage:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    [self.profileImage setImage: originalImage];
    [[[QueryManager alloc] init] uploadProfileImage:[QueryManager getPFFileFromImage:originalImage] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Updated user profile image");
            } else {
                NSLog(@"Unable to update profile image");
            }
    }];
    
   
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RunCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MateCell" forIndexPath:indexPath];
    
    cell.layer.cornerRadius = 20;
    [cell.layer setBorderColor:[UIColor systemBackgroundColor].CGColor];
    [cell.layer setBorderWidth:5.0f];
    cell.clipsToBounds = true;
    cell.contentView.backgroundColor = UIColor.secondarySystemBackgroundColor;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pastRuns.count;
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
