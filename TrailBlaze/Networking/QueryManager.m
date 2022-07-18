//
//  QueryManager.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/13/22.
//

#import "QueryManager.h"
#import "MapKit/MapKit.h"
@import Parse;

@implementation QueryManager

- (instancetype)init {
    return self;
}

- (void)queryMates: (NSInteger ) limit completion:(void (^)(NSArray *mates, NSError *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query orderByDescending:@"createdAt"];
    [[PFUser currentUser] fetchIfNeeded];
    [query whereKey:@"objectId" containedIn:[PFUser currentUser][@"friends"]];

        query.limit = limit;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends) {
            completion(friends, nil);
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)queryUsers: (NSInteger ) limit completion:(void (^)(NSArray *users, NSError *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query includeKey:@"objectId"];
    [query orderByAscending:@"username"];
    [[PFUser currentUser] fetchIfNeeded];
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];

        query.limit = limit;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends) {
            completion(friends, nil);
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)queryRequests: (NSInteger ) limit completion:(void (^)(NSArray *friendRequests, NSError *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query orderByDescending:@"createdAt"];
    [[PFUser currentUser] fetchIfNeeded];
    [query whereKey:@"requester" equalTo:PFUser.currentUser.objectId];

    query.limit = limit;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friendRequests, NSError *error) {
        if (friendRequests) {
            completion(friendRequests, nil);
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)queryReceives: (NSInteger ) limit completion:(void (^)(NSArray *friendReceives, NSError *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query orderByDescending:@"createdAt"];
    [[PFUser currentUser] fetchIfNeeded];
    [query whereKey:@"receiver" equalTo:PFUser.currentUser.objectId];


    query.limit = limit;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friendReceives, NSError *error) {
        if (friendReceives) {
            completion(friendReceives, nil);
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) uploadProfileImage:  ( PFFileObject * _Nullable )image withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    [[PFUser currentUser] setObject:image forKey:@"profileImage"];
    [[PFUser currentUser] saveInBackground];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        return nil;
    }

    return [PFFileObject fileObjectWithName:@"ProfileImage.png" data:imageData];
}


@end
