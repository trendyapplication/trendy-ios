//
//  PostStep2.h
//  Trendy
//
//  Created by NewAgeSMB on 8/10/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerRequest.h"
#import "ELCImagePickerHeader.h"
#import "FGalleryViewController.h"

@interface PostStep2 : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,delegaterequest,UIActionSheetDelegate,ELCImagePickerControllerDelegate,FGalleryViewControllerDelegate>{
    
    NSMutableURLRequest *request;
    FGalleryViewController *localGallery;
    FGalleryViewController *networkGallery;
}

@property (nonatomic, retain) NSDictionary *productdetail;
@property (nonatomic, retain) NSString *producturl;
@property (nonatomic, retain) NSString *genderUser;
@property (nonatomic, copy) NSArray *chosenImages;
@end
