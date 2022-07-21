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

+ (void) getBestETAPoint: (NSArray *) allPoints interceptorLocation: (CLLocation *) interceptorLocation runnerLocation: (CLLocation *) runnerLocation completion:(void (^)(MKMapItem *bestPoint, NSError *))completion {
    
    NSArray *prunedPoints = [self prunePoints:allPoints numberOfPoints:10];
    etas = [NSMutableArray array];
    etaPointPairs = [[NSMutableDictionary alloc] init];
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", nil);
    dispatch_group_t group = dispatch_group_create();
    
    MKPlacemark *startInterceptorPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(interceptorLocation.coordinate.latitude, interceptorLocation.coordinate.longitude)];
    
    MKPlacemark *startRunnerPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(runnerLocation.coordinate.latitude, runnerLocation.coordinate.longitude)];
    
    MKMapItem *startInterceptorItem = [[MKMapItem alloc] initWithPlacemark:startInterceptorPlacemark];
    
    MKMapItem *startRunnerItem = [[MKMapItem alloc] initWithPlacemark:startRunnerPlacemark];

    for (int i=0; i < prunedPoints.count; i++) {
        NSLog(@"starting operation %@..", @(i));
        
        dispatch_group_enter(group);
        MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([[prunedPoints objectAtIndex:i][0] doubleValue], [[prunedPoints objectAtIndex:i][1] doubleValue])];

        MKMapItem *destinationItem =  [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];

        MKDirectionsRequest *pathInterceptorRequest = [[MKDirectionsRequest alloc] init];
        [pathInterceptorRequest setSource:startInterceptorItem];
        [pathInterceptorRequest setDestination:destinationItem];
        [pathInterceptorRequest setTransportType:MKDirectionsTransportTypeWalking];
        [pathInterceptorRequest setRequestsAlternateRoutes:NO];
        
        MKDirectionsRequest *pathRunnerRequest = [[MKDirectionsRequest alloc] init];
        [pathRunnerRequest setSource:startRunnerItem];
        [pathRunnerRequest setDestination:destinationItem];
        [pathRunnerRequest setTransportType:MKDirectionsTransportTypeWalking];
        [pathRunnerRequest setRequestsAlternateRoutes:NO];
        
        MKDirections *pathInterceptor = [[MKDirections alloc] initWithRequest:pathInterceptorRequest];
        MKDirections *pathRunner = [[MKDirections alloc] initWithRequest:pathRunnerRequest];
        [pathInterceptor calculateETAWithCompletionHandler:^(MKETAResponse * _Nullable interceptorResponse, NSError * _Nullable error1) {
            if (interceptorResponse) {
                [pathRunner calculateETAWithCompletionHandler:^(MKETAResponse * _Nullable runnerResponse, NSError * _Nullable error2) {
                    if (runnerResponse) {
                        [etas addObject:[NSNumber numberWithDouble:fabs(interceptorResponse.expectedTravelTime - runnerResponse.expectedTravelTime)]];
                        [etaPointPairs setValue:runnerResponse.destination forKey:[NSString stringWithFormat:@"%.f", fabs(interceptorResponse.expectedTravelTime - runnerResponse.expectedTravelTime)]];
                    } else {
                        NSLog(@"%@", error2.localizedDescription);
                    }
                    dispatch_async(serialQueue, ^{
                        dispatch_group_leave(group);
                    });
                }];
            } else {
                NSLog(@"%@", error1.localizedDescription);
            }
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"everything is done!!");
        completion([etaPointPairs objectForKey:[NSString stringWithFormat:@"%@", [[self sortInAscendingOrder:etas] firstObject]]], nil);
    });
}


@end
