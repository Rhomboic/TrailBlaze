//
//  RunnerAnnotation.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/21/22.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"
NS_ASSUME_NONNULL_BEGIN

@interface RunnerAnnotation : NSObject <MKAnnotation>
@property (strong, nonatomic) UIImage *profilePhoto;
@end

NS_ASSUME_NONNULL_END
