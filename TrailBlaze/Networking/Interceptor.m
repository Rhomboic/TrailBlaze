//
//  Interceptor.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/20/22.
//

#import "Interceptor.h"
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"

@implementation Interceptor {
    
}
//static float etaDifferenceThreshold = 2;
static NSMutableArray *etas;
static NSMutableDictionary *etaPointPairs;

+ (NSArray *) getRemainingRoutePoints: (NSArray *) routePoints runnerLocation: (NSArray *)runnerLocation{
    float shortestDistance = FLT_MAX;
    int index = 0;
    int closestIndex = -1;
    CLLocation* runnerCLLocation = [[CLLocation alloc] initWithLatitude:[[runnerLocation firstObject] doubleValue] longitude:[[runnerLocation lastObject] doubleValue]];
    for (NSArray* point in routePoints) {
        CLLocation* thisPointCLLocation = [[CLLocation alloc] initWithLatitude:[[point firstObject] doubleValue] longitude:[[point lastObject] doubleValue]];
        float distanceBetween = [runnerCLLocation distanceFromLocation:thisPointCLLocation];
        if ( distanceBetween < shortestDistance) {
            shortestDistance = distanceBetween;
            closestIndex = index;
        }
        index += 1;
    }
    return [routePoints subarrayWithRange:NSMakeRange(closestIndex, routePoints.count - 1)];
}

+ (NSArray *) sortInAscendingOrder: (NSArray *) etaDifferences {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"doubleValue" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [etaDifferences sortedArrayUsingDescriptors:sortDescriptors];
}

+ (NSArray *) prunePoints: (NSArray *) routePoints numberOfPoints: (int) numberOfPoints{
    NSMutableArray *prunedPoints = [[NSMutableArray alloc] init];
    NSUInteger gap = routePoints.count/numberOfPoints;
    for (int i = (int) gap; i < numberOfPoints; i+=gap) {
        [prunedPoints addObject:[routePoints objectAtIndex:i]];
    }
    return prunedPoints;
}

@end
