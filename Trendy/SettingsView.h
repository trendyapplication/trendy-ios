//
//  SettingsView.h
//  Trendy
//
//  Created by NewAgeSMB on 9/21/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import "ServerRequest.h"

@interface SettingsView : UIViewController<UIActionSheetDelegate,delegaterequest>{
    
    __weak IBOutlet UIView *chngPasswordView;
    IBOutlet UIView *ratesuperview;
}
@property (weak, nonatomic) IBOutlet UIView *logutview;

@end
