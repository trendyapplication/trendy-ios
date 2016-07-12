//
//  SettingsView.m
//  Trendy
//
//  Created by NewAgeSMB on 9/21/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "SettingsView.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "ServerRequest.h"
#import "Contact.h"
#import "InviteList.h"
#import "TermsAndPrivacy.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "ChangePassword.h"
#import "InterView.h"
//#import <Contacts/Contacts.h>
@interface SettingsView ()<delegaterequest,FBSDKAppInviteDialogDelegate>{
    
    IBOutlet UIButton *genderbtn, *notificationbtn, *profilebtn;
    IBOutlet UILabel *malelabel, *femalelabel, *bothlabel, *onlabel, *offlabel, *publiclabel, *privatelabel, *versionlabel;
    AppDelegate *appdelegate;
    NSString *requesttype, *gender, *notifications, *profile;
    IBOutlet UITextField *radiustext;
    IBOutlet UIScrollView *scroll;
    NSString *radius;

}

@end

@implementation SettingsView
@synthesize logutview;
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self getsettings];
    ratesuperview.hidden = YES;
    gender = @"male";
    notifications = @"on";
    profile = @"public";
    scroll.contentSize = CGSizeMake([[UIScreen mainScreen ] bounds].size.width, 492);
    if([[UIScreen mainScreen] bounds].size.height <= 568)
        scroll.scrollEnabled = YES;
    else
        scroll.scrollEnabled = NO;
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    
    [toolBar setBarStyle:UIBarStyleDefault];
    
    
    UIBarButtonItem *barButtonCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissKeyboard:)];
    barButtonCancel.tag = 0;
    barButtonCancel.width = 50;
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *barButtonSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(dismissKeyboard:)];
    barButtonSave.tag = 1;
    barButtonSave.width = 50;
    
    [fixedItem setWidth:[[UIScreen mainScreen] bounds].size.width - (barButtonSave.width + barButtonCancel.width + 50)];
    
    toolBar.items = @[barButtonCancel,fixedItem,barButtonSave];
    
    toolBar.backgroundColor = [UIColor whiteColor];
    radiustext.inputAccessoryView = toolBar;
    
//    CNContactStore *store;
//    CNContactStore store = CNContactStore();
    
    
//    NSArray *array = CNContactStore();
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"user_type"] isEqualToString:@"normal_user"]){
         chngPasswordView.hidden=NO;
    }
    else{
        chngPasswordView.hidden=YES;
        CGRect frame = logutview.frame;
        frame.origin.y = chngPasswordView.frame.origin.y;
        logutview.frame = frame;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated{
    
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
}

//-(void)viewDidAppear:(BOOL)animated{
//    
//    [self authorize_addressbook];
//}

-(void)getsettings{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_settings\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"getsettings";
}

-(void)rateviewopenorclose:(BOOL)open{
    
    if(open == YES){
        
        ratesuperview.hidden = NO;
        ratesuperview.alpha = 0;
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:1.5f];
        ratesuperview.alpha = 1.0;
        [UIView commitAnimations];
    }
    else{
        [UIView commitAnimations];
        [UIView animateWithDuration:1.0f
                              delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^(void) {
                             ratesuperview.alpha = 0;
                         }
                         completion:^(BOOL completed) {
                             if (completed) {
                                 ratesuperview.hidden = YES;
                             }
                         }];
    }
}


-(IBAction)rateapp:(id)sender{
    
    if([sender tag] == 1){
        [self rateviewopenorclose:NO];
        return;
    }
//    ServerRequest *obj = [[ServerRequest alloc] init];
//    obj.delegate = self;
//    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"set_coach_experience\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"coach_id\": \"%@\",\"communication\": \"%.1f\",\"supportiveness\": \"%.1f\",\"expertise\": \"%.1f\",\"relationship\": \"%.1f\",\"overall_experience\": \"%.1f\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,appdelegate.coachid,rateView1.rate,rateView2.rate,rateView3.rate,rateView4.rate,rateView5.rate];
//    requesttype = @"set_coach_rates";
//    NSLog(@"%@",postdata);
//    [obj serverrequest:postdata];
//    [self startLoader:@"Loading..."];
    [self rateviewopenorclose:NO];
}


