//
//  QueryManager.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/13/22.
//

#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface QueryManager : NSObject
- (instancetype)init;
- (void)queryMates: (NSInteger ) limit completion:(void (^)(NSArray *mates, NSError *))completion;
- (void)queryUsers: (NSInteger ) limit completion:(void (^)(NSArray *users, NSError *))completion;
- (void)queryRequests: (NSInteger ) limit completion:(void (^)(NSArray *friendRequests, NSError *))completion;
- (void)queryReceives: (NSInteger ) limit completion:(void (^)(NSArray *friendReceives, NSError *))completion;
- (void) uploadProfileImage: (PFFileObject * _Nullable)image withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;
@end

NS_ASSUME_NONNULL_END
