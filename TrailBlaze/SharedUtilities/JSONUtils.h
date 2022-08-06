//
//  JSONUtils.h
//  TrailBlaze
//
//  Created by Adam Issah on 8/5/22.
//

#import <Foundation/Foundation.h>
@import MapKit;


NS_ASSUME_NONNULL_BEGIN

@interface JSONUtils : NSObject
+ (NSString *) arrayToJSONString: (MKPolyline *) polyline;
+ (NSArray *) jsonStringToArray: (NSString *) polylineCoords;
@end

NS_ASSUME_NONNULL_END
