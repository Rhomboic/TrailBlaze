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
#import "Interceptor.h"
#import "QueryManager.h"
#import "ParseLiveQuery/ParseLiveQuery-umbrella.h"

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
    CLLocation *cloudUserLocation;
    MKPointAnnotation* runnerPin;
    
    float destinationLocationLatitude;
    float destinationLocationLongitude;
    
    MKRoute *currentRoute;
    NSString *pointsJson;
    
    MKPolyline *currentPolyline;
    MKMapItem *startItem;
    MKMapItem *destinationItem;
    
    BOOL isReadyToStartRun;
    BOOL isCurrentlyRunning;
    
    NSTimer *timer;
    int timerCount;
    
    PFLiveQueryClient *liveQueryClient;
    PFLiveQuerySubscription *liveQuerySubscription;
    PFQuery *myLocationQuery;
    PFQuery *theirLocationQuery;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self centerOnUserLocation: 0.01];
    [self configureMapView];
    [self configureLocationManager];
    [self configureSubviews];
    
    
    
}
#pragma mark:  Button Actions

- (IBAction)didTapCurrentLocation:(id)sender {
    [self centerOnUserLocation:0.01];
}

- (IBAction)didTapStats:(id)sender {
}

- (IBAction)didTapTrailRun:(id)sender {
    if (isReadyToStartRun || _cloudPolyline) {
        [self centerOnUserLocation:0.004];
        self->isCurrentlyRunning = true;
        _timerLabel.text = @"00:00:00";
        [_timerLabel setHidden:NO];
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCounter) userInfo:nil repeats:true];
        [PFUser.currentUser setValue:[NSNumber numberWithBool:YES] forKey:@"isRunning"];
        [PFUser.currentUser saveInBackground];
        [_statsButton setHidden:YES];
        [_locationButton setHidden:YES];
        [_trailrunButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_trailrunButton setTitle:@"END" forState:UIControlStateNormal];
        if (isReadyToStartRun) {
            self->isReadyToStartRun = false;
            [Run uploadRun:currentRoute withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"run sent!");
                } else {
                    NSLog(@"run not sent");
                }
            }];
        } else if (_cloudPolyline) {
            isCurrentlyRunning = true;
            [self getInterceptingDirections];
        }
    } else if (isCurrentlyRunning) {
        isCurrentlyRunning = false;
        timerCount = 0;
        [timer invalidate];
        [_trailrunButton setTitle:@"" forState:UIControlStateNormal];
        [_mapView removeOverlay:currentPolyline];
        [PFUser.currentUser setValue:[NSNull null] forKey:@"currentLocation"];
        [PFUser.currentUser saveInBackground];
        
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
    timerCount = 0;
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];

}

- (void) configureSubviews {
    _locationButton.layer.cornerRadius = 30;
    _locationButton.clipsToBounds = true;
    
    [_trailrunButton setImage:[UIImage imageNamed:@"logo_button-removebg"] forState:UIControlStateNormal];
    if (_cloudUser) {
        [self->_trailrunButton setTitle:@"Rendezvous" forState:UIControlStateNormal];
    }
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
    isReadyToStartRun = false;
    isCurrentlyRunning = false;
    
    //sending user location to Parse 
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onTimer) userInfo:nil repeats:true];

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

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    if (_timerLabel.hidden) {
        [_mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
        MKCoordinateRegion sfRegion = MKCoordinateRegionMake(_mapView.userLocation.location.coordinate,  MKCoordinateSpanMake(0.004, 0.004));
        [_mapView setRegion:sfRegion];
        

    }
}

#pragma mark:  Helpers


- (void) timerCounter {
    timerCount = timerCount + 1;
    NSString *timeString = [self secondsToHMS:timerCount];
    _timerLabel.text = timeString;
}

- (NSString *) secondsToHMS: (int ) seconds {
    return [NSString stringWithFormat:@"%02d:%02d:%02d", seconds/3600, (seconds % 3600)/60, (seconds % 3600)%60];
}

