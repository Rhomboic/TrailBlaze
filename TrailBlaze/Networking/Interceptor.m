//
//  Interceptor.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/20/22.
//

#import "Interceptor.h"
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"

@implementation Interceptor

+ (NSArray *) getRemainingRoutePoints: (NSArray *) routePoints runnerLocation: (CLLocation *)runnerLocation{
    float shortestDistance = FLT_MAX;
    int index = 0;
    int closestIndex = -1;
    for (NSArray* point in routePoints) {
        CLLocation* thisPointCLLocation = [[CLLocation alloc] initWithLatitude:[[point firstObject] doubleValue] longitude:[[point lastObject] doubleValue]];
        float distanceBetween = [runnerLocation distanceFromLocation:thisPointCLLocation];
        if ( distanceBetween < shortestDistance) {
            shortestDistance = distanceBetween;
            closestIndex = index;
        }
        index += 1;
    }
    return [routePoints subarrayWithRange:NSMakeRange(closestIndex, routePoints.count-closestIndex)];
}

+ (NSArray *) sortInAscendingOrder: (NSArray *) etaDifferences {
    NSSortDescriptor *const sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"doubleValue" ascending:YES];
    NSArray<NSSortDescriptor *> *const sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [etaDifferences sortedArrayUsingDescriptors:sortDescriptors];
}

+ (NSArray *) prunePoints: (NSArray *) routePoints numberOfPoints: (int) numberOfPoints{
    NSMutableArray *pruned = [NSMutableArray new];
    NSUInteger gap = routePoints.count/numberOfPoints;
    NSLog(@"🌈🌈🌈🌈🌈%lu", (unsigned long)gap);
    for (int i = (int) gap; i < numberOfPoints; i+=gap) {
        [pruned addObject:[routePoints objectAtIndex:i]];
        NSLog(@"🐤🐤🐤%@", pruned);
    }
    return pruned;
}

+ (void) getBestETAPoint: (int) maxWaitTime allPoints:(NSArray *) allPoints interceptorLocation: (CLLocation *) interceptorLocation runnerLocation: (CLLocation *) runnerLocation completion:(void (^)(MKMapItem * _Nullable bestPoint, NSError *))completion {
    float etaDifferenceThreshold = maxWaitTime*60;
    NSArray *prunedPoints = [self prunePoints:[self getRemainingRoutePoints:allPoints runnerLocation:runnerLocation] numberOfPoints:10];
    NSLog(@"%lu", (unsigned long)allPoints.count);
    NSLog(@"🧪🧪🧪🧪🧪%lu", (unsigned long)[self getRemainingRoutePoints:allPoints runnerLocation:runnerLocation].count);
    NSLog(@"🌈🌈🌈🌈🌈%@", prunedPoints);
    NSMutableArray *etasDifferences = [NSMutableArray array];
    NSMutableDictionary *etaPointPairs = [[NSMutableDictionary alloc] init];
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
        
        dispatch_group_enter(group);
        [pathInterceptor calculateETAWithCompletionHandler:^(MKETAResponse * _Nullable interceptorResponse, NSError * _Nullable error1) {
            if (interceptorResponse) {
                [pathRunner calculateETAWithCompletionHandler:^(MKETAResponse * _Nullable runnerResponse, NSError * _Nullable error2) {
                    if (runnerResponse) {
                        dispatch_async(serialQueue, ^{
                            [etasDifferences addObject:[NSNumber numberWithDouble:fabs(interceptorResponse.expectedTravelTime - runnerResponse.expectedTravelTime)]];
                            [etaPointPairs setValue:runnerResponse.destination forKey:[NSString stringWithFormat:@"%.f", fabs(interceptorResponse.expectedTravelTime - runnerResponse.expectedTravelTime)]];
                        });
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
            dispatch_async(serialQueue, ^{
                dispatch_group_leave(group);
            });
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"everything is done!!");
        NSLog(@"%@", etasDifferences);
        NSLog(@"%@", [self sortInAscendingOrder:etasDifferences]);
        NSLog(@"%@", [NSString stringWithFormat:@"%@", [[self sortInAscendingOrder:etasDifferences] firstObject]]);
        NSNumber *bestDifference = [[self sortInAscendingOrder:etasDifferences] firstObject];
        if ([bestDifference floatValue] <= etaDifferenceThreshold) {
        completion([etaPointPairs objectForKey:[NSString stringWithFormat:@"%@", bestDifference]], nil);
        } else {
            completion(nil, nil);
        }
    });
}


@end
