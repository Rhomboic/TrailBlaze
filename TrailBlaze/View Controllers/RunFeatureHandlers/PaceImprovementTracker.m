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
#import "JSONUtils.h"
#import "CustomPolyline.h"

@implementation PaceImprovementTracker {
    CMPedometer  *pedometer;
    NSArray *polylinePoints;
    NSMutableDictionary *currentPacesDictionary;
    double currentPacesAverage;
    NSDictionary *bestPacesDictionary;
    NSArray *nextPoints;
    int indexOfNextPoint;
    NSDate *startDate;
    double lastDistanceToNextPoint;
    double lastDistanceToNextTwoPoints;
}
/// this wiggle value is to account for the fact that the user it not always going to be running directly on the polyline (see triangle analogy in PIT implementation plan)
static double interpointDistanceWiggleValue = 10;

+ (BOOL) isAtStartPosition: (CLLocation *) userLocation firstPoint: (NSArray *) firstPolylinePoint{
    
    CLLocation *firstPointLocation = [[CLLocation alloc] initWithLatitude:[firstPolylinePoint[0] doubleValue] longitude:[firstPolylinePoint[1] doubleValue]];
    if ([firstPointLocation distanceFromLocation:userLocation] < 10) {
        return true;
    }
    return false;
}

- (instancetype)initWithRunObject: (PFObject *) runObj {
    pedometer = [[CMPedometer alloc] init];
    currentPacesDictionary = [NSMutableDictionary new];
    indexOfNextPoint = 1;
    nextPoints = [[NSArray alloc] init];
    startDate = [NSDate date];
    bestPacesDictionary = runObj[@"pacesDictionary"];
    polylinePoints = [JSONUtils jsonStringToArray:runObj[@"polylineCoords"]];
    lastDistanceToNextPoint = FLT_MAX;
    lastDistanceToNextTwoPoints = FLT_MAX;
    
    return self;
}

- (instancetype)initForFirstRecord: (PFObject *) runObj {
    pedometer = [[CMPedometer alloc] init];
    currentPacesDictionary = [NSMutableDictionary new];
    indexOfNextPoint = 1;
    nextPoints = [[NSArray alloc] init];
    startDate = [NSDate date];
    polylinePoints = [JSONUtils jsonStringToArray:runObj[@"polylineCoords"]];
    lastDistanceToNextPoint = FLT_MAX;
    lastDistanceToNextTwoPoints = FLT_MAX;
    
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

- (BOOL) passedPointSecond: (NSArray *) nextTwoPoints currentLocation: (CLLocation *) currentLocation {
    CLLocation *firstPointLocation = [[CLLocation alloc] initWithLatitude:[nextTwoPoints[0][0] doubleValue] longitude:[nextTwoPoints[0][1] doubleValue]];
    CLLocation *secondPointLocation = [[CLLocation alloc] initWithLatitude:[nextTwoPoints[1][0] doubleValue] longitude:[nextTwoPoints[1][1] doubleValue]];
    double distanceToFirst = [firstPointLocation distanceFromLocation:currentLocation];
    double distanceToSecond = [secondPointLocation distanceFromLocation:currentLocation];
    if ((distanceToFirst > lastDistanceToNextPoint) && (distanceToSecond < lastDistanceToNextTwoPoints)) {
        lastDistanceToNextPoint = FLT_MAX;
        lastDistanceToNextTwoPoints = FLT_MAX;
        return true;
    }
    lastDistanceToNextPoint = distanceToFirst;
    lastDistanceToNextTwoPoints = distanceToSecond;
    return false;
}

- (CustomPolyline *) paceCompare: (NSNumber *) previousIntervalPace currentIntervalPace: (NSNumber *)currentIntervalPace pointsForInterval: (NSArray *) pointsForInterval {
    CLLocationCoordinate2D *endPoints = malloc(2 * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < 2; i++) {
        endPoints[i] = CLLocationCoordinate2DMake([pointsForInterval[i][0] doubleValue] , [pointsForInterval[i][1] doubleValue]);
    }
      CustomPolyline *overlapPolyline = [CustomPolyline polylineWithCoordinates:endPoints count:2];
    if (currentIntervalPace >= previousIntervalPace) {
        [overlapPolyline setColor:UIColor.systemGreenColor];
        return overlapPolyline;
    }
    [overlapPolyline setColor:UIColor.systemGreenColor];
    return overlapPolyline;
}

- (void) paceTracker:(CLLocation *) userLocation {
    [pedometer startPedometerEventUpdatesWithHandler:^(CMPedometerEvent * _Nullable pedometerEvent, NSError * _Nullable error) {
        
    }];
     nextPoints = [polylinePoints subarrayWithRange:NSMakeRange(indexOfNextPoint, 2)];
        if ([self passedPointSecond:nextPoints currentLocation:userLocation]) {
            NSString *gotPoint;
            NSArray *gotPointArray = nextPoints[0];
            gotPoint = [NSString stringWithFormat:@"[%f, %f]", [[gotPointArray firstObject] doubleValue], [[gotPointArray lastObject] doubleValue] ];
            NSNumber *previousPace = [bestPacesDictionary valueForKey:gotPoint] ;
            __block NSNumber *currentPace;
            NSDate *endDate = [NSDate date];
            [pedometer queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
                currentPace = pedometerData.averageActivePace;
                if (!currentPace) {
                    currentPace = [[NSNumber alloc] initWithDouble:0.0];
                }
                NSLog(@"%@", currentPace);
                NSString *point;
                NSArray *pointArray = self->polylinePoints[self->indexOfNextPoint-1];
                point = [NSString stringWithFormat:@"[%f, %f]", [[pointArray firstObject] doubleValue], [[pointArray lastObject] doubleValue] ];
                [self->currentPacesDictionary setValue:currentPace forKey:point];
                
                CustomPolyline *polylineVerdict = [self paceCompare:previousPace currentIntervalPace:currentPace pointsForInterval:@[self->polylinePoints[self->indexOfNextPoint-1], self->polylinePoints[self->indexOfNextPoint]] ];
                [self.delegate sendPolylineToHomeView: polylineVerdict];
                
                self->indexOfNextPoint += 1;
                @try {
                self->nextPoints = [self->polylinePoints subarrayWithRange:NSMakeRange(self->indexOfNextPoint, 2)];
                }
                @catch (NSException *e){
                    [self saveImprovedPaceDictionary:self.runObject];
                }
                self->startDate = endDate;
            }];
        }
    
}

