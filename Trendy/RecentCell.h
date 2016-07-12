//
//  RecentCell.h
//  Trendy
//
//  Created by NewAgeSMB on 8/10/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
@property (weak, nonatomic) IBOutlet UIButton *plusbtn, *minusbtn;
@property (weak, nonatomic) IBOutlet UIImageView *plusimage, *minusimage;
@property (weak, nonatomic) IBOutlet UILabel *likecount, *reviewcount;

@end
