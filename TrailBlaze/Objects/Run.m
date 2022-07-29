//
//  Run.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/12/22.
//

#import "Run.h"
@import Parse;
@import MapKit;
#import "Utils.h"


@implementation Run
@dynamic runID;
@dynamic user;
@dynamic startTime;
@dynamic endTime;
@dynamic polylineCoords;
@dynamic distance;


+ (nonnull NSString *)parseClassName {
    return @"Run";
}

+ (void) uploadRun: (MKRoute *) route withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Run *newRun = [Run new];
    
    newRun.user = [PFUser currentUser];
    newRun.startTime = [Utils currentDateTime];
    
    
    newRun.polylineCoords = [Utils arrayToJSONString:route.polyline];
    newRun.distance =  [NSString stringWithFormat:@"%.2lf", route.distance];
    NSLog(@"%@", newRun.distance);

    [newRun saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
    if (succeeded) {
        NSLog(@"Save run successfully!");
    } else {
        NSLog(@"%@", error.localizedDescription);    }
  }];

}

+ (void) retreiveRunPolyline : (PFUser *) runner completion:(void (^)(MKPolyline *polyline, NSError * _Nullable))completion {
    [runner fetchIfNeeded];
    PFQuery *query = [PFQuery queryWithClassName:@"Run"];
    [query whereKey:@"user" equalTo:runner];
      [query orderByDescending:@"createdAt"];
      query.limit = 1;
      [query findObjectsInBackgroundWithBlock:^(NSArray *runs, NSError *error) {
          if (runs) {
            NSDictionary *thisUserRun = [runs firstObject];
            NSLog(@"%@", thisUserRun);
            NSData *data = [thisUserRun[@"polylineCoords"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSArray *pointsPairs = json[@"points"];
            CLLocationCoordinate2D *CLLocations = malloc(pointsPairs.count * sizeof(CLLocationCoordinate2D));
            NSLog(@"%@", pointsPairs);
            for (int i = 0; i < pointsPairs.count; i++) {
                CLLocations[i] = CLLocationCoordinate2DMake([pointsPairs[i][0] doubleValue] , [pointsPairs[i][1] doubleValue]);
            }
              MKPolyline *thisUserRunPolyline = [MKPolyline polylineWithCoordinates:CLLocations count:pointsPairs.count];
              completion(thisUserRunPolyline, nil);
          } else {
              NSLog(@"Could not retrieve run");
          }
      }];
}

+ (void) retreiveRunObject : (PFUser *) runner completion:(void (^)(PFObject *runObject, NSError * _Nullable))completion {
    [runner fetchIfNeeded];
    PFQuery *query = [PFQuery queryWithClassName:@"Run"];
    [query whereKey:@"user" equalTo:runner];
      [query orderByDescending:@"createdAt"];
      query.limit = 1;
      [query findObjectsInBackgroundWithBlock:^(NSArray *runs, NSError *error) {
          if (runs) {
              PFObject *thisUserRunObject = [runs firstObject];
              completion(thisUserRunObject, nil);
          } else {
              NSLog(@"Could not retrieve run");
          }
      }];
}

+ (void) retreiveRunPoints : (PFUser *) runner completion:(void (^)(NSArray *runObjectPoints, NSError * _Nullable))completion {
    [runner fetchIfNeeded];
    PFQuery *query = [PFQuery queryWithClassName:@"Run"];
    [query whereKey:@"user" equalTo:runner];
      [query orderByDescending:@"createdAt"];
      query.limit = 1;
      [query findObjectsInBackgroundWithBlock:^(NSArray *runs, NSError *error) {
          if (runs) {
              PFObject *thisUserRunObject = [runs firstObject];
              NSLog(@"%@", thisUserRunObject);
              NSData *data = [thisUserRunObject[@"polylineCoords"] dataUsingEncoding:NSUTF8StringEncoding];
              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
              NSArray *pointsPairs = json[@"points"];
              completion(pointsPairs, nil);
          } else {
              NSLog(@"Could not retrieve run");
          }
      }];
}

+ (void) retreiveRunObjects : (PFUser *) runner limit: (int) limit completion:(void (^)(NSArray *runObjects, NSError * _Nullable))completion {
    [runner fetchIfNeeded];
    PFQuery *query = [PFQuery queryWithClassName:@"Run"];
    [query whereKey:@"user" equalTo:runner];
      [query orderByDescending:@"createdAt"];
      query.limit = limit;
      [query findObjectsInBackgroundWithBlock:^(NSArray *runs, NSError *error) {
          if (runs) {
              completion(runs, nil);
          } else {
              NSLog(@"Could not retrieve run");
          }
      }];
}

@end
