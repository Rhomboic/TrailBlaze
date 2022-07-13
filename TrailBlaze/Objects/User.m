//
//  User.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/12/22.
//

#import "User.h"

@implementation User

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    self.userID = dictionary[@"objectId"];
    self.username = dictionary[@"username"];
    self.email = dictionary[@"email"];
    self.friends = dictionary[@"friends"];
    self.outGoingFriendRequests = dictionary[@"outGoingFriendRequests"];
    self.incomingFreindRequests = dictionary[@"incomingFreindRequests"];
    self.isRunning = [dictionary[@"isRunning"] boolValue];
    self.currentLocation = dictionary[@"currentLocation"];
    
    return self;
}

@end
