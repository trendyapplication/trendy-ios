//
//  GalleryCell.h
//  Trendy
//
//  Created by NewAgeSMB on 8/10/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
@property (weak, nonatomic) IBOutlet UIImageView *leftarrowimage, *righttarrowimage;
@property (weak, nonatomic) IBOutlet UIButton *leftbtn, *rightbtn, *checkbtn, *deletebtn, *swipefullbtn;;
@property (weak, nonatomic) IBOutlet UILabel *count;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityloader;
@end
