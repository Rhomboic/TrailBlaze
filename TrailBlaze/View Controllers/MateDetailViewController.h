//
//  MateDetailViewController.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/18/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "MapKit/MapKit.h"

NS_ASSUME_NONNULL_BEGIN
//@protocol RetrievedPolylineDelegate <NSObject>
//- (void) sendPolylineToHomeVC: (MKPolyline *)polyline;
//@end

@interface MateDetailViewController : UIViewController
@property (strong, nonatomic) PFUser *thisUser;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@end

NS_ASSUME_NONNULL_END
