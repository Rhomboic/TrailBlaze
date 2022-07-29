//
//  Interception.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/26/22.
//

#import "Interception.h"
#import "MapKit/Mapkit.h"
@import Parse;
#import "Utils.h"


@implementation Interception
@dynamic rendezvous;
@dynamic polylineCoords;
@dynamic startTime;
@dynamic receiver;

+ (nonnull NSString *)parseClassName {
    return @"Interception";
}

+ (void) uploadRequest: (PFGeoPoint *) rendezvous polyline: (MKPolyline *)polyline receiver: (PFUser *) receiver withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Interception *newReq = [Interception new];
    [newReq setRendezvous:rendezvous];
    
    
    [newReq setPolylineCoords:[Utils arrayToJSONString:polyline]];
    
    
    [newReq setStartTime:[Utils currentDateTime]];
    [newReq setReceiver: receiver.objectId];

    [newReq saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"Successfully sent intercept request!");
        }
    }];
}
@end
