//
//  InviteList.h
//  Trendy
//
//  Created by NewAgeSMB on 9/22/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "ViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface InviteList : UIViewController<ABPeoplePickerNavigationControllerDelegate,
UINavigationControllerDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property(nonatomic, retain) NSString *type;
@end
