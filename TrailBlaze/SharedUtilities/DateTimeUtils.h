//
//  Utils.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/29/22.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"
#import "SceneDelegate.h"
#import "HomeViewController.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface DateTimeUtils : NSObject

+ (NSString *) currentDateTime;
+ (void) loadHomeVC;

@end

NS_ASSUME_NONNULL_END
