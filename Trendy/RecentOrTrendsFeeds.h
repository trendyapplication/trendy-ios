//
//  RecentOrTrendsFeeds.h
//  Trendy
//
//  Created by NewAgeSMB on 8/5/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerRequest.h"
#import "NMRangeSlider.h"
#import "FilterView.h"
@interface RecentOrTrendsFeeds : UIViewController<delegaterequest,delegatefilter>{
    
   
}

@property (weak, nonatomic) IBOutlet UIView *topbarview;
@property (weak, nonatomic) IBOutlet NMRangeSlider *labelSlider;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerimg;
@property (weak, nonatomic) IBOutlet UIButton *plusbutton;
@property (weak, nonatomic) IBOutlet UIButton *recentBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblRecent;
@property (weak, nonatomic) IBOutlet UILabel *lblTrends;

@property (weak, nonatomic) IBOutlet UIView *rtBottomView;
@property (nonatomic) CGFloat lastContentOffset;
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender;
@end
