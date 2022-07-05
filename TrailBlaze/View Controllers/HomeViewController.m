//
//  HomeViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 6/30/22.
//

#import "HomeViewController.h"
#import "MapKit/MapKit.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//@property (weak, nonatomic) IBOutlet UIButton *trailRunButton;
//@property (weak, nonatomic) IBOutlet UIButton *freeRunButton;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667), MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:sfRegion animated:false];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
