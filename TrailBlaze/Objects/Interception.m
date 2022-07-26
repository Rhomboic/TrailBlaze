//
//  Interception.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/26/22.
//

#import "Interception.h"
@import Parse;

@implementation Interception
@dynamic rendezvous;
@dynamic polylineCoords;
@dynamic startTime;

+ (nonnull NSString *)parseClassName {
    return @"Interception";
}

+ (void) uploadRequest: (PFGeoPoint *) rendezvous polylineCoords: (NSString *)polylineCoords startTime: (NSString *) startTime withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Interception *newReq = [Interception new];
    [newReq setRendezvous:rendezvous];
    [newReq setPolylineCoords:polylineCoords];
    [newReq setStartTime:startTime];

    [newReq saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"Successfully sent intercept request!");
        }
    }];
}
@end
