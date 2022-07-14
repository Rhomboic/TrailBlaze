//
//  QueryManager.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/13/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QueryManager : NSObject
- (instancetype)init;
- (void)queryMates: (NSInteger ) limit completion:(void (^)(NSArray *mates, NSError *))completion;
- (void)queryUsers: (NSInteger ) limit completion:(void (^)(NSArray *mates, NSError *))completion;
- (void)queryRequests: (NSInteger ) limit completion:(void (^)(NSArray *mates, NSError *))completion;
- (void)queryReceives: (NSInteger ) limit completion:(void (^)(NSArray *friendReceives, NSError *))completion;
@end

NS_ASSUME_NONNULL_END
