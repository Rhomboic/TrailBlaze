//
//  FriendRequest.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/13/22.
//

#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequest : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *requester;
@property (nonatomic, strong) NSString *receiver;
+ (void) uploadRequest: (NSString*)requesterID receiverID: (NSString *)receiverID withCompletion: (PFBooleanResultBlock _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
