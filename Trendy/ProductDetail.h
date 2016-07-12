//
//  ProductDetail.h
//  Trendy
//
//  Created by NewAgeSMB on 9/8/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "ServerRequest.h"
#import "FGalleryViewController.h"
#import "ReviewList.h"
#import "YALContextMenuTableView.h"

@interface ProductDetail : UIViewController<delegaterequest,HPGrowingTextViewDelegate,UIGestureRecognizerDelegate,FGalleryViewControllerDelegate,deleteaction>{
    
    HPGrowingTextView *textView;
    FGalleryViewController *localGallery;
    FGalleryViewController *networkGallery;
    
    IBOutlet UIButton *contextbtn;
    IBOutlet UIView *contextview;
    
}
@property (retain, nonatomic) NSString *productid, *producttype;
@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;


@end
