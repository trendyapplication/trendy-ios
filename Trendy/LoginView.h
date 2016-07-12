//
//  LoginView.h
//  Trendy
//
//  Created by NewAgeSMB on 2/16/16.
//  Copyright (c) 2016 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerRequest.h"
@interface LoginView : UIViewController<delegaterequest>
{
    IBOutlet UITextField *userName, *password;
}
@property BOOL notactive;
@end
