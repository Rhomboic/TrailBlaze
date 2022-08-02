//
//  PaceImprovementTracking.h
//  TrailBlaze
//
//  Created by Adam Issah on 8/1/22.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"
#import "CoreMotion/CoreMotion.h"

NS_ASSUME_NONNULL_BEGIN


@interface PaceImprovementTracker : NSObject
@property (strong, nonatomic) CMPedometer  *pedometer;
@property (strong, nonatomic) NSMutableArray *currentPacesArray;
@property (strong, nonatomic) NSDictionary *bestPacesDictionary;
@property (strong, nonatomic) NSArray *polylinePoints;

- (instancetype)initWithRunID: (NSString *) objectId;
+ (BOOL) isAtStartPosition: (CLLocation *) userLocation firstPoint: (NSArray *) firstPolylinePoint;
- (BOOL) passedPoint: (NSArray *) nextTwoPoints currentLocation: (CLLocation *) currentLocation;
- (NSArray *) paceCompare: (NSNumber *) previousIntervalPace currentIntervalPace: (NSNumber *)currentIntervalPace pointsForInterval: (NSArray *) pointsForInterval;
- (void) paceTracker: (NSArray *) polylinePoints userLocation: (CLLocation *) userLocation bestPaces: (NSDictionary *) bestPaces;

@end

NS_ASSUME_NONNULL_END



