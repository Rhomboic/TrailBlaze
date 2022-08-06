//
//  DateTiUtils.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/29/22.
//

#import "DateTimeUtils.h"
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"
#import "SceneDelegate.h"
#import "HomeViewController.h"
@import Parse;

@implementation DateTimeUtils
+ (NSString *) currentDateTime {
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [DateFormatter stringFromDate:[NSDate date]];
}

+ (void) loadHomeVC {
    SceneDelegate *sceneDelegate = (SceneDelegate *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    UINavigationController *navController = tabBarController.viewControllers[1];
    [tabBarController setSelectedViewController: navController];
    sceneDelegate.window.rootViewController = tabBarController;
}
@end
