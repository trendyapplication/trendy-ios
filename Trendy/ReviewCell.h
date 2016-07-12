//
//  ReviewCell.h
//  Trendy
//
//  Created by NewAgeSMB on 9/9/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *reviewownername, *reviewtext;
@property (weak, nonatomic) IBOutlet UITextView *reviewtextview;
@property (weak, nonatomic) IBOutlet UIButton *deletebtn, *reviewownerbtn;
@property (weak, nonatomic) IBOutlet UIImageView *seperatorimage;
@end
