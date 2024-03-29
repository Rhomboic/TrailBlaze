//
//  Interceptor.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/20/22.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface Interceptor : NSObject
+ (void) getBestETAPoint: (int) maxWaitTime allPoints:(NSArray *) allPoints interceptorLocation: (CLLocation *) interceptorLocation runnerLocation: (CLLocation *) runnerLocation completion:(void (^)(MKMapItem * _Nullable bestPoint, NSError *))completion;
@end

NS_ASSUME_NONNULL_END
