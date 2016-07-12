//
//  NotificationCell.m
//  Trendy
//
//  Created by NewAgeSMB on 10/13/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell
@synthesize userImage,userName,notificationLabel,acceptBtn,acceptlabel,rejectBtn,rejectlabel,seperatorimage,requestview;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
