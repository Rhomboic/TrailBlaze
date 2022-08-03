//
//  HomeViewController.h
//  TrailBlaze
//
//  Created by Adam Issah on 6/30/22.
//

#import <UIKit/UIKit.h>
#import "Mapkit/Mapkit.h"
#import "MateDetailViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController 
@property (strong, nonatomic) MKPolyline *cloudPolyline;
@property (strong, nonatomic) PFUser *cloudUser;
@property BOOL isRerun;
@property (strong, nonatomic) PFObject *runObject;
@end

NS_ASSUME_NONNULL_END
