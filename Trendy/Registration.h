//
//  Registration.h
//  Trendy
//
//  Created by NewAgeSMB on 2/16/16.
//  Copyright (c) 2016 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerRequest.h"
@interface Registration : UIViewController<delegaterequest>{
    
    IBOutlet UITextField *fName, *lName, *userName, *email, *password;
    IBOutlet UIButton *genderbtn;
    IBOutlet UILabel *femalelabel ,*malelabel;
    IBOutlet UIScrollView *scroll;
    IBOutlet UIButton *maleRadioBtn;
    IBOutlet UIButton *femaleRadioBtn;
    UITextField *lasttext;
}

@end
