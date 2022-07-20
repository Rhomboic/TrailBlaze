//
//  FriendRequest.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/13/22.
//

#import "FriendRequest.h"

@implementation FriendRequest

@dynamic receiver;
@dynamic requester;

+ (nonnull NSString *)parseClassName {
    return @"FriendRequest";
}

+ (void) uploadRequest: (NSString*)requesterID receiverID: (NSString *)receiverID withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    FriendRequest *newReq = [FriendRequest new];
    [newReq setReceiver:receiverID];
    [newReq setRequester:requesterID];
    [newReq saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"Successfully sent friend request!");
        }
    }];
}

@end
