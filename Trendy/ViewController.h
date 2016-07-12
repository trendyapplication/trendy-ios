//
//  ViewController.h
//  Trendy
//
//  Created by NewAgeSMB on 8/3/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerRequest.h"

@interface ViewController : UIViewController<delegaterequest>{
    
    AppDelegate *appdelegate;
    NSString *requesttype;
    NSDictionary *fbprofiledict;
}

@end

