//
//  HomeViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 6/30/22.
//
#import "CoreLocation/CoreLocation.h"
#import "HomeViewController.h"
#import "MapKit/MapKit.h"
#import "Run.h"

@interface HomeViewController ()  <MKMapViewDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *trailrunButton;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UIButton *statsButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@end

@implementation HomeViewController {
    BOOL firstCenteredOnUserLocation;
    CLLocationManager *locationManager;

    CLLocation *currentLocation;
    CLLocation *destinationLocation;
    
    float destinationLocationLatitude;
    float destinationLocationLongitude;
    
    MKRoute *currentRoute;
    NSString *pointsJson;
    
    MKPolyline *currentPolyline;
    MKMapItem *startItem;
    MKMapItem *destinationItem;
    
    BOOL isReady;
    BOOL localIsRunning;
    
    NSTimer *timer;
    int count;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self centerOnUserLocation];
    [self configureMapView];
    [self configureLocationManager];
    [self configureSubviews];
    
    
    
}
#pragma mark:  Button Actions

- (IBAction)didTapCurrentLocation:(id)sender {
    [self centerOnUserLocation];
}

- (IBAction)didTapStats:(id)sender {
}

- (IBAction)didTapTrailRun:(id)sender {
    if (isReady) {
        self->localIsRunning = true;
        self->isReady = false;
        _timerLabel.text = @"00:00:00";
        [_timerLabel setHidden:NO];
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCounter) userInfo:nil repeats:true];
        [Run uploadRun:currentRoute withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"run sent!");
            } else {
                NSLog(@"run not sent");
            }
        }];
        [PFUser.currentUser setValue:[NSNumber numberWithBool:YES] forKey:@"isRunning"];
        [PFUser.currentUser saveInBackground];
        [_statsButton setHidden:YES];
        [_locationButton setHidden:YES];
        [_trailrunButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_trailrunButton setTitle:@"END" forState:UIControlStateNormal];
    } else if (localIsRunning) {
        localIsRunning = false;
        [timer invalidate];
        count = 0;
        [_trailrunButton setTitle:@"" forState:UIControlStateNormal];
        [_mapView removeOverlay:currentPolyline];
        
        [_mapView removeAnnotations:_mapView.annotations];
        [PFUser.currentUser setValue: [NSNumber numberWithBool:NO] forKey:@"isRunning"];
        [Run retreiveRunObject:PFUser.currentUser completion:^(PFObject * _Nonnull runObject, NSError * _Nullable err) {
            if (runObject) {
                NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
                [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
                [runObject setValue:[DateFormatter stringFromDate:[NSDate date]] forKey:@"endTime"];
                [runObject setValue:self->_timerLabel.text forKey:@"duration"];
                [runObject saveInBackground];
            } else {
                NSLog(@"%@", err.localizedDescription);
            }
        }];
        [PFUser.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"isRunning = False");
            } else {
                NSLog(@"could not save is running");
            }
        }];
        [NSThread sleepForTimeInterval: 1];
        [_timerLabel setHidden:YES];
        [_locationButton setHidden:NO];
        [_statsButton setHidden:NO];
        
    } else {
        [_goButton setImage:[UIImage systemImageNamed:@"point.topleft.down.curvedto.point.filled.bottomright.up"] forState:UIControlStateNormal];
        _goButton.imageView.image = nil;
        _goButton.layer.cornerRadius = 15;
        
        [_locationField setHidden:NO];
        [_locationField becomeFirstResponder];
    }
    
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
    count = 0;
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    if (_cloudPolyline) {
        [self->_trailrunButton setTitle:@"Rendezvous" forState:UIControlStateNormal];
        [_mapView addOverlay:_cloudPolyline];
        MKMapRect mapRect = _cloudPolyline.boundingMapRect;
        [self->_mapView setRegion:MKCoordinateRegionForMapRect(mapRect) animated:YES];
    }
}

- (void) configureSubviews {
    _locationButton.layer.cornerRadius = 30;
    _locationButton.clipsToBounds = true;
    
    [_trailrunButton setImage:[UIImage imageNamed:@"logo_button-removebg"] forState:UIControlStateNormal];
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
    
    _timerLabel.layer.cornerRadius = 30;
    _timerLabel.clipsToBounds = true;
    [_timerLabel setHidden:YES];
}

- (void) configureLocationManager {
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager requestAlwaysAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    isReady = false;
    localIsRunning = false;
}

#pragma mark:  Delegates
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    if (overlay == currentPolyline) {
        [render setStrokeColor:UIColor.systemYellowColor];
        [render setLineWidth:5.0];

    } else {
        [render setStrokeColor:UIColor.systemGreenColor];
        [render setLineWidth:5.0];
    }
    return render;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations lastObject];
}

#pragma mark:  Helpers
- (void) timerCounter {
    count = count + 1;
    NSString *timeString = [self secondsToHMS:count];
    _timerLabel.text = timeString;
}

- (NSString *) secondsToHMS: (int ) seconds {
    return [NSString stringWithFormat:@"%02d:%02d:%02d", seconds/3600, (seconds % 3600)/60, (seconds % 3600)%60];
}



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
            [_trailrunButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self->_trailrunButton setTitle:@"Start" forState:UIControlStateNormal];
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

    startItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    destinationItem =  [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];

    MKDirectionsRequest *pathRequest = [[MKDirectionsRequest alloc] init];
    [pathRequest setSource:startItem];
    [pathRequest setDestination:destinationItem];
    [pathRequest setTransportType:MKDirectionsTransportTypeWalking];
    [pathRequest setRequestsAlternateRoutes:YES];
    
    MKDirections *path = [[MKDirections alloc] initWithRequest:pathRequest];
    [path calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (response) {
            MKRoute *route = [response.routes firstObject];
            self->currentRoute = route;
            self->isReady = true;
            self->currentPolyline = route.polyline;
            [self->_mapView addOverlay:self->currentPolyline level:MKOverlayLevelAboveRoads];
            MKMapRect mapRect = route.polyline.boundingMapRect;
            [self->_mapView setRegion:MKCoordinateRegionForMapRect(mapRect) animated:YES];
            
        } else {
            NSLog(@"Unable to get route %@", error.description);
        
        }
    }];
    
}

@end
