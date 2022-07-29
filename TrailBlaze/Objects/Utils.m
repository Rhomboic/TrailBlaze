//
//  Utils.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/29/22.
//

#import "Utils.h"

@implementation Utils
+ (NSString *) currentDateTime {
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [DateFormatter stringFromDate:[NSDate date]];
}


@end