- (void) onTimer {
    if (isCurrentlyRunning) {
        if (!_cloudUser) {
        PFGeoPoint *userLocationGeoPoint = [[PFGeoPoint alloc] init];
        userLocationGeoPoint.latitude = locationManager.location.coordinate.latitude;
        userLocationGeoPoint.longitude = locationManager.location.coordinate.longitude;
        [PFUser.currentUser setValue:userLocationGeoPoint forKey:@"currentLocation"];
        [PFUser.currentUser saveInBackground];
        }
    }
//    } else {
//        [[[QueryManager alloc] init] queryLocation:_cloudUser completion:^(PFObject * _Nonnull friendLocation, NSError * _Nonnull err) {
//            if (friendLocation) {
//                PFGeoPoint *newGeoPoint = friendLocation[@"currentLocation"];
//                if (newGeoPoint.latitude) {
//                CLLocation *newFriendLocation = [[CLLocation alloc] initWithLatitude:newGeoPoint.latitude longitude:newGeoPoint.longitude];
//                [UIView animateWithDuration:1 animations:^{[self->runnerPin setCoordinate:newFriendLocation.coordinate];} completion:nil];
//                } else {
//                    NSLog(@"Mate Ended their run");
//                }
//            }
//        }];
//
//    }
//    }
}

- (void) centerOnUserLocation: (float) span{
    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(_mapView.userLocation.location.coordinate,  MKCoordinateSpanMake(span, span));
    [UIView animateWithDuration:2 animations:^{
        [self->_mapView setCenterCoordinate:self->_mapView.userLocation.location.coordinate animated:YES];
        [self->_mapView setRegion:sfRegion animated:YES];
    } completion:nil];
}

- (void) addPins:(CLLocationCoordinate2D)destinationCoord {
    MKPointAnnotation *startPin = [[MKPointAnnotation alloc] initWithCoordinate:locationManager.location.coordinate title:@"Start" subtitle:@"Me"];
    MKPointAnnotation *endPin = [[MKPointAnnotation alloc] initWithCoordinate:destinationCoord title:@"End" subtitle:@"Future Me"];
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
            [self getDirections: self->destinationLocationLatitude destlongitude:self->destinationLocationLongitude];
            [self->_trailrunButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self->_trailrunButton setTitle:@"Start" forState:UIControlStateNormal];
        } else {
            NSLog(@"No location found");
        }
    }];
}

- (void) getDirections: (float) destlatitude destlongitude: (float) destlongitude{
    float startlatitude = currentLocation.coordinate.latitude;
    float startlongitude = currentLocation.coordinate.longitude;
    
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
            self->isReadyToStartRun = true;
            self->currentPolyline = route.polyline;
            [self->_mapView addOverlay:self->currentPolyline level:MKOverlayLevelAboveRoads];
            MKMapRect mapRect = route.polyline.boundingMapRect;
            [self->_mapView setRegion:MKCoordinateRegionForMapRect(mapRect) animated:YES];
        } else {
            NSLog(@"Unable to get route %@", error.description);
        
        }
    }];
    
}

- (void) getInterceptingDirections {
        [_mapView addOverlay:_cloudPolyline];
        MKMapRect mapRect = _cloudPolyline.boundingMapRect;
        [self->_mapView setRegion:MKCoordinateRegionForMapRect(mapRect) animated:YES];

        __block NSArray *points;

        [Run retreiveRunPoints: _cloudUser completion:^(NSArray * _Nonnull runObjectPoints, NSError * _Nullable err) {
            if (runObjectPoints) {
                points = runObjectPoints;
                PFGeoPoint *geoPoint = self->_cloudUser[@"currentLocation"];
                self->cloudUserLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
                self->runnerPin = [[MKPointAnnotation alloc] initWithCoordinate:self->cloudUserLocation.coordinate title:self->_cloudUser[@"username"] subtitle:@"Running"];
                [self->_mapView addAnnotation:self->runnerPin];
                [Interceptor getBestETAPoint: 16 allPoints:points interceptorLocation:self->locationManager.location runnerLocation:self->cloudUserLocation completion:^(MKMapItem * _Nonnull bestPoint, NSError * _Nonnull err) {
                    if (bestPoint) {
                        NSLog(@"🌗🌗🌗🌗v%@", bestPoint);
                        MKPointAnnotation *rendezvousPin = [[MKPointAnnotation alloc] initWithCoordinate:bestPoint.placemark.coordinate title:@"Rendezvous" subtitle:@"Meet here"];
                        [self->_mapView addAnnotation:rendezvousPin];
                        [self getDirections:bestPoint.placemark.coordinate.latitude destlongitude:bestPoint.placemark.coordinate.longitude];
                    } else {
                        NSLog(@"No Best Point was found, eta difference greater than threshold");
                    }
                }];
            }
        }];
    }



@end
