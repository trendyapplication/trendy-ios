//
//  TrackingCell.h
//  Trendy
//
//  Created by NewAgeSMB on 9/24/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName, *trackingLabel;
@property (weak, nonatomic) IBOutlet UIButton *trackingBtn;

@end
