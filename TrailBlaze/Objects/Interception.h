//
//  Interception.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/26/22.
//

#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface Interception : PFObject<PFSubclassing>
@property (nonatomic, strong) PFGeoPoint *rendezvous;
@property (nonatomic, strong) NSString *polylineCoords;
@property (nonatomic, strong) NSString *startTime;
+ (void) uploadRequest: (PFGeoPoint *) rendezvous polylineCoords: (NSString *)polylineCoords startTime: (NSString *) startTime withCompletion: (PFBooleanResultBlock _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
