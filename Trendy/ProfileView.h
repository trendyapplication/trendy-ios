//
//  ProfileView.h
//  Trendy
//
//  Created by NewAgeSMB on 8/5/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileView : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, retain) NSString *userid;
@property (retain, nonatomic) NSData *picData;
@property BOOL navigated;
@end
