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
@dynamic polylineCoords;


+ (nonnull NSString *)parseClassName {
    return @"Run";
}

+ (void) uploadRun: (MKRoute *) route withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Run *newRun = [Run new];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    newRun.user = [PFUser currentUser];
    newRun.startTime = [DateFormatter stringFromDate:[NSDate date]];
    
    NSUInteger pointCount = route.polyline.pointCount;
    CLLocationCoordinate2D *routeCoordinates = malloc(pointCount * sizeof(CLLocationCoordinate2D));
    [route.polyline getCoordinates:routeCoordinates range:NSMakeRange(0, pointCount)];
    NSString *pointsJSON = @"{\"points\" : [";
    for (int c=0; c < pointCount-1; c++) {
        NSString *this = [NSString stringWithFormat:@"[%f, %f],", routeCoordinates[c].latitude, routeCoordinates[c].longitude];
        pointsJSON = [pointsJSON stringByAppendingString:this];
    }
      
    pointsJSON= [pointsJSON stringByAppendingString:[NSString stringWithFormat:@"%@ ] }", [NSString stringWithFormat:@"[%f, %f]", routeCoordinates[pointCount-1].latitude, routeCoordinates[pointCount - 1].longitude]] ];
    free(routeCoordinates);
    newRun.polylineCoords = pointsJSON;

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

@end
