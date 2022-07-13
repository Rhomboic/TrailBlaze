//
//  User.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/12/22.
//

#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *outGoingFriendRequests;
@property (nonatomic, strong) NSMutableArray *incomingFreindRequests;
@property BOOL *isRunning;
@property (nonatomic, strong) NSArray *currentLocation;

@end

NS_ASSUME_NONNULL_END
