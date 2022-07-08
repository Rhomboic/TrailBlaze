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
    [_locationField setHidden:NO];
    [_locationField becomeFirstResponder];
    [_goButton setHidden:NO];
}
- (IBAction)didTapGo:(id)sender {
    [_locationField endEditing:YES];
    [_locationField setHidden:YES];
    [_goButton setHidden:YES];
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
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
    
    _trailrunButton.layer.cornerRadius = 40;
    _trailrunButton.clipsToBounds = true;
    
    _statsButton.layer.cornerRadius = 30;
    _statsButton.clipsToBounds = true;
    
    [_locationField setHidden:YES];
    _locationField.layer.cornerRadius = 20;
    _locationField.clipsToBounds = true;
    [_goButton setHidden:YES];
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
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!firstCenteredOnUserLocation) {
        [self centerOnUserLocation];
        firstCenteredOnUserLocation = YES;
    }
}

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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
