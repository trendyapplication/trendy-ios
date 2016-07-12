//
//  SocialCell.h
//  Trendy
//
//  Created by NewAgeSMB on 9/24/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
@property (weak, nonatomic) IBOutlet UIView *subview;
@property (weak, nonatomic) IBOutlet UIButton *plusbtn, *minusbtn, *namebtn;
@property (weak, nonatomic) IBOutlet UIImageView *plusimage, *minusimage;
@property (weak, nonatomic) IBOutlet UILabel *likecount, *reviewcount;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UILabel *BottomNameLbl;

@end
