//
//  Utils.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/29/22.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+ (NSString *) currentDateTime;
+ (NSString *) arrayToJSONString: (MKPolyline *) route;

@end

NS_ASSUME_NONNULL_END
