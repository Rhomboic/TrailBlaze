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
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UITextField *locationField;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;

@end

@implementation HomeViewController {
    BOOL *firstCenteredOnUserLocation;
    NSDictionary *currentRun;
    CLLocation *destinationLocation;
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

- (IBAction)didTapTrailRun:(id)sender {
    [_locationField setHidden:NO];
    [_goButton setHidden:NO];
}
- (IBAction)didTapGo:(id)sender {
    [_locationField endEditing:YES];
    [_locationField setHidden:YES];
    [_goButton setHidden:YES];
    [self getLocation];
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
    
    [_locationField setHidden:YES];
    [_goButton setHidden:YES];
}

- (void) configureLocationManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestAlwaysAuthorization];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
}
#pragma mark:  Delegates
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self->firstCenteredOnUserLocation) {
        [self centerOnUserLocation];
        self->firstCenteredOnUserLocation = YES;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolygonRenderer *render = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
    [render setStrokeColor:UIColor.blueColor];
    return render;
}

#pragma mark:  Helpers
- (void) centerOnUserLocation {
    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
     MKCoordinateRegion sfRegion = MKCoordinateRegionMake(_mapView.userLocation.location.coordinate,  MKCoordinateSpanMake(0.01, 0.01));
    [_mapView setRegion:sfRegion animated:YES];
}

- (void) addPins:(CLLocationCoordinate2D)destinationCoord {
    MKPointAnnotation *startPin = [[MKPointAnnotation alloc] initWithCoordinate:_locationManager.location.coordinate title:@"Start" subtitle:@"Me"];
    MKPointAnnotation *endPin = [[MKPointAnnotation alloc] initWithCoordinate:destinationCoord title:@"End" subtitle:@"Future Me"];
    [_mapView addAnnotation:startPin];
    [_mapView addAnnotation:endPin];
}

- (void) getLocation {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:_locationField.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks) {
             self->destinationLocation = placemarks.firstObject.location;
            NSLog(@"%@", self->destinationLocation);
            [self addPins: self->destinationLocation.coordinate];
            [self getDirections:(__bridge CLLocationCoordinate2D *)(self->destinationLocation)];
        } else {
            NSLog(@"No location found");
        }
    }];
}

- (void) getDirections:(CLLocationCoordinate2D *) destinationCoords {
    CLLocationCoordinate2D startCoords = _locationManager.location.coordinate;
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:startCoords];
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:*destinationCoords];
    
    MKMapItem *startItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    MKMapItem *destinationItem =  [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];

    MKDirectionsRequest *pathRequest = [[MKDirectionsRequest alloc] init];
    [pathRequest setSource:startItem];
    [pathRequest setDestination:destinationItem];
    [pathRequest setTransportType:MKDirectionsTransportTypeAutomobile];
    [pathRequest setRequestsAlternateRoutes:NO];
    
    MKDirections *path = [[MKDirections alloc] initWithRequest:pathRequest];
    [path calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (response) {
            MKRoute *route = [response.routes firstObject];
            [self->_mapView addOverlay:route.polyline];
            [self->_mapView setVisibleMapRect:route.polyline.boundingMapRect animated:YES];
        } else {
            NSLog(@"Unable to get route");
        }
    }];
    
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
