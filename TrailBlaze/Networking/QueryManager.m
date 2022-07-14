//
//  QueryManager.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/13/22.
//

#import "QueryManager.h"
@import Parse;

@implementation QueryManager

- (instancetype)init {
    return self;
}

- (void)queryMates: (NSInteger *) limit completion:(void (^)(NSArray *mates, NSError *))completion {
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

- (void)queryUsers: (NSInteger *) limit completion:(void (^)(NSArray *mates, NSError *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query includeKey:@"objectId"];
    [query orderByDescending:@"createdAt"];
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

- (void)queryRequests: (NSInteger *) limit completion:(void (^)(NSArray *friendRequests, NSError *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query orderByDescending:@"createdAt"];
    [[PFUser currentUser] fetchIfNeeded];
    [query whereKey:@"requester" equalTo:PFUser.currentUser.objectId];
    
//    [query includeKey:@"receiver"];
    

    query.limit = limit;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friendRequests, NSError *error) {
        if (friendRequests) {
            completion(friendRequests, nil);
//            NSLog(@"💃🏼💃🏼💃🏼💃🏼💃🏼💃🏼💃🏼%@", friendRequests);
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

@end
