//
//  HomeViewController.h
//  TrailBlaze
//
//  Created by Adam Issah on 6/30/22.
//

#import <UIKit/UIKit.h>
#import "Mapkit/Mapkit.h"
#import "MateDetailViewController.h"
#import "PaceImprovementTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController <PacePolylineDelegate>
@property (strong, nonatomic) MKPolyline *cloudPolyline;
@property (strong, nonatomic) PFUser *cloudUser;
@property BOOL isRerun;
@property BOOL isReadyToStartRun;
@property (strong, nonatomic) PFObject *runObject;

@end

NS_ASSUME_NONNULL_END
