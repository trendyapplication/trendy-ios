//
//  OccasionDetail.h
//  Trendy
//
//  Created by NewAgeSMB on 9/9/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerRequest.h"
#import "FilterView.h"

@interface OccasionDetail : UIViewController<delegaterequest,delegatefilter>
@property (retain, nonatomic) NSString *occasionid, *occasionname;
@property (retain, nonatomic) NSDictionary *selectedlocation;
@property (weak, nonatomic) IBOutlet UIView *occasionTopView;
@property (weak, nonatomic) IBOutlet UIView *occassionBottomView;
@end
