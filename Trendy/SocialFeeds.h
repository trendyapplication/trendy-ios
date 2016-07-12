//
//  SocialFeeds.h
//  Trendy
//
//  Created by NewAgeSMB on 8/7/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialFeeds : UIViewController
@property (weak, nonatomic) IBOutlet UIView *socialTopview;
@property (weak, nonatomic) IBOutlet UIView *socialBottomView;
@property (nonatomic) CGFloat lastContentOffset;
@end
