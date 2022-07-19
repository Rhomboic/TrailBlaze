//
//  Run.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/12/22.
//

#import <Foundation/Foundation.h>
@import Parse;
@import MapKit;

NS_ASSUME_NONNULL_BEGIN

@interface Run : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *runID;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *polylineCoords;

+ (void) uploadRun: (MKRoute *) route withCompletion: (PFBooleanResultBlock _Nullable)completion;
+ (void) retreiveRun : (PFUser *) runner completion:(void (^)(MKPolyline *polyline, NSError * _Nullable))completion ;

@end

NS_ASSUME_NONNULL_END
