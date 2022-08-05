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
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *startLocationAddress;
@property (nonatomic, strong) NSString *endLocationAddress;

+ (void) uploadRun: (MKRoute *) route;
+ (void) retreiveRunPolyline : (PFUser *) runner completion:(void (^)(MKPolyline *polyline, NSError * _Nullable))completion ;
+ (void) retreiveRunObject : (PFUser *) runner completion:(void (^)(PFObject *runObject, NSError * _Nullable))completion;
+ (void) retreiveRunObjects : (PFUser *) runner limit: (int) limit completion:(void (^)(NSArray *runObjects, NSError * _Nullable))completion;
+ (void) retreiveRunPoints : (PFUser *) runner completion:(void (^)(NSArray *runObjectPoints, NSError * _Nullable))completion;
+ (void) retreiveSpecificRunObject :(NSString *) objectId completion:(void (^)(PFObject *runObject, NSError * _Nullable))completion;
+ (void) savePaceData: (PFObject *) runObject dataDict: (NSMutableDictionary *) currentPacesDictionary dataAverage: (double) currentPaceTotalToAverage ;
@end

NS_ASSUME_NONNULL_END