- (void) recordPacesOnRegularRun: (PFObject *) runObject userLocation:(CLLocation *) userLocation{
    NSArray *Points = [JSONUtils jsonStringToArray:runObject[@"polylineCoords"]];
    [pedometer startPedometerEventUpdatesWithHandler:^(CMPedometerEvent * _Nullable pedometerEvent, NSError * _Nullable error) {
        
    }];
     nextPoints = [Points subarrayWithRange:NSMakeRange(indexOfNextPoint, 2)];
        if ([self passedPointSecond:nextPoints currentLocation:userLocation]) {
            NSLog(@"💀💀💀💀💀💀💀💀");
            [self.delegate notifyWhenPointPassed: indexOfNextPoint];
            
            __block NSNumber *currentPace;
            NSDate *endDate = [NSDate date];
            [pedometer queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
                currentPace = pedometerData.averageActivePace;
                if (!currentPace) {
                    currentPace = [[NSNumber alloc] initWithDouble:0.0];
                }
                NSLog(@"%@", currentPace);
                NSString *point;
                NSArray *pointArray = self->polylinePoints[self->indexOfNextPoint-1];
                point = [NSString stringWithFormat:@"[%f, %f]", [[pointArray firstObject] doubleValue], [[pointArray lastObject] doubleValue] ];
                [self->currentPacesDictionary setValue:currentPace forKey:point];
                self->indexOfNextPoint += 1;
                @try {
                self->nextPoints = [self->polylinePoints subarrayWithRange:NSMakeRange(self->indexOfNextPoint, 2)];
                }
                @catch (NSException *e) {
                    [Run savePaceData: runObject dataDict:self->currentPacesDictionary dataAverage:self->currentPacesAverage];
                }
                self->startDate = endDate;
            }];
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
    
    currentPacesAverage = currentPaceTotalToAverage;
    
    if (currentPaceTotalToAverage >= bestPaceTotalToAverage) {
        [Run savePaceData: runObject dataDict:currentPacesDictionary dataAverage:currentPacesAverage];
    }
    
}
@end
