//
//  PaceImprovementTracking.h
//  TrailBlaze
//
//  Created by Adam Issah on 8/1/22.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface PaceImprovementTracking : NSObject
+ (BOOL) isAtStartPosition: (CLLocation *) userLocation firstPoint: (NSArray *) firstPolylinePoint;

@end

NS_ASSUME_NONNULL_END

//
//  PIT.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/29/22.
//


