//
//  Interception.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/26/22.
//

#import <Foundation/Foundation.h>
#import "MapKit/Mapkit.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface Interception : PFObject<PFSubclassing>
@property (nonatomic, strong) PFGeoPoint *rendezvous;
@property (nonatomic, strong) NSString *polylineCoords;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *receiver;
+ (void) uploadRequest: (PFGeoPoint *) rendezvous polyline: (MKPolyline *)polyline receiver: (PFUser *) receiver withCompletion: (PFBooleanResultBlock _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
