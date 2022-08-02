//
//  PaceImprovementTracking.m
//  TrailBlaze
//
//  Created by Adam Issah on 8/1/22.
//

#import "PaceImprovementTracker.h"
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"
#import "CoreMotion/CoreMotion.h"
#import "Run.h"
#import "Utils.h"

@implementation PaceImprovementTracker
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

 - (void) paceTracker: (NSArray *) polylinePoints userLocation: (CLLocation *) userLocation bestPaces: (NSDictionary *) bestPaces{
    [self.pedometer startPedometerEventUpdatesWithHandler:^(CMPedometerEvent * _Nullable pedometerEvent, NSError * _Nullable error) {
        
    }];
    __block int i = 1;
    __block NSArray *nextPoints = [polylinePoints subarrayWithRange:NSMakeRange(i, 2)];
    __block NSDate *startDate = [NSDate date];
    
    while (![nextPoints[1] isEqual:polylinePoints[-1]]) {
        if ([self passedPoint:nextPoints currentLocation:userLocation]) {
            NSNumber *previousPace = bestPaces[nextPoints[0]] ;
            __block NSNumber *currentPace;
            NSDate *endDate = [NSDate date];
            [self.pedometer queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
                currentPace = pedometerData.averageActivePace;
                
                // make delegate to handle
                [self paceCompare:previousPace currentIntervalPace:currentPace pointsForInterval:@[polylinePoints[i-1], polylinePoints[i]] ];
                i += 1;
                nextPoints = [polylinePoints subarrayWithRange:NSMakeRange(i, 2)];
                startDate = endDate;
            }];
        } 
    }
}
@end
