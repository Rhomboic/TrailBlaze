//
//  HomeViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 6/30/22.
//
#import "CoreLocation/CoreLocation.h"
#import "HomeViewController.h"
#import "MapKit/MapKit.h"

@interface HomeViewController ()  <MKMapViewDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *freerunButton;
@property (weak, nonatomic) IBOutlet UIButton *trailrunButton;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;

@end

@implementation HomeViewController {
    NSDictionary *_currentRun;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureMapView];
    [self configureLocationManager];
    [self configureSubviews];
    [self centerOnUserLocation];
    
}
#pragma mark:  Button Actions

- (IBAction)didTapCurrentLocation:(id)sender {
    [self centerOnUserLocation];
}

- (IBAction)didTapFreeRun:(id)sender {
    
}

#pragma mark:  Views Configs

- (void) configureMapView {
    _mapView.delegate =  self;
    _mapView.showsUserLocation = YES;
}

- (void) configureSubviews {
    _locationButton.layer.cornerRadius = 30;
    _locationButton.clipsToBounds = true;
    
    _freerunButton.layer.cornerRadius = 30;
    _freerunButton.clipsToBounds = true;
    
    _trailrunButton.layer.cornerRadius = 30;
    _trailrunButton.clipsToBounds = true;
}

- (void) configureLocationManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
}
#pragma mark:  Delegates
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [self centerOnUserLocation];
}

#pragma mark:  Helpers
- (void) centerOnUserLocation {
    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
     MKCoordinateRegion sfRegion = MKCoordinateRegionMake(_mapView.userLocation.location.coordinate,  MKCoordinateSpanMake(0.01, 0.01));
    [_mapView setRegion:sfRegion animated:YES];
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
