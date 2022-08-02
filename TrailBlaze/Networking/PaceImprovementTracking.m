//
//  PaceImprovementTracking.m
//  TrailBlaze
//
//  Created by Adam Issah on 8/1/22.
//

#import "PaceImprovementTracking.h"
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"
#import "CoreMotion/CoreMotion.h"
#import "Run.h"
#import "Utils.h"

@implementation PaceImprovementTracking
/// this wiggle value is to account for the fact that the user it not always going to be running directly on the polyline (see triangle analogy in PIT implementation plan)
static double interpointDistanceWiggleValue = 2;

+ (BOOL) isAtStartPosition: (CLLocation *) userLocation firstPoint: (NSArray *) firstPolylinePoint {
    CLLocation *firstPointLocation = [[CLLocation alloc] initWithLatitude:[firstPolylinePoint[0] doubleValue] longitude:[firstPolylinePoint[1] doubleValue]];
    if ([firstPointLocation distanceFromLocation:userLocation] < 10) {
        return true;
    }
    return false;
}

- (instancetype)initWithRunID: (NSString *) objectId {
    self.pedometer = [[CMPedometer alloc] init];
    self.currentPacesArray = [NSMutableArray new];
    
    [Run retreiveSpecificRunObject:objectId completion:^(PFObject * _Nonnull runObject, NSError * _Nullable err) {
        if (runObject) {
            self.bestPacesArray = runObject[@"pacesArray"];
            self.polylinePoints = [Utils jsonStringToArray:runObject[@"polylineCoords"]];
            
        }
    }];
    //find a way to return self in completion block
        return self;
}





- (BOOL) passedPoint: (NSArray *) nextTwoPoints currentLocation: (CLLocation *) currentLocation {
    CLLocation *firstPointLocation = [[CLLocation alloc] initWithLatitude:[nextTwoPoints[0][0] doubleValue] longitude:[nextTwoPoints[0][1] doubleValue]];
    CLLocation *secondPointLocation = [[CLLocation alloc] initWithLatitude:[nextTwoPoints[1][0] doubleValue] longitude:[nextTwoPoints[1][1] doubleValue]];
    double distanceToFirst = [firstPointLocation distanceFromLocation:currentLocation];
    double distanceToSecond = [secondPointLocation distanceFromLocation:currentLocation];
    double distanceBewteen = [firstPointLocation distanceFromLocation:secondPointLocation];
    if (((distanceToFirst + distanceToSecond) - distanceBewteen) <= interpointDistanceWiggleValue ) {
        return true;
    }
    return false;
}

- (NSArray *) paceCompare: (NSNumber *) previousIntervalPace currentIntervalPace: (NSNumber *)currentIntervalPace pointsForInterval: (NSArray *) pointsForInterval {
    CLLocationCoordinate2D *endPoints = malloc(2 * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < 2; i++) {
        endPoints[i] = CLLocationCoordinate2DMake([pointsForInterval[i][0] doubleValue] , [pointsForInterval[i][1] doubleValue]);
    }
      MKPolyline *overlapPolyline = [MKPolyline polylineWithCoordinates:endPoints count:2];
    if (currentIntervalPace >= previousIntervalPace) {
        return @[UIColor.systemGreenColor, overlapPolyline];
    }
    return @[UIColor.systemRedColor, overlapPolyline];
}


@end
