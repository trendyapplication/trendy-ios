//
//  TrendsCell.h
//  Trendy
//
//  Created by NewAgeSMB on 8/10/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendsCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgimage;
@property (weak, nonatomic) IBOutlet UILabel *pricelabel, *brandlabel;
@property (weak, nonatomic) IBOutlet UIImageView *Trendmage;

@end
