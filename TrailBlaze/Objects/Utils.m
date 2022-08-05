//
//  Utils.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/29/22.
//

#import "Utils.h"
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"
#import "SceneDelegate.h"
#import "HomeViewController.h"
@import Parse;

@implementation Utils
+ (NSString *) currentDateTime {
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [DateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *) arrayToJSONString: (MKPolyline *) polyline {
    NSUInteger pointCount = polyline.pointCount;
    CLLocationCoordinate2D *routeCoordinates = malloc(pointCount * sizeof(CLLocationCoordinate2D));
    [polyline getCoordinates:routeCoordinates range:NSMakeRange(0, pointCount)];
    NSString *pointsJSON = @"{\"points\" : [";
    for (int c=0; c < pointCount-1; c++) {
        NSString *this = [NSString stringWithFormat:@"[%f, %f],", routeCoordinates[c].latitude, routeCoordinates[c].longitude];
        pointsJSON = [pointsJSON stringByAppendingString:this];
    }
    free(routeCoordinates);
    pointsJSON= [pointsJSON stringByAppendingString:[NSString stringWithFormat:@"%@ ] }", [NSString stringWithFormat:@"[%f, %f]", routeCoordinates[pointCount-1].latitude, routeCoordinates[pointCount - 1].longitude]] ];
    return pointsJSON;
}

+ (NSArray *) jsonStringToArray: (NSString *) polylineCoords {
    NSData *data = [polylineCoords dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
    return json[@"points"];
}

+ (void) loadHomeVC {
    SceneDelegate *sceneDelegate = (SceneDelegate *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    UINavigationController *navController = tabBarController.viewControllers[1];
//    HomeViewController *hvc = navController.childViewControllers[0];
    [tabBarController setSelectedViewController: navController];
    sceneDelegate.window.rootViewController = tabBarController;
}
@end
