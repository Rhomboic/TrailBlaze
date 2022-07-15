//
//  RunCell.h
//  TrailBlaze
//
//  Created by Adam Issah on 7/13/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RunCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endLocationLabel;

@end

NS_ASSUME_NONNULL_END
