//
//  PaceImprovementTracking.h
//  TrailBlaze
//
//  Created by Adam Issah on 8/1/22.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"
#import "CoreMotion/CoreMotion.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN


@interface PaceImprovementTracker : NSObject
@property (strong, nonatomic) CMPedometer  *pedometer;
@property (strong, nonatomic) NSMutableDictionary *currentPacesDictionary;
@property (strong, nonatomic) NSDictionary *bestPacesDictionary;
@property (strong, nonatomic) NSArray *polylinePoints;
@property (strong, nonatomic) NSArray *nextPoints;
@property int i;
@property (strong, nonatomic) NSDate *startDate;

- (instancetype)initWithRunID: (NSString *) objectId;
+ (BOOL) isAtStartPosition: (CLLocation *) userLocation firstPoint: (NSArray *) firstPolylinePoint;
- (BOOL) passedPoint: (NSArray *) nextTwoPoints currentLocation: (CLLocation *) currentLocation;
- (NSArray *) paceCompare: (NSNumber *) previousIntervalPace currentIntervalPace: (NSNumber *)currentIntervalPace pointsForInterval: (NSArray *) pointsForInterval;
- (void) paceTracker: (NSArray *) polylinePoints userLocation: (CLLocation *) userLocation bestPaces: (NSDictionary *) bestPaces;
- (void) saveImprovedPaceDictionary: (PFObject *) runObject;

@end

NS_ASSUME_NONNULL_END



