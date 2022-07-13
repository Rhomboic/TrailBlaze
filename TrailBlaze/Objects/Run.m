//
//  Run.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/12/22.
//

#import "Run.h"
@import Parse;
@import MapKit;


@implementation Run
@dynamic runID;
@dynamic user;
@dynamic startTime;
@dynamic endTime;
@dynamic routeObject;


+ (nonnull NSString *)parseClassName {
    return @"Run";
}

+ (void) uploadRun: (MKRoute *) route withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Run *newRun = [Run new];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    newRun.user = [PFUser currentUser];
    newRun.startTime = [DateFormatter stringFromDate:[NSDate date]];
//    NSError *err;@property (nonatomic, strong) NSString *email;
//    NSData *routeJSON = [NSJSONSerialization dataWithJSONObject:route options:NSJSONWritingFragmentsAllowed error:&err];
//    newRun.routeObject = routeJSON;
    
    [newRun saveInBackgroundWithBlock: completion];
}


@end
