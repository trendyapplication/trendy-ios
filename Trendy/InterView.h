//
//  InterView.h
//  Trendy
//
//  Created by NewAgeSMB on 4/19/16.
//  Copyright © 2016 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerRequest.h"
@interface InterView : UIViewController{
    
    IBOutlet UITextView *TutorialTxtView;
    IBOutlet UIButton *BackBtn;
    IBOutlet UIWebView *webview;
    IBOutlet UILabel *DismissBtn;
    IBOutlet UIButton *DismissGreenBtn;
    
}
- (IBAction)BackClkd:(id)sender;
- (IBAction)SkipClkd:(id)sender;
@property (nonatomic, retain) NSString *IsIntroducing;
@property (nonatomic, retain) NSString *webtype;

@end