-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict1 = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict1);
    if(tempdict1){
        
        
        if([[tempdict1 objectForKey:@"status"] isEqualToString:@"true"]){
          
            if([requesttype isEqualToString:@"getsettings"]){
                
                NSDictionary *tempdict = [tempdict1 objectForKey:@"settings"];
                if([tempdict objectForKey:@"gender"] != [NSNull null]){
                    
                    if([[tempdict objectForKey:@"gender"] isEqualToString:@"male"]){
                        
                        gender = @"male";
                    }
                    else if([[tempdict objectForKey:@"gender"] isEqualToString:@"both"]){
                        
                        gender = @"both";
                    }
                    else
                        gender = @"Female";
                    [self setswitches];                    
                }
                if([tempdict objectForKey:@"notifications"] != [NSNull null]){
                    if([[tempdict objectForKey:@"notifications"] isEqualToString:@"on"]){
                        
                        notifications = @"on";
                    }
                    else
                        notifications = @"off";
                    [self setswitches];
                    
                }
                if([tempdict objectForKey:@"profile"] != [NSNull null]){
                    if([[tempdict objectForKey:@"profile"] isEqualToString:@"public"]){
                        
                        profile = @"public";
                    }
                    else
                        profile = @"private";
                    
                }
                if([tempdict objectForKey:@"radius"] != [NSNull null]){
                  
                    radiustext.text = [tempdict objectForKey:@"radius"];
                    radius = radiustext.text;
                }
                [self setswitches];
            }
            else if([requesttype isEqualToString:@"save_radius"]){
                
                radius = radiustext.text;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
            }
            else if([requesttype isEqualToString:@"savesettings"]){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
            }
            
        }
        else{
            
        }
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}

- (void)authorize_addressbook{
    
    
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
    ABAddressBookRef addressbook = ABAddressBookCreate();
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL)
    {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
        {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressbook, ^(bool granted, CFErrorRef error)
                                                     {
                                                         accessGranted = granted;
                                                         dispatch_semaphore_signal(sema);
                                                     });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            //            dispatch_release(sema);
        }
        else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
        {
            
        }
        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusDenied)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Access to your contact list is denied." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            accessGranted = NO;
        }
        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusRestricted){
            accessGranted = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Access to your contact list is Restricted." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else
        {
            
        }
        
    }
}

-(IBAction)btnactions:(id)sender{
    
    if([sender tag] == 0){
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Follow" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Twitter",@"LinkedIn", nil];
        sheet.tag = 1;
        [sheet showInView:self.view];
    }
    else if([sender tag] == 1){
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Invite" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email",@"Message",@"Facebook", nil];
        [sheet showInView:self.view];
    }
    else if([sender tag] == 2){
        TermsAndPrivacy *obj = [[TermsAndPrivacy alloc] init];
        obj.webtype = @"TERMS OF SERVICES";
        obj.loggedIn = YES;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if([sender tag] == 3){
        TermsAndPrivacy *obj = [[TermsAndPrivacy alloc] init];
        obj.webtype = @"PRIVACY POLICY";
        obj.loggedIn = YES;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if([sender tag] == 4){
        
        NSString *str, *appID = @"1026863408";
        float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (ver >= 7.0 && ver < 7.1) {
            str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appID];
        } else if (ver >= 8.0) {
            str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software",appID];
        } else {
            str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appID];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
//        [self rateviewopenorclose:YES];
    }
    else if([sender tag] == 5){
        
        Contact *obj = [[Contact alloc] init];
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if([sender tag] == 20){
        
        InterView *obj = [[InterView alloc] init];
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if([sender tag] == 6){
       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to log out?" message:nil delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        [alert show];
        
    }
    else if([sender tag] == 10){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([[defaults objectForKey:@"user_type"] isEqualToString:@"normal_user"]){
            ChangePassword *obj = [[ChangePassword alloc] init];
            [self.navigationController pushViewController:obj animated:YES];

        }
        else{
            chngPasswordView.hidden=YES;
                CGRect frame = logutview.frame;
            frame.origin.y = chngPasswordView.frame.origin.y;
            logutview.frame = frame;
        }
           }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 0){

        [appdelegate logout];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
   
    if(actionSheet.tag == 1){
        
        NSString *urlstring;
        if(buttonIndex == 0)
            urlstring = @"https://www.facebook.com/trendyapplication";
        else if(buttonIndex == 1)
            urlstring = @"https://twitter.com/Trendy_App";
        else if(buttonIndex == 2)
            urlstring = @"https://www.linkedin.com/company/trendy-llc-mn-";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstring]];
    }
    else{
        if(buttonIndex == 2){
            [self fbinvites];
        }
        else{
            if(buttonIndex != 3){
                
                InviteList *obj = [[InviteList alloc] init];
                if(buttonIndex == 0){
                    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
                    obj.type = @"email";
                }
                else if(buttonIndex == 1){
                    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
                    obj.type = @"sms";
                }
                
                [self.navigationController pushViewController:obj animated:YES];
            }
            else{
                
            }
        }
    }
}

