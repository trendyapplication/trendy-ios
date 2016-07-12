//
//  NotificationCell.h
//  Trendy
//
//  Created by NewAgeSMB on 10/13/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImage, *seperatorimage;
@property (weak, nonatomic) IBOutlet UILabel *userName, *notificationLabel, *acceptlabel, *rejectlabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn, *rejectBtn;
@property (weak, nonatomic) IBOutlet UIView *requestview;
@end
