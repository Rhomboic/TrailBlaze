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

- (void)queryUsers: (NSInteger ) limit completion:(void (^)(NSArray *mates, NSError *))completion {
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
    
//    [query includeKey:@"receiver"];
    

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

//- (void)friendingQuery: (NSInteger ) limit otherUser :(NSString *) otherUserId completion:(void (^)(NSArray *matches, NSError *))completion {
//    [[PFUser currentUser] fetchIfNeeded];
//    PFQuery *query1 = [PFQuery queryWithClassName:@"FriendRequest"];
//    [query1 whereKey:@"receiver" equalTo:[PFUser currentUser][@"objectId"]];
//    [query1 whereKey:@"requester" equalTo:otherUserId];
//
//    PFQuery *query2 = [PFQuery queryWithClassName:@"FriendRequest"];
//    [query2 whereKey:@"receiver" equalTo:otherUserId];
//    [query2 whereKey:@"requester" equalTo:[PFUser currentUser][@"objectId"]];
//
//    PFQuery *mainQuery = [PFQuery orQueryWithSubqueries:@[query1,query2]];
//    mainQuery.limit = limit;
//    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *matches, NSError *error) {
//        if (matches) {
//            for (PFObject *obj in matches) {
//                [obj deleteInBackground];
//            }
//        } else {
//            NSLog(@"%@", error.localizedDescription);
//        }
//    }];
//}
@end
