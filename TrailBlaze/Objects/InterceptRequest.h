//
//  InterceptRequest.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/26/22.
//
#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface InterceptRequest : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *requester;
@property (nonatomic, strong) NSString *receiver;
@property BOOL *approved;

@end

NS_ASSUME_NONNULL_END
