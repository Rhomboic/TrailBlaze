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
@property (strong, nonatomic) PFObject *runObject;

- (instancetype)initWithRunObject: (PFObject *) runObj;
- (instancetype)initForFirstRecord: (PFObject *) runObj;
+ (BOOL) isAtStartPosition: (CLLocation *) userLocation firstPoint: (NSArray *) firstPolylinePoint;
- (BOOL) passedPoint: (NSArray *) nextTwoPoints currentLocation: (CLLocation *) currentLocation;
- (NSArray *) paceCompare: (NSNumber *) previousIntervalPace currentIntervalPace: (NSNumber *)currentIntervalPace pointsForInterval: (NSArray *) pointsForInterval;
- (void) paceTracker:(CLLocation *) userLocation;
- (void) saveImprovedPaceDictionary: (PFObject *) runObject;
- (void) recordPacesOnRegularRun: (PFObject *) runObject userLocation:(CLLocation *) userLocation;

@end

NS_ASSUME_NONNULL_END