-(void)fbinvites{
   
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/710306305738136"];
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://www.mydomain.com/my_invite_image.jpg"];
    
    // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
    [FBSDKAppInviteDialog showWithContent:content
                                 delegate:self];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results{
    
    NSLog(@"--results--%@",results);
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error{
    
    NSLog(@"--error--%@",error);
}
-(IBAction)clothing:(id)sender{
     [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESHSOCIAL" object:nil];
    if(genderbtn.selected == YES){
       // notifications = @"on";
        gender = @"Female";
    }
    else{
       // notifications = @"off";
         gender = @"male";
       // genderbtn.selected = NO;
    }
    
//    if([sender tag] == 0){
//        
//        
//        
//    }
//    else if([sender tag] == 1){
//        
//       
//    }
//    else if([sender tag] == 2){
//        
//        gender = @"both";
//    }
    [self setswitches];
    [self savesettings];
    [appdelegate clearAllFilter];
}

-(IBAction)notifications:(id)sender{
    
    
    if(notificationbtn.selected == NO){
        notifications = @"on";
    }
    else{
        notifications = @"off";
    }
    [self setswitches];
    [self savesettings];
}

-(IBAction)profile:(id)sender{
    
    
    if(profilebtn.selected == NO){
        
        profile = @"public";
    }
    else{
        
        profile = @"private";
    }
    [self setswitches];
    [self savesettings];
}

-(void)setswitches{
    
    malelabel.textColor = [UIColor blackColor];
    femalelabel.textColor = [UIColor blackColor];
    bothlabel.textColor = [UIColor blackColor];
    
    if([gender isEqualToString:@"both"] || [gender isEqualToString:@"male"]){
        
        genderbtn.selected = YES;
        //genderbtn.highlighted = NO;
        malelabel.textColor = [UIColor blackColor];
        
    }
    else if([gender isEqualToString:@"Female"]){
        
        genderbtn.selected = NO;
       // genderbtn.highlighted = YES;
        femalelabel.textColor = [UIColor blackColor];
    }
    else if([gender isEqualToString:@"both"]){
        
       // genderbtn.selected = YES;
        //genderbtn.highlighted = NO;
       // bothlabel.textColor = [UIColor blackColor];
    }
    
    onlabel.textColor = [UIColor blackColor];
    offlabel.textColor = [UIColor blackColor];
    if([notifications isEqualToString:@"on"]){
        notificationbtn.selected = YES;
        onlabel.textColor = [UIColor blackColor];
    }
    else{
        notificationbtn.selected = NO;
        offlabel.textColor = [UIColor blackColor];
    }
    
    publiclabel.textColor = [UIColor blackColor];
    privatelabel.textColor = [UIColor blackColor];
    if([profile isEqualToString:@"public"]){
        
        profilebtn.selected = YES;
        publiclabel.textColor = [UIColor blackColor];
        
    }
    else{
        
        profilebtn.selected = NO;
        privatelabel.textColor = [UIColor blackColor];
    }
   
}

-(void)savesettings{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"user_settings\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"profile\": \"%@\",\"gender\": \"%@\",\"notifications\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,profile,gender,notifications];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"savesettings";
}
-(void)dismissKeyboard:(id)sender{
   
    
    if([sender tag] == 1){
       
        if(radiustext.text.length>0 && ![radiustext.text isEqualToString:@"0"]){
            ServerRequest *obj = [[ServerRequest alloc] init];
            obj.delegate = self;
            NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"save_radius\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"radius\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,radiustext.text];
            NSLog(@"%@",postdata);
            [obj serverrequest:postdata];
            [self startLoader:@"Loading..."];
            requesttype = @"save_radius";
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Enter a valid radius." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    else if([sender tag] == 0){
        radiustext.text = radius;
    }
    [radiustext resignFirstResponder];
}

#pragma mark Textfield Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
   
    [scroll setContentOffset:CGPointMake(0, 0)];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    return YES;
}

-(IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)noNetworkFound: (NSNotification *) notification
{
    NSString *status=(NSString *)[notification object];
    if (![status boolValue]) {
        
        [self stoploader];
    }
}

-(void)startLoader:(NSString *)title
{
    MBProgressHUD *objOfHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    objOfHUD.labelText = title;
    
}
-(void) stoploader{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
-(void)stopLoader:(NSNotification *) notification{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
