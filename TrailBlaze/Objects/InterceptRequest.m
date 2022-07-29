//
//  InterceptRequest.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/26/22.
//

#import "InterceptRequest.h"

@implementation InterceptRequest
@dynamic receiver;
@dynamic requester;
@dynamic approved;

+ (nonnull NSString *)parseClassName {
    return @"InterceptRequest";
}

+ (void) uploadRequest: (NSString*)requesterID receiverID: (NSString *)receiverID withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    InterceptRequest *newReq = [InterceptRequest new];
    [newReq setReceiver:receiverID];
    [newReq setRequester:requesterID];
    [newReq saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"Successfully sent intercept request!");
        }
    }];
}
@end
