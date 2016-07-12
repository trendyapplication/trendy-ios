//
//  FilterView.h
//  Trendy
//
//  Created by NewAgeSMB on 9/28/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"
#import "ServerRequest.h"

@protocol delegatefilter <NSObject>

-(void)dismissed:(NSString *)status;

@end
@interface FilterView : UIViewController<delegaterequest,UIGestureRecognizerDelegate,UITextFieldDelegate>

@property(nonatomic, retain) id<delegatefilter>delegate;
@property (weak, nonatomic) IBOutlet NMRangeSlider *popularitySlider;
@property (weak, nonatomic) IBOutlet NMRangeSlider *priceSlider;
@property (weak, nonatomic) IBOutlet UITextField *votelowerLabel;
@property (weak, nonatomic) IBOutlet UITextField *voteupperLabel;
@property (weak, nonatomic) IBOutlet UITextField *pricelowerLabel;
@property (weak, nonatomic) IBOutlet UITextField *priceupperLabel, *searchfield;
@property (weak, nonatomic) NSString *btnstate;
@property (strong, nonatomic) NSDictionary *locationdetails;
@property (weak, nonatomic) NSString *filtertype, *occasion_id;
@end
