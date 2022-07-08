//
//  MapViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/6/22.
//

#import "MapViewController.h"
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) MKMapView *mapView;
@property (weak, nonatomic) UIButton *locationButton;
@property (weak, nonatomic) UIButton *freerunButton;
@property (weak, nonatomic) UIButton *trailrunButton;
@property (weak, nonatomic) UIButton *goButton;
@property (weak, nonatomic) UITextField *locationField;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;

@end

@implementation MapViewController {
    NSDictionary *currentRun;
    CLLocation *destinationLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setRestorationIdentifier:@"MapViewController"];
    [self configureMapView];
    [self configureLocationManager];
    [self configureSubviews];
    [self centerOnUserLocation];
    [self getLocation];
    
}
#pragma mark:  Button Actions

- (void) didTapCurrentLocation:(UIButton *)currentlocationButton {
    [self centerOnUserLocation];
}

- (void)didTapFreeRun:(UIButton *)_freerunButton {
    
}

- (void)didTapTrailRun:(UIButton *)_trailrunButton {
    [_locationField setHidden:NO];
    [_goButton setHidden:NO];
}
- (void)didTapGo:(UIButton *)_goButton {
    [_locationField endEditing:YES];
    [_locationField setHidden:YES];
    [_goButton setHidden:YES];
    [self getLocation];
}

#pragma mark:  Views Configs

- (void) configureMapView {
    _mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    _mapView.delegate =  self;
    _mapView.showsUserLocation = YES;
    [self.view addSubview:_mapView];
}

- (void) configureSubviews {
    _locationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_locationButton setImage:[UIImage imageNamed:@"location.fill"] forState:UIControlStateNormal];
    [_locationButton sizeToFit];
    _locationButton.layer.cornerRadius = 30;
    _locationButton.clipsToBounds = true;
    
    _freerunButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_freerunButton setTitle:@"Free Run" forState:UIControlStateNormal];
    [_freerunButton sizeToFit];
    _freerunButton.layer.cornerRadius = 30;
    _freerunButton.clipsToBounds = true;
    
    
    _trailrunButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_trailrunButton setTitle:@"Trail Run" forState:UIControlStateNormal];
    [_trailrunButton sizeToFit];
    _trailrunButton.layer.cornerRadius = 30;
    _trailrunButton.clipsToBounds = true;
    
    
    
    _locationField = [[UITextField alloc] initWithFrame:CGRectMake(10, 200, 300, 40)];
    _locationField.borderStyle = UITextBorderStyleRoundedRect;
    _locationField.font = [UIFont systemFontOfSize:15];
    _locationField.placeholder = @"enter text";
    _locationField.autocorrectionType = UITextAutocorrectionTypeNo;
    _locationField.keyboardType = UIKeyboardTypeDefault;
    _locationField.returnKeyType = UIReturnKeyDone;
    _locationField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _locationField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _locationField.delegate = self;
    [_locationField setHidden:YES];
    
    _goButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_goButton setTitle:@"Trail Run" forState:UIControlStateNormal];
    [_goButton sizeToFit];
    [_goButton setHidden:YES];
    
    [self.mapView addSubview:_locationButton];
    [self.mapView addSubview:_locationField];
    [self.mapView addSubview:_freerunButton];
    [self.mapView addSubview:_trailrunButton];
    [self.mapView addSubview:_goButton];
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

- (void) getLocation {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:@"Palo Alto" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks) {
             self->destinationLocation = placemarks.firstObject.location;
            NSLog(@"%@", self->destinationLocation);
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
    [pathRequest setTransportType:MKDirectionsTransportTypeWalking];
    [pathRequest setRequestsAlternateRoutes:YES];
    
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


