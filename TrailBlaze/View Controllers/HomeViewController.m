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
@property (weak, nonatomic) IBOutlet UIButton *trailrunButton;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UIButton *statsButton;
@end

@implementation HomeViewController {
    BOOL firstCenteredOnUserLocation;
    CLLocationManager *locationManager;

    CLLocation *currentLocation;
    CLLocation *destinationLocation;
    
    float destinationLocationLatitude;
    float destinationLocationLongitude;
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

- (IBAction)didTapStats:(id)sender {
}


- (IBAction)didTapTrailRun:(id)sender {
    [_goButton setImage:[UIImage systemImageNamed:@"point.topleft.down.curvedto.point.filled.bottomright.up"] forState:UIControlStateNormal];
    _goButton.imageView.image = nil;
    _goButton.layer.cornerRadius = 15;
    
    [_locationField setHidden:NO];
    [_locationField becomeFirstResponder];
    
}
- (IBAction)didTapGo:(id)sender {
    if (!_locationField.isHidden) {
        [_goButton setImage:[UIImage systemImageNamed:@"map.fill"] forState:UIControlStateNormal];
        [_locationField endEditing:YES];
        _goButton.layer.cornerRadius = 25;
        
        [_locationField setHidden:YES];
        [_mapView removeOverlays:_mapView.overlays];
        [_mapView removeAnnotations:_mapView.annotations];
        [self getLocation];
    } else {
        if (_mapView.mapType == MKMapTypeHybridFlyover) {
            _mapView.mapType = MKMapTypeStandard;
        } else {
            _mapView.mapType = MKMapTypeHybridFlyover;
        }
    }
}

#pragma mark:  Views Configs

- (void) configureMapView {
    _mapView.delegate =  self;
    _mapView.showsUserLocation = YES;
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void) configureSubviews {
    _locationButton.layer.cornerRadius = 30;
    _locationButton.clipsToBounds = true;
    
    _trailrunButton.layer.cornerRadius = 40;
    _trailrunButton.clipsToBounds = true;
    
    _statsButton.layer.cornerRadius = 30;
    _statsButton.clipsToBounds = true;
    
    [_locationField setHidden:YES];
    _locationField.layer.cornerRadius = 20;
    _locationField.clipsToBounds = true;
           
    _goButton.layer.cornerRadius = 25;
    _goButton.clipsToBounds = true;
    [_goButton setImage:[UIImage systemImageNamed:@"map.fill"] forState:UIControlStateNormal];


}

- (void) configureLocationManager {
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager requestAlwaysAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}
#pragma mark:  Delegates
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    [render setStrokeColor:UIColor.systemYellowColor];
    [render setLineWidth:5.0];
    return render;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations lastObject];
}

#pragma mark:  Helpers
- (void) centerOnUserLocation {
    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
     MKCoordinateRegion sfRegion = MKCoordinateRegionMake(_mapView.userLocation.location.coordinate,  MKCoordinateSpanMake(0.01, 0.01));
    [_mapView setRegion:sfRegion animated:YES];
}

- (void) addPins:(CLLocationCoordinate2D)destinationCoord {
    MKPointAnnotation *startPin = [[MKPointAnnotation alloc] initWithCoordinate:locationManager.location.coordinate title:@"Start" subtitle:@"Me"];
    MKPointAnnotation *endPin = [[MKPointAnnotation alloc] initWithCoordinate:destinationCoord title:@"End" subtitle:@"Future Me"];
    [_mapView addAnnotation:startPin];
    [_mapView addAnnotation:endPin];
}

- (void) getLocation {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:_locationField.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks) {
            self->destinationLocation = placemarks.firstObject.location;
            [self addPins: self->destinationLocation.coordinate];
            self->destinationLocationLatitude = placemarks.firstObject.location.coordinate.latitude;
            self->destinationLocationLongitude = placemarks.firstObject.location.coordinate.longitude;
            [self getDirections];
        } else {
            NSLog(@"No location found");
        }
    }];
}

- (void) getDirections{
    float startlatitude = currentLocation.coordinate.latitude;
    float startlongitude = currentLocation.coordinate.longitude;
    
    float destlatitude = destinationLocationLatitude;
    float destlongitude = destinationLocationLongitude;
    
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(startlatitude, startlongitude)];
    
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(destlatitude, destlongitude)];

    MKMapItem *startItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    MKMapItem *destinationItem =  [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];

    MKDirectionsRequest *pathRequest = [[MKDirectionsRequest alloc] init];
    [pathRequest setSource:startItem];
    [pathRequest setDestination:destinationItem];
    [pathRequest setTransportType:MKDirectionsTransportTypeAutomobile];
    [pathRequest setRequestsAlternateRoutes:YES];
    
    MKDirections *path = [[MKDirections alloc] initWithRequest:pathRequest];
    [path calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (response) {
            MKRoute *route = [response.routes firstObject];

            [self->_mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
            MKMapRect mapRect = route.polyline.boundingMapRect;
            [self->_mapView setRegion:MKCoordinateRegionForMapRect(mapRect) animated:YES];
            
        } else {
            NSLog(@"Unable to get route %@", error.description);
        
        }
    }];
    
}

@end
