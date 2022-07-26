//
//  Interception.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/26/22.
//

#import "Interception.h"
#import "MapKit/Mapkit.h"
@import Parse;


@implementation Interception
@dynamic rendezvous;
@dynamic polylineCoords;
@dynamic startTime;

+ (nonnull NSString *)parseClassName {
    return @"Interception";
}

+ (void) uploadRequest: (PFGeoPoint *) rendezvous polyline: (MKPolyline *)polyline startTime: (NSString *) startTime withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Interception *newReq = [Interception new];
    [newReq setRendezvous:rendezvous];
    
    NSUInteger pointCount = polyline.pointCount;
    CLLocationCoordinate2D *routeCoordinates = malloc(pointCount * sizeof(CLLocationCoordinate2D));
    [polyline getCoordinates:routeCoordinates range:NSMakeRange(0, pointCount)];
    NSString *pointsJSON = @"{\"points\" : [";
    for (int c=0; c < pointCount-1; c++) {
        NSString *this = [NSString stringWithFormat:@"[%f, %f],", routeCoordinates[c].latitude, routeCoordinates[c].longitude];
        pointsJSON = [pointsJSON stringByAppendingString:this];
    }
      
    pointsJSON= [pointsJSON stringByAppendingString:[NSString stringWithFormat:@"%@ ] }", [NSString stringWithFormat:@"[%f, %f]", routeCoordinates[pointCount-1].latitude, routeCoordinates[pointCount - 1].longitude]] ];
    free(routeCoordinates);
    [newReq setPolylineCoords:pointsJSON];
    [newReq setStartTime:startTime];

    [newReq saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"Successfully sent intercept request!");
        }
    }];
}
@end
