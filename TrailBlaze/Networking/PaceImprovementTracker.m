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

@implementation PaceImprovementTracker {
    CMPedometer  *pedometer;
    NSArray *polylinePoints;
    NSMutableDictionary *currentPacesDictionary;
    NSDictionary *bestPacesDictionary;
    NSArray *nextPoints;
    int indexOfNextPoint;
    NSDate *startDate;
}
/// this wiggle value is to account for the fact that the user it not always going to be running directly on the polyline (see triangle analogy in PIT implementation plan)
static double interpointDistanceWiggleValue = 2;

+ (BOOL) isAtStartPosition: (CLLocation *) userLocation firstPoint: (NSArray *) firstPolylinePoint{
    
    CLLocation *firstPointLocation = [[CLLocation alloc] initWithLatitude:[firstPolylinePoint[0] doubleValue] longitude:[firstPolylinePoint[1] doubleValue]];
    if ([firstPointLocation distanceFromLocation:userLocation] < 10) {
        return true;
    }
    return false;
}

- (instancetype)initWithRunID: (NSString *) objectId {
    pedometer = [[CMPedometer alloc] init];
    currentPacesDictionary = [NSMutableDictionary new];
    indexOfNextPoint = 1;
    nextPoints = [[NSArray alloc] init];
    startDate = [NSDate date];
    bestPacesDictionary = self.runObject[@"pacesDictionary"];
    polylinePoints = [Utils jsonStringToArray:self.runObject[@"polylineCoords"]];
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

 - (void) paceTracker:(CLLocation *) userLocation {
    [pedometer startPedometerEventUpdatesWithHandler:^(CMPedometerEvent * _Nullable pedometerEvent, NSError * _Nullable error) {
        
    }];
     nextPoints = [polylinePoints subarrayWithRange:NSMakeRange(indexOfNextPoint, 2)];
    
    if (![nextPoints[1] isEqual:polylinePoints[-1]]) {
        if ([self passedPoint:nextPoints currentLocation:userLocation]) {
            NSNumber *previousPace = bestPacesDictionary[nextPoints[0]] ;
            __block NSNumber *currentPace;
            NSDate *endDate = [NSDate date];
            [pedometer queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
                currentPace = pedometerData.averageActivePace;
                self->currentPacesDictionary[self->polylinePoints[self->indexOfNextPoint-1]] = currentPace;
                
                // make delegate to handle
                [self paceCompare:previousPace currentIntervalPace:currentPace pointsForInterval:@[self->polylinePoints[self->indexOfNextPoint-1], self->polylinePoints[self->indexOfNextPoint]] ];
                self->indexOfNextPoint += 1;
                self->nextPoints = [self->polylinePoints subarrayWithRange:NSMakeRange(self->indexOfNextPoint, 2)];
                self->startDate = endDate;
            }];
        } 
    } else {
        [self saveImprovedPaceDictionary:self.runObject];
    }
}

- (void) saveImprovedPaceDictionary: (PFObject *) runObject{
    NSArray *currentPacesArray = [currentPacesDictionary allValues];
    NSArray *bestPacesArray = [bestPacesDictionary allValues];
    double currentPaceTotalToAverage = 0;
    double bestPaceTotalToAverage = 0;
    
    for (int i = 0; i<bestPacesArray.count; i++) {
        currentPaceTotalToAverage += [currentPacesArray[i] doubleValue];
        bestPaceTotalToAverage += [bestPacesArray[i] doubleValue];
    }
    currentPaceTotalToAverage/=bestPacesArray.count;
    bestPaceTotalToAverage/=bestPacesArray.count;
    
    if (currentPaceTotalToAverage >= bestPaceTotalToAverage) {
        [runObject setValue:currentPacesDictionary forKey:@"pacesDict"];
        [runObject setValue:[NSString stringWithFormat:@"%f", currentPaceTotalToAverage] forKey:@"overallAveragePace"];
        [runObject save];
    }
    
}
@end
