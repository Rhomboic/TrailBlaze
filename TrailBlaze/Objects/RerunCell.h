//
//  RerunCell.h
//  TrailBlaze
//
//  Created by Adam Issah on 8/3/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RerunCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *startLocationAddress;
@property (weak, nonatomic) IBOutlet UILabel *endLocationAddress;
@property (weak, nonatomic) IBOutlet UILabel *averagePace;

@end

NS_ASSUME_NONNULL_END
