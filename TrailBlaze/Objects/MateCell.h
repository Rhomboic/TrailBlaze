//
//  MateCell.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *runningStatus;

@end

NS_ASSUME_NONNULL_END
